#include "VelvetHeaders.h"

@implementation VelvetListItemsController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UITableView *table = [self valueForKey:@"_table"];
	table.separatorStyle = 0;
    table.tintColor = kVELVETCOLOR;
}

-(long long)tableViewStyle {
	return (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) ? 2 : [super tableViewStyle];
}

@end