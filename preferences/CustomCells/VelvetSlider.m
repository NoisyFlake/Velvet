#include "../VelvetHeaders.h"

@implementation VelvetSlider

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		[((PSSegmentableSlider *)[self control]) setMinimumTrackTintColor:kVELVETCOLOR];
	}

	return self;
}

@end