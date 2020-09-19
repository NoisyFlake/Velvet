#include "VelvetHeaders.h"

@implementation VelvetBannerController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(testNotification)];
	self.navigationItem.rightBarButtonItem = testButton;
	[self setupHeader];
}

- (void)setupHeader {
	UIImage *image = [[UIImage alloc] initWithContentsOfFile: @"/Library/PreferenceBundles/Velvet.bundle/Images/previewBanner.png"];

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
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Banner" target:self] mutableCopy];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"indicatorCustomRoundedCornerBanner"]) {
				if (![[[self preferences] valueForKey:@"indicatorRoundedCornerBanner"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"customCornerRadiusBanner"]) {
				if (![[[self preferences] valueForKey:@"roundedCornersBanner"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([[[self preferences] valueForKey:@"styleBanner"] isEqual:@"classic"]) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernBanner"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernColorBanner"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeBanner"]) [mutableSpecifiers removeObject:spec];

				if ([spec.properties[@"key"] isEqual:@"indicatorClassicColorBanner"] && ([[[self preferences] valueForKey:@"indicatorClassicBanner"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorClassicBanner"] isEqual:@"icon"])) [mutableSpecifiers removeObject:spec];
			} else {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicBanner"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicColorBanner"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"colorHeaderBanner"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"colorHeaderTitleBanner"]) [mutableSpecifiers removeObject:spec];

				if ([spec.properties[@"key"] isEqual:@"indicatorModernColorBanner"] && ([[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"icon"])) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeBanner"] && ([[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"line"])) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"borderPositionBanner"]) {
				if ([[[self preferences] valueForKey:@"borderColorBanner"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderColorBanner"]) [mutableSpecifiers removeObject:spec];
			}
			if ([spec.properties[@"key"] isEqual:@"borderWidthBanner"]) {
				if ([[[self preferences] valueForKey:@"borderColorBanner"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderColorBanner"]) [mutableSpecifiers removeObject:spec];
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

- (void)setAppIconRoundedCorners:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"custom"]) {
		if ([self specifierForID:@"indicatorCustomRoundedCornerBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorCustomRoundedCornerBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorRoundedCornerBanner" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"indicatorCustomRoundedCornerBanner" animated:YES];
	}
}

- (void)setRoundedCorners:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"custom"]) {
		if ([self specifierForID:@"customCornerRadiusBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"customCornerRadiusBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"roundedCornersBanner" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"customCornerRadiusBanner" animated:YES];
	}
}

- (void)setStyle:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"classic"]) {
		[self removeSpecifierID:@"indicatorModernBanner" animated:NO];
		[self removeSpecifierID:@"indicatorModernColorBanner" animated:NO];
		[self removeSpecifierID:@"indicatorModernSizeBanner" animated:YES];


		if ([self specifierForID:@"indicatorClassicBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"styleBanner" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicColorBanner"] && !([[[self preferences] valueForKey:@"indicatorClassicBanner"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorClassicBanner"] isEqual:@"icon"])) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorClassicBanner" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"colorHeaderBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorClassicBanner" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"colorHeaderTitleBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"colorHeaderBanner" animated:YES];
				}
			}
		}

	} else {
		[self removeSpecifierID:@"indicatorClassicBanner" animated:NO];
		[self removeSpecifierID:@"indicatorClassicColorBanner" animated:NO];
		[self removeSpecifierID:@"colorHeaderBanner" animated:YES];
		[self removeSpecifierID:@"colorHeaderTitleBanner" animated:YES];

		if ([self specifierForID:@"indicatorModernBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"styleBanner" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"indicatorModernColorBanner"] && !([[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"icon"])) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernBanner" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeBanner"] && !([[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"line"])) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernBanner" animated:YES];
				}
			}
		}

	}
}

- (void)setIndicatorModern:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"icon"] || [value isEqual:@"dot"] || [value isEqual:@"triangle"]) {
		if ([self specifierForID:@"indicatorModernSizeBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernBanner" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"indicatorModernSizeBanner" animated:YES];
	}

	if ([value isEqual:@"line"] || [value isEqual:@"dot"] || [value isEqual:@"triangle"]) {
		if ([self specifierForID:@"indicatorModernColorBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernColorBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorModernBanner" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"indicatorModernColorBanner" animated:YES];
	}
}

- (void)setIndicatorClassic:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if ([value isEqual:@"line"] || [value isEqual:@"dot"] || [value isEqual:@"triangle"]) {
		if ([self specifierForID:@"indicatorClassicColorBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicColorBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorClassicBanner" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"indicatorClassicColorBanner" animated:YES];
	}
}

- (void)setBorder:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (![value isEqual:@"none"]) {
		if ([self specifierForID:@"borderPositionBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"borderPositionBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"borderColorBanner" animated:YES];
				}
				if ([spec.properties[@"key"] isEqual:@"borderWidthBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"borderPositionBanner" animated:YES];
				}
			}
		}
	} else {
		[self removeSpecifierID:@"borderPositionBanner" animated:YES];
		[self removeSpecifierID:@"borderWidthBanner" animated:YES];
	}
}

- (void)testNotification {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.initwithframe.velvet/testRegular", NULL, NULL, YES);
}

@end
