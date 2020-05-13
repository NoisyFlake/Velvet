#import "ColorSupport.h"

@interface PLPlatterHeaderContentView : UIView
@end

@interface MTMaterialView : UIView
@end

@interface MTPlatterView : UIView
@property (nonatomic,readonly) MTMaterialView * backgroundMaterialView;
@end

@interface MTTitledPlatterView : MTPlatterView
@end

@interface NCNotificationShortLookView : MTTitledPlatterView
@end

@interface NCNotificationViewController : UIViewController
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@property (nonatomic,readonly) NCNotificationShortLookView * viewForPreview;
@end

%hook PLPlatterHeaderContentView
-(void)setIcons:(NSArray *)arg1 {
	%orig;

	UIView *headerLine = nil;
	for (UIView *subview in self.superview.subviews) {
		if ([subview isMemberOfClass:%c(UIView)]) {
			headerLine = subview;
		}
	}

	if (headerLine) {
		UIImage *icon = arg1[0];
		headerLine.backgroundColor = [icon velvetDominantColor];
	}
}
%end

%hook NCNotificationShortLookViewController
- (void)viewDidLoad {
	%orig;

	UIView *headerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 359, 2)];
	[self.viewForPreview insertSubview:headerLine atIndex:1];

	self.viewForPreview.backgroundMaterialView.layer.cornerRadius = 0;
}
%end