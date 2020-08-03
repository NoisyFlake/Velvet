@interface RGBPixel : NSObject
@property int r, g, b, d;
@end

@interface UIImage (VelvetColorSupport)
- (UIColor *)velvetDominantColor;
- (int)colourDistance:(RGBPixel *)a andB:(RGBPixel *)b;
- (UIColor *)velvetAverageColor;
@end

@interface UIColor (VelvetColorSupport)
- (CGFloat)velvetColorBrightness;
+ (UIColor *)velvetColorFromHexString:(NSString *)hexString;
@end