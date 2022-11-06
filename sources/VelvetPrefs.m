#import "Headers.h"
#import "VelvetPrefs.h"
#include <objc/runtime.h>

@implementation VelvetPrefs

+ (instancetype)sharedInstance {
    static VelvetPrefs *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[VelvetPrefs alloc] initWithSuiteName:@"com.initwithframe.velvet"];
    });

    return sharedInstance;
}

+ (NSMutableDictionary *)colorCache {
    static NSMutableDictionary *colorCache = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        colorCache = [[NSMutableDictionary alloc] init];
    });

    return colorCache;
}

- (void)convertBoolToString:(NSString *)key {
    if ([[self objectForKey:key] isKindOfClass:objc_getClass("__NSCFBoolean")]) {
        if ([self boolForKey:key]) {
            [self setValue:@"dominant" forKey:key];
        } else {
            [self setValue:@"none" forKey:key];
        }
    }
}

- (void)mergeOldSettings {
    [self convertBoolToString:@"colorBackgroundBanner"];
    [self convertBoolToString:@"colorHeaderBanner"];
    [self convertBoolToString:@"colorPrimaryLabelBanner"];
    [self convertBoolToString:@"colorSecondaryLabelBanner"];

    [self convertBoolToString:@"colorHeaderLockscreen"];
    [self convertBoolToString:@"colorBackgroundLockscreen"];
    [self convertBoolToString:@"colorPrimaryLabelLockscreen"];
    [self convertBoolToString:@"colorSecondaryLabelLockscreen"];

    [self convertBoolToString:@"colorHeaderWidget"];
    [self convertBoolToString:@"colorBackgroundWidget"];

    [self convertBoolToString:@"colorBackgroundMediaplayer"];

    if ([[self objectForKey:@"hideBackgroundLockscreen"] isKindOfClass:objc_getClass("__NSCFBoolean")]) {
        if ([self boolForKey:@"hideBackgroundLockscreen"]) {
            [self setValue:@"#000000:0.00" forKey:@"colorBackgroundLockscreen"];
            [self removeObjectForKey:@"hideBackgroundLockscreen"];
        }
    }

    if ([[self objectForKey:@"hideBackgroundWidget"] isKindOfClass:objc_getClass("__NSCFBoolean")]) {
        if ([self boolForKey:@"hideBackgroundWidget"]) {
            [self setValue:@"#000000:0.00" forKey:@"colorBackgroundWidget"];
            [self removeObjectForKey:@"hideBackgroundWidget"];
        }
    }

    if ([self valueForKey:@"borderBanner"] && ![[self valueForKey:@"borderBanner"] isEqual:@"none"]) {
        [self setValue:[self valueForKey:@"borderBanner"] forKey:@"borderPositionBanner"];
        [self setValue:@"dominant" forKey:@"borderColorBanner"];
        [self removeObjectForKey:@"borderBanner"];
    }

    if ([self valueForKey:@"borderLockscreen"] && ![[self valueForKey:@"borderLockscreen"] isEqual:@"none"]) {
        [self setValue:[self valueForKey:@"borderLockscreen"] forKey:@"borderPositionLockscreen"];
        [self setValue:@"dominant" forKey:@"borderColorLockscreen"];
        [self removeObjectForKey:@"borderLockscreen"];
    }

    if ([self valueForKey:@"borderWidget"] && ![[self valueForKey:@"borderWidget"] isEqual:@"none"]) {
        [self setValue:[self valueForKey:@"borderWidget"] forKey:@"borderPositionWidget"];
        [self setValue:@"dominant" forKey:@"borderColorWidget"];
        [self removeObjectForKey:@"borderWidget"];
    }

    if ([self valueForKey:@"borderMediaplayer"] && ![[self valueForKey:@"borderMediaplayer"] isEqual:@"none"]) {
        [self setValue:[self valueForKey:@"borderMediaplayer"] forKey:@"borderPositionMediaplayer"];
        [self setValue:@"dominant" forKey:@"borderColorMediaplayer"];
        [self removeObjectForKey:@"borderMediaplayer"];
    }
}

