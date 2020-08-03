#include "../VelvetHeaders.h"

@implementation VelvetColorListSelector

-(void)didMoveToWindow {
	[super didMoveToWindow];

    VelvetPrefs *prefs = [VelvetPrefs sharedInstance];
    NSString *currentValue = [prefs valueForKey:[self.specifier propertyForKey:@"key"]];

    if ([currentValue isEqual:@"none"]) {
        self.detailTextLabel.text = @"Default";
    } else if ([currentValue isEqual:@"dominant"]) {
        self.detailTextLabel.text = @"Automatic";
    } else {
        self.detailTextLabel.text = @"Custom";
    }

}

@end
