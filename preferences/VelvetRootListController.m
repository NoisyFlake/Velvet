#include "VelvetHeaders.h"

@implementation VelvetRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"customCornerRadius"]) {
				if (![[[self preferences] valueForKey:@"roundedCorners"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}
		}
		
		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (void)setRoundedCorners:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"custom"]) {
		if ([self specifierForID:@"customCornerRadius"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"customCornerRadius"]) {
					[self insertSpecifier:spec afterSpecifierID:@"roundedCorners" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"customCornerRadius" animated:YES];
	}
}

@end
