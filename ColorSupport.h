@interface RGBPixel : NSObject
@property int r, g, b, d;
@end

@interface UIImage (CozyBadges)
- (UIColor *)velvetDominantColor;
-(int)colourDistance:(RGBPixel *)a andB:(RGBPixel *)b;
@end