#include "../VelvetHeaders.h"

@implementation VelvetColorListCell

-(void) didMoveToWindow {
	[super didMoveToWindow];

	self.textLabel.textColor = UIColor.labelColor;
	self.textLabel.highlightedTextColor = UIColor.labelColor;

    if ([self.specifier propertyForKey:@"isActive"]) {
        [self setAccessoryType:UITableViewCellAccessoryCheckmark];
        self.tintColor = kVELVETCOLOR;
    }
}

@end
