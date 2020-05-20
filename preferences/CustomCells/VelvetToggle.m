#include "../VelvetHeaders.h"

@implementation VelvetToggle

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) [((UISwitch *)[self control]) setOnTintColor:kVELVETCOLOR];

	return self;
}

@end
