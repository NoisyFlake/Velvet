#include "VelvetHeaders.h"
#include <objc/runtime.h>

@implementation VelvetBaseController

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	self.navigationItem.navigationBar.tintColor = kVELVETCOLOR;
	
	UITableView *table = [self valueForKey:@"_table"]; //self.view.subviews[0];
	table.separatorStyle = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMemberOfClass:[VelvetRootListController class]] && self.navigationController.viewControllers.count == 1) {
		// Remove the navigationBar tintColor as the user is about to leave our settings area
		self.navigationItem.navigationBar.tintColor = nil;
	}
}

-(long long)tableViewStyle {
	return (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) ? 2 : [super tableViewStyle];
}

@end
