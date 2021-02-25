#import "ColorSupport.h"

@implementation RGBPixel
@end

@implementation UIImage (Velvet)
- (UIColor *)velvetDominantColor {

    int width = self.size.width;
    int height = self.size.height;

    int limit = 2000;

    if (width * height > limit) {
        float ratio = width / height;
        float maxWidth = sqrtf(ratio * limit);

        width = (int)maxWidth;
        height = (int)(limit / maxWidth);
    }

    int tolerance = 40;

    CGImageRef imageRef = [self CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;

    unsigned char *rawData = calloc(bytesPerRow * height, sizeof(unsigned char));

    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    NSMutableArray *imageColors = [[NSMutableArray alloc] init];

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {

            int i = (bytesPerRow * y) + x * bytesPerPixel;

            if (rawData[i + 3] < 128) continue;

            RGBPixel *pixel = [[RGBPixel alloc] init];
            pixel.r = rawData[i];
            pixel.g = rawData[i + 1];
            pixel.b = rawData[i + 2];

            BOOL colorExists = false;
            for (RGBPixel *color in imageColors) {
                int distance = [self colourDistance:pixel andB:color];

                if (distance < tolerance) {
                    colorExists = true;

                    color.r = (int) ((color.r + pixel.r) / 2);
                    color.g = (int) ((color.g + pixel.g) / 2);
                    color.b = (int) ((color.b + pixel.b) / 2);
                    // color.d+= distance > 0 ? distance : 1;
                    color.d++;

                    break;
                }
            }

            if (!colorExists) [imageColors addObject:pixel];

        }
    }

    free(rawData);

    if (imageColors.count < 2) return [UIColor clearColor];

    NSArray *sorted = [[NSArray arrayWithArray:imageColors] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"d" ascending:false]]];

    RGBPixel *pixel1 = sorted[0];
    RGBPixel *pixel2 = sorted[1];

    CGFloat sat1, br1;
    UIColor *color1 = [UIColor colorWithRed:pixel1.r/255.0f green:pixel1.g/255.0f blue:pixel1.b/255.0f alpha:1.0f];
    [color1 getHue:nil saturation:&sat1 brightness:&br1 alpha:nil];

    if (pixel2.d > pixel1.d * 0.125) {
        CGFloat sat2, br2;
        UIColor *color2 = [UIColor colorWithRed:pixel2.r/255.0f green:pixel2.g/255.0f blue:pixel2.b/255.0f alpha:1.0f];
        [color2 getHue:nil saturation:&sat2 brightness:&br2 alpha:nil];

        if (sat2 + br2 * 0.5 > sat1 + br1 * 0.5) {
            return color2;
        }
    }

    return color1;
}

-(int)colourDistance:(RGBPixel *)a andB:(RGBPixel *)b {
    return abs(a.r-b.r)+abs(a.g-b.g)+abs(a.b-b.b);
}

- (UIColor *)velvetAverageColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                        green:((CGFloat)rgba[1])*multiplier
                        blue:((CGFloat)rgba[2])*multiplier
                        alpha:alpha];
    } else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                        green:((CGFloat)rgba[1])/255.0
                        blue:((CGFloat)rgba[2])/255.0
                        alpha:((CGFloat)rgba[3])/255.0];
    }
}
@end

@implementation UIColor (Velvet)
// Returns a value between 0 (black) and 1 (white)
- (CGFloat)velvetColorBrightness {
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    return ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
}
// Returns UIColor from hex string
+ (UIColor *)velvetColorFromHexString:(NSString *)string {
	if(string == nil || string.length == 0 || [string rangeOfString:@"#"].location != 0) {
        return nil;
    }

    CGFloat alpha = 1.0;
    NSUInteger location = [string rangeOfString:@":"].location;
    NSString *hexString;

    if(location != NSNotFound) {
        alpha = [[string substringFromIndex:(location + 1)] floatValue];
        hexString = [string substringWithRange:NSMakeRange(0, location)];
    } else {
        hexString = [string copy];
    }

    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];

    if([hexString rangeOfString:@"#"].location == 0) {
        [scanner setScanLocation:1];
    }

    [scanner scanHexInt:&rgbValue];

    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0
                    green:((rgbValue & 0xFF00) >> 8) / 255.0
                    blue:(rgbValue & 0xFF) / 255.0
                    alpha:alpha];
}
- (BOOL)velvetIsDarkColor {
    const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;

    return (colorBrightness < 0.6);
}
@end