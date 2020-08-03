#include "../VelvetHeaders.h"
#include "../../sources/ColorSupport.h"

@implementation VelvetColorPicker

-(NSString *)previewColor {
    VelvetPrefs *prefs = [VelvetPrefs sharedInstance];
    return [prefs valueForKey:[self.specifier propertyForKey:@"key"]];
}

-(void)createAccessoryView {
    _colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]];
    imageView.frame = _colorPreview.bounds;

    [_colorPreview addSubview:imageView];
}

-(void)dismissPicker {
    [super dismissPicker];
    [self._viewControllerForAncestor reloadSpecifiers];
}

-(void)updateCellDisplay {
    // Set necessary options for sparks colorpicker
    if ([self.options valueForKey:@"defaults"] == nil || [self.options valueForKey:@"fallback"] == nil) {
        [self.options setObject:@"com.initwithframe.velvet" forKey:@"defaults"];
        [self.options setObject:([self.specifier propertyForKey:@"default"] ?: @"#FFFFFF:1.00") forKey:@"fallback"];
    }

    [self.specifier setButtonAction:@selector(openColourPicker)];

    if (_colorPreview == nil) {
        [self createAccessoryView];
    }

    if (self.accessoryView != _colorPreview) {
        // Overwrite sparks colour preview with our custom one
        self.accessoryView = _colorPreview;
    }
   
   UIColor *color = [UIColor velvetColorFromHexString:[self previewColor]];
    if (color) {
        self.tintColor = color;
        _colorPreview.hidden = NO;
    } else {
        _colorPreview.hidden = YES;
    }
}

@end
