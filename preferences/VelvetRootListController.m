#include "VelvetHeaders.h"

@implementation VelvetRootListController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupHeader];
}

- (void)setupHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile: @"/Library/PreferenceBundles/Velvet.bundle/Images/velvet-header-icon.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, self.view.bounds.size.width, 80)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImage:image];

    [header addSubview:imageView];

    [self.table setTableHeaderView:header];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

@end
