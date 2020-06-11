#include "VelvetHeaders.h"

@implementation VelvetRootListController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupHeader];
    [self setupFooter];
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

-(void)setupFooter {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSPipe *pipe = [NSPipe pipe];

			NSTask *task = [[NSTask alloc] init];
			task.arguments = @[@"-c", @"dpkg -s com.initwithframe.velvet | grep -i version | cut -d' ' -f2"];
			task.launchPath = @"/bin/sh";
			[task setStandardOutput: pipe];
			[task launch];
			[task waitUntilExit];

			NSFileHandle *file = [pipe fileHandleForReading];
			NSData *output = [file readDataToEndOfFile];
			NSString *outputString = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
			outputString = [outputString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
			[file closeFile];

			dispatch_async(dispatch_get_main_queue(), ^(void){
				// Update specifier on the main queue
				if ([outputString length] > 0) {
					PSSpecifier *spec = [self specifierForID:@"footerVersion"];
					[spec setProperty:[NSString stringWithFormat:@"Velvet %@ - initWithFrame", outputString] forKey:@"footerText"];
					[self reloadSpecifierID:@"footerVersion" animated:NO];
				}
			});
		});
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSMutableArray *mutableSpecifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] mutableCopy];

		_specifiers = mutableSpecifiers;
	}

	return _specifiers;
}

@end
