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
}

- (instancetype)initWithSuiteName:(NSString *)suitename {
    VelvetPrefs *prefs = [super initWithSuiteName:suitename];

    [prefs mergeOldSettings];

    [prefs registerDefaults:@{
        @"enabled": @YES,
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
        @"colorHeaderBanner": @"dominant",
        @"colorBackgroundBanner": @"none",
        @"colorPrimaryLabelBanner": @"dominant",
        @"colorSecondaryLabelBanner": @"none",
        @"nameAsTitleBanner": @NO,
        @"borderColorBanner": @"none",
        @"borderPositionBanner": @"all",
        @"borderWidthBanner": @2,
        @"roundedCornersBanner": @"stock",
        @"customCornerRadiusBanner": @13,

        @"styleLockscreen": @"modern",
        @"indicatorClassicLockscreen": @"icon",
        @"indicatorClassicColorLockscreen": @"dominant",
        @"indicatorModernLockscreen": @"icon",
        @"indicatorModernColorLockscreen": @"dominant",
        @"indicatorModernSizeLockscreen": @32,
        @"colorHeaderLockscreen": @"dominant",
        @"colorBackgroundLockscreen": @"none",
        @"colorPrimaryLabelLockscreen": @"dominant",
        @"colorSecondaryLabelLockscreen": @"none",
        @"nameAsTitleLockscreen": @NO,
        @"borderColorLockscreen": @"none",
        @"borderPositionLockscreen": @"all",
        @"borderWidthLockscreen": @2,
        @"roundedCornersLockscreen": @"stock",
        @"customCornerRadiusLockscreen": @13,

        @"hideBackgroundMediaplayer": @NO,
        @"colorBackgroundMediaplayer": @NO,
        @"borderMediaplayer": @"none",
        @"borderWidthMediaplayer": @2,
        @"roundedCornersMediaplayer": @"stock",
        @"customCornerRadiusMediaplayer": @13,

        @"colorHeaderWidget": @NO,
        @"hideBackgroundWidget": @NO,
        @"colorBackgroundWidget": @NO,
        @"borderWidget": @"none",
        @"borderWidthWidget": @2,
        @"roundedCornersWidget": @"stock",
        @"customCornerRadiusWidget": @13
    }];

    return prefs;
}

@end