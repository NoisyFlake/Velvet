@interface VelvetPrefs : NSUserDefaults
+(instancetype)sharedInstance;
+ (NSMutableDictionary *)colorCache;
@end

VelvetPrefs *preferences;
NSMutableDictionary *colorCache;