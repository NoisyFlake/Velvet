#include "VelvetHeaders.h"

@implementation VelvetMediaplayerController
- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Mediaplayer" target:self] mutableCopy];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"customCornerRadiusMediaplayer"]) {
				if (![[[self preferences] valueForKey:@"roundedCornersMediaplayer"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"borderPositionMediaplayer"]) {
				if ([[[self preferences] valueForKey:@"borderColorMediaplayer"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderColorMediaplayer"]) [mutableSpecifiers removeObject:spec];
			}
			if ([spec.properties[@"key"] isEqual:@"borderWidthMediaplayer"]) {
				if ([[[self preferences] valueForKey:@"borderColorMediaplayer"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderColorMediaplayer"]) [mutableSpecifiers removeObject:spec];
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
@end
