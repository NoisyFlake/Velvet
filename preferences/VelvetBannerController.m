#include "VelvetHeaders.h"

@implementation VelvetBannerController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	UIBarButtonItem *testButton = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(testNotification)];
	self.navigationItem.rightBarButtonItem = testButton;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Banner" target:self] mutableCopy];

		for (PSSpecifier *spec in [mutableSpecifiers reverseObjectEnumerator]) {
			if ([spec.properties[@"key"] isEqual:@"customCornerRadiusBanner"]) {
				if (![[[self preferences] valueForKey:@"roundedCornersBanner"] isEqual:@"custom"]) [mutableSpecifiers removeObject:spec];
			}

			if ([[[self preferences] valueForKey:@"styleBanner"] isEqual:@"classic"]) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernBanner"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeBanner"]) [mutableSpecifiers removeObject:spec];
			} else {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicBanner"]) [mutableSpecifiers removeObject:spec];
				if ([spec.properties[@"key"] isEqual:@"colorHeaderBanner"]) [mutableSpecifiers removeObject:spec];

				if ([spec.properties[@"key"] isEqual:@"indicatorModernSizeBanner"] && ([[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"none"] || [[[self preferences] valueForKey:@"indicatorModernBanner"] isEqual:@"line"])) [mutableSpecifiers removeObject:spec];
			}

			if ([spec.properties[@"key"] isEqual:@"borderWidthBanner"]) {
				if ([[[self preferences] valueForKey:@"borderBanner"] isEqual:@"none"] || ![[self preferences] valueForKey:@"borderBanner"]) [mutableSpecifiers removeObject:spec];
			}
		}

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
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
		[self removeSpecifierID:@"indicatorModernSizeBanner" animated:YES];


		if ([self specifierForID:@"indicatorClassicBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorClassicBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"styleBanner" animated:NO];
				}
				if ([spec.properties[@"key"] isEqual:@"colorHeaderBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"indicatorClassicBanner" animated:YES];
				}
			}
		}

	} else {
		[self removeSpecifierID:@"indicatorClassicBanner" animated:NO];
		[self removeSpecifierID:@"colorHeaderBanner" animated:YES];

		if ([self specifierForID:@"indicatorModernBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"indicatorModernBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"styleBanner" animated:NO];
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
}

- (void)setBorder:(id)value specifier:(PSSpecifier*)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (![value isEqual:@"none"]) {
		if ([self specifierForID:@"borderWidthBanner"] == nil) {
			NSArray *specifiers = [self loadSpecifiersFromPlistName:@"Banner" target:self];
			for (PSSpecifier *spec in specifiers) {
				if ([spec.properties[@"key"] isEqual:@"borderWidthBanner"]) {
					[self insertSpecifier:spec afterSpecifierID:@"borderBanner" animated:YES];
					break;
				}
			}
		}
	} else {
		[self removeSpecifierID:@"borderWidthBanner" animated:YES];
	}
}

- (void)testNotification {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"com.initwithframe.velvet/testRegular", NULL, NULL, YES);
}

@end
