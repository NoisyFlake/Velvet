#include "VelvetHeaders.h"

@implementation VelvetWidgetController
- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Widget" target:self] mutableCopy];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"customCornerRadiusWidget"]) {
				if (![[[self preferences] valueForKey:@"roundedCornersWidget"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"borderWidthWidget"]) {
				if ([[[self preferences] valueForKey:@"borderWidget"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderWidget"]) [mutableSpecifiers removeObject:spec];
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (void)setRoundedCorners:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"custom"]) {
		if ([self specifierForID:@"customCornerRadiusWidget"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Widget" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"customCornerRadiusWidget"]) {
					[self insertSpecifier:spec afterSpecifierID:@"roundedCornersWidget" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"customCornerRadiusWidget" animated:YES];
	}
}

- (void)setBorder:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (![value isEqual:@"none"]) {
		if ([self specifierForID:@"borderWidthWidget"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Widget" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"borderWidthWidget"]) {
					[self insertSpecifier:spec afterSpecifierID:@"borderWidget" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"borderWidthWidget" animated:YES];
	}
}

@end
