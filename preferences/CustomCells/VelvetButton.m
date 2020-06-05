#include "../VelvetHeaders.h"

@implementation VelvetButton

-(void) layoutSubviews {
	[super layoutSubviews];

	self.textLabel.textColor = kVELVETCOLOR;
	self.textLabel.highlightedTextColor = kVELVETCOLOR;
}

@end
