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
@property (retain, nonatomic) UIView * colorIndicator;
@end

@interface VelvetIndicatorView : UIView
@end

@implementation VelvetIndicatorView
@end

%hook PLPlatterHeaderContentView
- (void)setIcons:(NSArray *)arg1 {
	%orig;

	VelvetIndicatorView *colorIndicator = nil;
	for (VelvetIndicatorView *subview in self.superview.subviews) {
		if ([subview isMemberOfClass:%c(VelvetIndicatorView)]) {
			colorIndicator = subview;
		}
	}

	if (colorIndicator) {
		UIImage *icon = arg1[0];
		colorIndicator.backgroundColor = [icon velvetDominantColor];
		// [colorIndicator setFrame:CGRectMake(0, 0, 5, self.superview.frame.size.height)];
	}
}
%end

%hook NCNotificationShortLookViewController
%property (retain, nonatomic) VelvetIndicatorView *colorIndicator;
- (void)viewDidLoad {
	%orig;

	self.colorIndicator = [[VelvetIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 359, 2)];
	[self.viewForPreview insertSubview:self.colorIndicator atIndex:1];

	self.viewForPreview.backgroundMaterialView.layer.cornerRadius = 0;
}
%end