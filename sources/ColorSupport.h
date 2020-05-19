@interface RGBPixel : NSObject
@property int r, g, b, d;
@end

@interface UIImage (Velvet)
- (UIColor *)velvetDominantColor;
- (int)colourDistance:(RGBPixel *)a andB:(RGBPixel *)b;
@end

@interface UIColor (Velvet)
- (CGFloat)velvetColorBrightness;
+ (UIColor *)colorFromHexString:(NSString *)hexString;
@end