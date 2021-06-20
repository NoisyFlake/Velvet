#include "VelvetHeaders.h"

@implementation VelvetLockscreenController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(testNotification)];
	self.navigationItem.rightBarButtonItem = testButton;

	[self setupHeader];
}

- (void)setupHeader {
	UIImage *image = [[UIImage alloc] initWithContentsOfFile: @"/Library/PreferenceBundles/Velvet.bundle/Images/previewLockscreen.png"];

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 30, image.size.height / 2)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, self.view.bounds.size.width - 30, image.size.height / 2)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    [imageView setImage:image];

    [header addSubview:imageView];

	// Ugly workaround for devices where it whould overlap the selector
	header.layer.zPosition = -1;

    [self.table setTableHeaderView:header];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Lockscreen" target:self] mutableCopy];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"indicatorCustomRoundedCornerLockscreen"]) {
				if (![[[self preferences] valueForKey:@"indicatorRoundedCornerLockscreen"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"customCornerRadiusLockscreen"]) {
				if (![[[self preferences] valueForKey:@"roundedCornersLockscreen"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([[[self preferences] valueForKey:@"styleLockscreen"] isEqual:@"classic"]) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernColorLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeLockscreen"]) [mutableSpecifiers removeObject:spec];

				if ([spec.properties[@"key"] isEqual:@"contactPictureLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"useContactPictureLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"useContactPictureIconLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"contactPictureBorderLockscreen"]) [mutableSpecifiers removeObject:spec];

				if ([spec.properties[@"key"] isEqual:@"indicatorClassicColorLockscreen"] && ([[[self preferences] valueForKey:@"indicatorClassicLockscreen"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorClassicLockscreen"] isEqual:@"icon"])) [mutableSpecifiers removeObject:spec];
			} else {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicColorLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"colorHeaderLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"colorHeaderTitleLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"gradientHeaderLockscreen"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"headerOptionsLockscreen"]) [mutableSpecifiers removeObject:spec];

				if ([spec.properties[@"key"] isEqual:@"indicatorModernColorLockscreen"] && ([[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"icon"])) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeLockscreen"] && ([[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"line"])) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"borderPositionLockscreen"]) {
				if ([[[self preferences] valueForKey:@"borderColorLockscreen"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderColorLockscreen"]) [mutableSpecifiers removeObject:spec];
			}
			if ([spec.properties[@"key"] isEqual:@"borderWidthLockscreen"]) {
				if ([[[self preferences] valueForKey:@"borderColorLockscreen"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderColorLockscreen"]) [mutableSpecifiers removeObject:spec];
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (void)setAppIconRoundedCorners:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"custom"]) {
		if ([self specifierForID:@"indicatorCustomRoundedCornerLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorCustomRoundedCornerLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorRoundedCornerLockscreen" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"indicatorCustomRoundedCornerLockscreen" animated:YES];
	}
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
		[self removeSpecifierID:@"indicatorModernColorLockscreen" animated:NO];
		[self removeSpecifierID:@"indicatorModernSizeLockscreen" animated:YES];

		[self removeSpecifierID:@"contactPictureLockscreen" animated:NO];
		[self removeSpecifierID:@"useContactPictureLockscreen" animated:NO];
		[self removeSpecifierID:@"useContactPictureIconLockscreen" animated:NO];
		[self removeSpecifierID:@"contactPictureBorderLockscreen" animated:YES];


		if ([self specifierForID:@"indicatorClassicLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"styleLockscreen" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicColorLockscreen"] && !([[[self preferences] valueForKey:@"indicatorClassicLockscreen"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorClassicLockscreen"] isEqual:@"icon"])) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorClassicLockscreen" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"headerOptionsLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorClassicLockscreen" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"colorHeaderLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"headerOptionsLockscreen" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"gradientHeaderLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"colorHeaderLockscreen" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"colorHeaderTitleLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"gradientHeaderLockscreen" animated:YES];
				}
			}
		}

	} else {
		[self removeSpecifierID:@"indicatorClassicLockscreen" animated:NO];
		[self removeSpecifierID:@"indicatorClassicColorLockscreen" animated:NO];
		[self removeSpecifierID:@"colorHeaderLockscreen" animated:YES];
		[self removeSpecifierID:@"colorHeaderTitleLockscreen" animated:YES];
		[self removeSpecifierID:@"gradientHeaderLockscreen" animated:YES];
		[self removeSpecifierID:@"headerOptionsLockscreen" animated:YES];

		if ([self specifierForID:@"indicatorModernLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"styleLockscreen" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"indicatorModernColorLockscreen"] && !([[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"icon"])) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernLockscreen" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeLockscreen"] && !([[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernLockscreen"] isEqual:@"line"])) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernLockscreen" animated:YES];
				}

				if ([spec.properties[@"key"] isEqual:@"contactPictureLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernSizeLockscreen" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"useContactPictureLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"contactPictureLockscreen" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"useContactPictureIconLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"useContactPictureLockscreen" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"contactPictureBorderLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"useContactPictureIconLockscreen" animated:NO];
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

	if ([value isEqual:@"line"] || [value isEqual:@"dot"] || [value isEqual:@"triangle"]) {
		if ([self specifierForID:@"indicatorModernColorLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernColorLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernLockscreen" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"indicatorModernColorLockscreen" animated:YES];
	}
}

- (void)setIndicatorClassic:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"line"] || [value isEqual:@"dot"] || [value isEqual:@"triangle"]) {
		if ([self specifierForID:@"indicatorClassicColorLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicColorLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorClassicLockscreen" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"indicatorClassicColorLockscreen" animated:YES];
	}
}

- (void)setBorder:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (![value isEqual:@"none"]) {
		if ([self specifierForID:@"borderPositionLockscreen"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Lockscreen" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"borderPositionLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"borderColorLockscreen" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"borderWidthLockscreen"]) {
					[self insertSpecifier:spec afterSpecifierID:@"borderPositionLockscreen" animated:YES];
				}
			}
		}
	} else {
		[self removeSpecifierID:@"borderPositionLockscreen" animated:YES];
		[self removeSpecifierID:@"borderWidthLockscreen" animated:YES];
	}
}

- (void)testNotification {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.initwithframe.velvet/testLockscreen", NULL, NULL, YES);
}

@end
