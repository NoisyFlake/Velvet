#import "Headers.h"
#import "VelvetPrefs.h"

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

- (instancetype)initWithSuiteName:(NSString *)suitename {
    VelvetPrefs *prefs = [super initWithSuiteName:suitename];

    [prefs registerDefaults:@{
        @"enabled": @YES,
        @"enableBanners" : @YES,
        @"enableLockscreen" : @YES,
        @"enableMediaplayer" : @YES,
        @"enableWidgets" : @YES,

        @"styleBanner": @"modern",
        @"indicatorClassicBanner": @"icon",
        @"indicatorModernBanner": @"icon",
        @"indicatorModernSizeBanner": @32,
        @"colorHeaderBanner": @NO,
        @"hideBackgroundBanner": @NO,
        @"colorBackgroundBanner": @NO,
        @"colorPrimaryLabelBanner": @YES,
        @"colorSecondaryLabelBanner": @NO,
        @"nameAsTitleBanner": @NO,
        @"borderBanner": @"none",
        @"borderWidthBanner": @2,
        @"roundedCornersBanner": @"stock",
        @"customCornerRadiusBanner": @13,

        @"styleLockscreen": @"modern",
        @"indicatorClassicLockscreen": @"icon",
        @"indicatorModernLockscreen": @"icon",
        @"indicatorModernSizeLockscreen": @32,
        @"colorHeaderLockscreen": @NO,
        @"hideBackgroundLockscreen": @NO,
        @"colorBackgroundLockscreen": @NO,
        @"colorPrimaryLabelLockscreen": @YES,
        @"colorSecondaryLabelLockscreen": @NO,
        @"nameAsTitleLockscreen": @NO,
        @"borderLockscreen": @"none",
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