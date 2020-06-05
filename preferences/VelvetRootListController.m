#include "VelvetHeaders.h"

@implementation VelvetRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"customCornerRadius"]) {
				if (![[[self preferences] valueForKey:@"roundedCorners"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([[[self preferences] valueForKey:@"style"] isEqual:@"classic"]) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModern"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSize"]) [mutableSpecifiers removeObject:spec];
			} else if ([[[self preferences] valueForKey:@"style"] isEqual:@"modern"]) {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassic"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"colorHeader"]) [mutableSpecifiers removeObject:spec];

				if ([spec.properties[@"key"] isEqual:@"indicatorModernSize"] && ([[[self preferences] valueForKey:@"indicatorModern"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModern"] isEqual:@"line"])) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"borderWidth"]) {
				if ([[[self preferences] valueForKey:@"border"] isEqual:@"none"]) [mutableSpecifiers removeObject:spec];
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

- (void)setStyle:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"classic"]) {
		[self removeSpecifierID:@"indicatorModern" animated:NO];
		[self removeSpecifierID:@"indicatorModernSize" animated:YES];
		
		
		if ([self specifierForID:@"indicatorClassic"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassic"]) {
					[self insertSpecifier:spec afterSpecifierID:@"style" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"colorHeader"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorClassic" animated:YES];
				}
			}
		}
		
	} else {
		[self removeSpecifierID:@"indicatorClassic" animated:NO];
		[self removeSpecifierID:@"colorHeader" animated:YES];
		
		if ([self specifierForID:@"indicatorModern"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModern"]) {
					[self insertSpecifier:spec afterSpecifierID:@"style" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSize"] && ([[[self preferences] valueForKey:@"indicatorModern"] isEqual:@"icon"] || [[[self preferences] valueForKey:@"indicatorModern"] isEqual:@"dot"] || [[[self preferences] valueForKey:@"indicatorModern"] isEqual:@"triangle"])) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModern" animated:YES];
				}
			}
		}

	}
}

- (void)setIndicatorModern:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"icon"] || [value isEqual:@"dot"] || [value isEqual:@"triangle"]) {
		if ([self specifierForID:@"indicatorModernSize"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSize"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModern" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"indicatorModernSize" animated:YES];
	}
}

- (void)setBorder:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (![value isEqual:@"none"]) {
		if ([self specifierForID:@"borderWidth"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"borderWidth"]) {
					[self insertSpecifier:spec afterSpecifierID:@"border" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"borderWidth" animated:YES];
	}
}

- (void)testLockscreen {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.initwithframe.velvet/testLockscreen", NULL, NULL, YES);
}

- (void)testRegular {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.initwithframe.velvet/testRegular", NULL, NULL, YES);
}

@end
