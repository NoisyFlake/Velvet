#include "VelvetHeaders.h"
#include <objc/runtime.h>
#import <spawn.h>

@implementation VelvetBaseController

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	self.navigationItem.navigationBar.tintColor = kVELVETCOLOR;

	UITableView *table = [self valueForKey:@"_table"];
	table.separatorStyle = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMemberOfClass:[VelvetRootListController class]] && self.navigationController.viewControllers.count == 1) {
		// Remove the navigationBar tintColor as the user is about to leave our settings area
		self.navigationItem.navigationBar.tintColor = nil;
	}
}

-(UITableViewStyle)tableViewStyle {
	return (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) ? 2 : [super tableViewStyle];
}

-(VelvetPrefs *)preferences {
	return [VelvetPrefs sharedInstance];
}

-(void)respring {
	[self.view endEditing:YES];

	pid_t pid;
	const char* args[] = {"sbreload", NULL};
	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
}

-(void)setWithRespring:(id)value specifier:(PSSpecifier *)specifier {
	[self setPreferenceValue:value specifier:specifier];

	UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Respring required" message:@"Changing this option requires a respring. Do you want to respring now?" preferredStyle:UIAlertControllerStyleAlert];

	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		 [self respring];
	}]];

	[alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

@end
