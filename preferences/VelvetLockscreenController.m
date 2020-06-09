#include "VelvetHeaders.h"

@implementation VelvetLockscreenController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(testNotification)];
	self.navigationItem.rightBarButtonItem = testButton;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Lockscreen" target:self] mutableCopy];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"customCornerRadiusLockscreen"]) {
				if (![[[self preferences] valueForKey:@"roundedCornersLockscreen"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([[[self preferences] valueForKey:@"styleLockscreen"] isEqual:@"classic"]) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeLockscreen"]) [mutableSpecifiers removeObject:spec];
			} else {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"colorHeaderLockscreen"]) [mutableSpecifiers removeObject:spec];

				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeLockscreen"] && ([[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"line"])) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"borderWidthLockscreen"]) {
				if ([[[self preferences] valueForKey:@"borderLockscreen"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderLockscreen"]) [mutableSpecifiers removeObject:spec];
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (void)setRoundedCorners:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"custom"]) {
		if ([self specifierForID:@"customCornerRadiusLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"customCornerRadiusLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"roundedCornersLockscreen" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"customCornerRadiusLockscreen" animated:YES];
	}
}

- (void)setStyle:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"classic"]) {
		[self removeSpecifierID:@"indicatorModernLockscreen" animated:NO];
		[self removeSpecifierID:@"indicatorModernSizeLockscreen" animated:YES];


		if ([self specifierForID:@"indicatorClassicLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"styleLockscreen" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"colorHeaderLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorClassicLockscreen" animated:YES];
				}
			}
		}

	} else {
		[self removeSpecifierID:@"indicatorClassicLockscreen" animated:NO];
		[self removeSpecifierID:@"colorHeaderLockscreen" animated:YES];

		if ([self specifierForID:@"indicatorModernLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"styleLockscreen" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeLockscreen"] && !([[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"line"])) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernLockscreen" animated:YES];
				}
			}
		}

	}
}

- (void)setIndicatorModern:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"icon"] || [value isEqual:@"dot"] || [value isEqual:@"triangle"]) {
		if ([self specifierForID:@"indicatorModernSizeLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernLockscreen" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"indicatorModernSizeLockscreen" animated:YES];
	}
}

- (void)setBorder:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (![value isEqual:@"none"]) {
		if ([self specifierForID:@"borderWidthLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"borderWidthLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"borderLockscreen" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"borderWidthLockscreen" animated:YES];
	}
}

- (void)testNotification {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.initwithframe.velvet/testLockscreen", NULL, NULL, YES);
}

@end