- (instancetype)initWithSuiteName:(NSString *)suitename {
    VelvetPrefs *prefs = [super initWithSuiteName:suitename];

    [prefs mergeOldSettings];

    [prefs registerDefaults:@{
        @"enabled": @NO,
        @"enableBanners" : @YES,
        @"enableLockscreen" : @YES,
        @"enableMediaplayer" : @YES,
        @"enableWidgets" : @YES,

        @"styleBanner": @"modern",
        @"indicatorClassicBanner": @"icon",
        @"indicatorClassicColorBanner": @"dominant",
        @"indicatorModernBanner": @"icon",
        @"indicatorModernColorBanner": @"dominant",
        @"indicatorModernSizeBanner": @32,
        @"forceModeBanner": @"default",
        @"colorHeaderBanner": @"dominant",
        @"gradientHeaderBanner": @"no",
        @"colorHeaderTitleBanner": @"none",
        @"colorHeaderDateBanner": @"none",
        @"colorBackgroundBanner": @"none",
        @"colorPrimaryLabelBanner": @"dominant",
        @"colorSecondaryLabelBanner": @"none",
        @"borderColorBanner": @"none",
        @"borderPositionBanner": @"all",
        @"borderWidthBanner": @2,
        @"roundedCornersBanner": @"stock",
        @"customCornerRadiusBanner": @13,
        @"indicatorRoundedCornerBanner" : @"stock",
        @"indicatorCustomRoundedCornerBanner" : @5,
        @"useContactPictureBanner": @YES,
        @"contactPictureNetworkBanner": @YES,
        @"useContactPictureIconBanner": @YES,
        @"contactPictureBorderBanner":@"none",
        @"compactStyleBanner": @NO,

        @"styleLockscreen": @"modern",
        @"indicatorClassicLockscreen": @"icon",
        @"indicatorClassicColorLockscreen": @"dominant",
        @"indicatorModernLockscreen": @"icon",
        @"indicatorModernColorLockscreen": @"dominant",
        @"indicatorModernSizeLockscreen": @32,
        @"forceModeLockscreen": @"default",
        @"colorHeaderLockscreen": @"stock",
        @"gradientHeaderLockscreen": @"no",
        @"colorHeaderTitleLockscreen": @"none",
        @"colorHeaderDateLockscreen": @"none",
        @"colorBackgroundLockscreen": @"none",
        @"colorPrimaryLabelLockscreen": @"dominant",
        @"colorSecondaryLabelLockscreen": @"none",
        @"borderColorLockscreen": @"none",
        @"borderPositionLockscreen": @"all",
        @"borderWidthLockscreen": @2,
        @"roundedCornersLockscreen": @"stock",
        @"customCornerRadiusLockscreen": @13,
        @"indicatorRoundedCornerLockscreen" : @"stock",
        @"indicatorCustomRoundedCornerLockscreen" : @5,
        @"useContactPictureLockscreen": @YES,
        @"contactPictureNetworkLockscreen": @YES,
        @"useContactPictureIconLockscreen": @YES,
        @"contactPictureBorderLockscreen":@"none",
        @"compactStyleLockscreen": @NO,

        @"colorBackgroundMediaplayer": @"none",
        @"borderColorMediaplayer": @"none",
        @"borderPositionMediaplayer": @"all",
        @"borderWidthMediaplayer": @2,
        @"roundedCornersMediaplayer": @"stock",
        @"customCornerRadiusMediaplayer": @13,
        @"forceModeMediaplayer": @"default",

        @"colorHeaderWidget": @"none",
        @"colorBackgroundWidget": @"none",
        @"borderColorWidget": @"none",
        @"borderPositionWidget": @"all",
        @"borderWidthWidget": @2,
        @"roundedCornersWidget": @"stock",
        @"customCornerRadiusWidget": @13
    }];

    return prefs;
}

@end