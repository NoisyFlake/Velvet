#include "VelvetHeaders.h"

@implementation VelvetMediaplayerController
- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Mediaplayer" target:self] mutableCopy];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"customCornerRadiusMediaplayer"]) {
				if (![[[self preferences] valueForKey:@"roundedCornersMediaplayer"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([[[self preferences] valueForKey:@"styleMediaplayer"] isEqual:@"classic"]) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernMediaplayer"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeMediaplayer"]) [mutableSpecifiers removeObject:spec];
			} else {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicMediaplayer"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"colorHeaderMediaplayer"]) [mutableSpecifiers removeObject:spec];

				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeMediaplayer"] && ([[[self preferences] valueForKey:@"indicatorModernMediaplayer"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernMediaplayer"] isEqual:@"line"])) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"borderWidthMediaplayer"]) {
				if ([[[self preferences] valueForKey:@"borderMediaplayer"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderMediaplayer"]) [mutableSpecifiers removeObject:spec];
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (void)setRoundedCorners:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"custom"]) {
		if ([self specifierForID:@"customCornerRadiusMediaplayer"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Mediaplayer" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"customCornerRadiusMediaplayer"]) {
					[self insertSpecifier:spec afterSpecifierID:@"roundedCornersMediaplayer" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"customCornerRadiusMediaplayer" animated:YES];
	}
}

- (void)setBorder:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (![value isEqual:@"none"]) {
		if ([self specifierForID:@"borderWidthMediaplayer"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Mediaplayer" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"borderWidthMediaplayer"]) {
					[self insertSpecifier:spec afterSpecifierID:@"borderMediaplayer" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"borderWidthMediaplayer" animated:YES];
	}
}

@end
