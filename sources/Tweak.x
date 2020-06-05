#import "Headers.h"
#import "ColorSupport.h"

NSUserDefaults *preferences;

@implementation VelvetIndicatorView
@end

@implementation VelvetBackgroundView
@end

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
%property (retain, nonatomic) UIView * velvetBorder;
%property (retain, nonatomic) VelvetBackgroundView * velvetBackground;
%property (retain, nonatomic) UIImageView * imageIndicator;
- (void)layoutSubviews {
	%orig;
	CGRect frame = self.frame;
	self.velvetBackground.frame = frame;
}
- (CGSize)sizeThatFitsContentWithSize:(CGSize)arg1 {
    CGSize orig = %orig;
	if ([[preferences valueForKey:@"style"] isEqual:@"classic"] && [preferences boolForKey:@"colorHeader"]) {
    	orig.height += 10;
	}
    return orig;
}
%end

%hook NCNotificationShortLookViewController
- (void)viewDidLayoutSubviews {
	%orig;

	NCNotificationShortLookView *view = self.viewForPreview;

	// Notification view is not yet fully initialized
	if (view.frame.size.width == 0) return;

	float cornerRadius = getCornerRadius();
	if (cornerRadius < 0) cornerRadius = view.frame.size.height / 2;
	
	UIColor *dominantColor = [self getDominantColor];

	if (view.velvetBackground == nil) {
		VelvetBackgroundView *velvetBackground = [[VelvetBackgroundView alloc] initWithFrame:CGRectZero];
		velvetBackground.layer.cornerRadius = cornerRadius;
		velvetBackground.layer.continuousCorners = YES;
		velvetBackground.clipsToBounds = YES;

		[view insertSubview:velvetBackground atIndex:1];
		view.velvetBackground = velvetBackground;
	}

	if (view.colorIndicator == nil) {
		VelvetIndicatorView *colorIndicator = [[VelvetIndicatorView alloc] initWithFrame:CGRectZero];

		[view.velvetBackground insertSubview:colorIndicator atIndex:1];
		view.colorIndicator = colorIndicator;
	}

	if (view.velvetBorder == nil) {
		UIView *velvetBorder = [[UIView alloc] initWithFrame:CGRectZero];

		[view.velvetBackground insertSubview:velvetBorder atIndex:1];
		view.velvetBorder = velvetBorder;
	}

	if (view.imageIndicator == nil) {
		UIImageView *imageIndicator = [[UIImageView alloc] initWithFrame:CGRectZero];

		[view insertSubview:imageIndicator atIndex:3];
		view.imageIndicator = imageIndicator;
	}

	view.backgroundMaterialView.layer.cornerRadius = cornerRadius;
	UIView *stackDimmingView = [self.view valueForKey:@"_stackDimmingView"];
	stackDimmingView.layer.cornerRadius = cornerRadius;


	if ([[preferences valueForKey:@"style"] isEqual:@"modern"]) {
		[self velvetHideHeader];

		if ([[preferences valueForKey:@"indicatorModern"] isEqual:@"icon"]) {
			float size = [preferences integerForKey:@"indicatorModernSize"];
			view.imageIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);
			view.imageIndicator.image = [self getIconForBundleId:self.notificationRequest.sectionIdentifier];
		} else if ([[preferences valueForKey:@"indicatorModern"] isEqual:@"dot"]) {
			float size = [preferences integerForKey:@"indicatorModernSize"] / 2;
			view.colorIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);
			view.colorIndicator.layer.cornerRadius = size/2;
		} else if ([[preferences valueForKey:@"indicatorModern"] isEqual:@"triangle"]) {
			float size = [preferences integerForKey:@"indicatorModernSize"] / 2;
			view.colorIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);

			// Build a triangular path
			UIBezierPath *path = [UIBezierPath new];
			[path moveToPoint:(CGPoint){0, 0}];
			[path addLineToPoint:(CGPoint){size, size/2}];
			[path addLineToPoint:(CGPoint){0, size}];
			[path addLineToPoint:(CGPoint){0, 0}];

			// Create a CAShapeLayer with this triangular path
			CAShapeLayer *mask = [CAShapeLayer new];
			mask.frame = view.bounds;
			mask.path = path.CGPath;

			// Mask the view's layer with this shape
			view.colorIndicator.layer.mask = mask;
		} else if ([[preferences valueForKey:@"indicatorModern"] isEqual:@"line"]) {
			float width = 3;
			view.colorIndicator.frame = CGRectMake(20, 20, width, view.frame.size.height-40);
			view.colorIndicator.layer.cornerRadius = width/2;
			view.colorIndicator.layer.continuousCorners = YES;
		}
	} 

	if ([[preferences valueForKey:@"style"] isEqual:@"classic"]) {

		PLPlatterHeaderContentView *header = [self.viewForPreview valueForKey:@"_headerContentView"];

		if ([preferences boolForKey:@"colorHeader"]) {
			header.backgroundColor = [dominantColor colorWithAlphaComponent:0.8];

			// Move the header to the velvetBackground view so that it gets automatically cut off with higher cornerRadius settings
			[view.velvetBackground insertSubview:header atIndex:1];
		}

		if ([[preferences valueForKey:@"indicatorClassic"] isEqual:@"none"]) {
			((UIView *)header.iconButtons[0]).alpha = 0;
		} else if ([[preferences valueForKey:@"indicatorClassic"] isEqual:@"dot"]) {
			((UIView *)header.iconButtons[0]).alpha = 0;
			float size = 12;
			view.colorIndicator.frame = CGRectMake(14.5, 14.5, size, size);
			view.colorIndicator.layer.cornerRadius = size/2;
		} else if ([[preferences valueForKey:@"indicatorClassic"] isEqual:@"triangle"]) {
			((UIView *)header.iconButtons[0]).alpha = 0;
			float size = 12;
			view.colorIndicator.frame = CGRectMake(14.5, 14.5, size, size);

			// Build a triangular path
			UIBezierPath *path = [UIBezierPath new];
			[path moveToPoint:(CGPoint){0, 0}];
			[path addLineToPoint:(CGPoint){size, size/2}];
			[path addLineToPoint:(CGPoint){0, size}];
			[path addLineToPoint:(CGPoint){0, 0}];

			// Create a CAShapeLayer with this triangular path
			CAShapeLayer *mask = [CAShapeLayer new];
			mask.frame = view.bounds;
			mask.path = path.CGPath;

			// Mask the view's layer with this shape
			view.colorIndicator.layer.mask = mask;
		}
	}

	view.colorIndicator.backgroundColor = dominantColor;
	view.velvetBorder.backgroundColor = dominantColor;
	

	if ([preferences boolForKey:@"colorPrimaryLabel"]) {
		view.notificationContentView.primaryLabel.textColor = dominantColor;
	}

	if ([preferences boolForKey:@"colorSecondaryLabel"]) {
		view.notificationContentView.secondaryLabel.textColor = dominantColor;
	}

	if ([preferences boolForKey:@"colorBackground"]) {
		view.velvetBackground.backgroundColor = [dominantColor colorWithAlphaComponent:0.6];
	}

	if ([preferences boolForKey:@"hideBackground"]) {
		view.backgroundMaterialView.alpha = 0;
		[self velvetHideGroupedNotifications];
	}

	int borderWidth = [preferences integerForKey:@"borderWidth"];
	if ([[preferences valueForKey:@"border"] isEqual:@"all"]) {
		view.velvetBackground.layer.borderColor = dominantColor.CGColor;
		view.velvetBackground.layer.borderWidth = borderWidth;
	} else if ([[preferences valueForKey:@"border"] isEqual:@"top"]) {
		view.velvetBorder.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
	} else if ([[preferences valueForKey:@"border"] isEqual:@"right"]) {
		view.velvetBorder.frame = CGRectMake(view.frame.size.width - borderWidth, 0, borderWidth, view.frame.size.height);
	} else if ([[preferences valueForKey:@"border"] isEqual:@"bottom"]) {
		view.velvetBorder.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, borderWidth);
	} else if ([[preferences valueForKey:@"border"] isEqual:@"left"]) {
		view.velvetBorder.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
	}

}

%new
-(void)velvetHideHeader {
	PLPlatterHeaderContentView *header = [self.viewForPreview valueForKey:@"_headerContentView"];

	for (UIView *subview in header.subviews) {
		if ([subview isKindOfClass:%c(UIButton)]) {
			// hide icon
			subview.hidden = YES;
		}
	}

	header.titleLabel.hidden = YES;
}

%new
-(void)velvetHideGroupedNotifications {
	if (self.associatedView) {
		NCNotificationListCell *cell = (NCNotificationListCell *)self.associatedView;
		NCNotificationListView *listView = (NCNotificationListView *)cell.superview;

		NCNotificationListCell *frontCell = [listView _visibleViewAtIndex:0];
		for (UIView *subview in listView.subviews) {
			if (subview != frontCell && [subview isKindOfClass:%c(NCNotificationListCell)]) subview.hidden = listView.grouped;
		}
	}
}

%new
-(UIColor *)getDominantColor {

	NSString *bundleId = nil;

	if (self.associatedView) {
		// This could be one of those pseudo notifications that are empty, so we have to find the first actual notification in the list to get the color
		NCNotificationListCell *cell = (NCNotificationListCell *)self.associatedView;
		NCNotificationListView *listView = (NCNotificationListView *)cell.superview;

		NCNotificationListCell *frontCell = [listView _visibleViewAtIndex:0];
		NCNotificationViewControllerView *frontView = [frontCell _notificationCellView];
		NCNotificationShortLookView *shortLookView = (NCNotificationShortLookView *)frontView.contentView;

		NCNotificationShortLookViewController *controller = shortLookView._viewControllerForAncestor;
		bundleId = controller.notificationRequest.sectionIdentifier;
	} else {
		// This is a single notification, we can safely use our own bundleId
		bundleId = self.notificationRequest.sectionIdentifier;
	}

	UIImage *icon = [self getIconForBundleId:bundleId];
	return [icon velvetDominantColor];
}

%new
-(UIImage *)getIconForBundleId:(NSString *)bundleId {
	UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:bundleId format:2 scale:[UIScreen mainScreen].scale];

	if (!icon) {
		// Fallback to the default 20x20 icon
		icon = self.viewForPreview.icons[0];
	}

	return icon;
}
%end

%hook BSUIDefaultDateLabel
-(void)setFrame:(CGRect)frame {
	// Move the dateLabel into the corner to make room for the centered notification text
	if ([[preferences valueForKey:@"style"] isEqual:@"modern"]) {
		if (self.superview.frame.size.width > 0) {
			frame.origin.y -= 3;
		}
	}

	%orig;
}
%end

%hook PLPlatterHeaderContentView
- (CGFloat)_iconTrailingPadding {
	return [[preferences valueForKey:@"indicatorClassic"] isEqual:@"none"] ? -18 : %orig;
}
%end

%hook PLTitledPlatterView
- (CGRect)_mainContentFrame {
	// needed because else the frame of it cuts of the content after adjustment
	self.customContentView.clipsToBounds = NO;

	CGRect frame = %orig;

	if ([[preferences valueForKey:@"style"] isEqual:@"modern"]) {
		frame.origin.y = frame.origin.y - 14;
		frame.origin.x = frame.origin.x + getIndicatorOffset();
	}

	if ([[preferences valueForKey:@"style"] isEqual:@"classic"] && [preferences boolForKey:@"colorHeader"]) {
		frame.origin.y = frame.origin.y + 10;
	}
	
	return frame;
}
%end

%hook NCNotificationContentView
- (void)layoutSubviews {
	%orig;

	CGRect primaryLabelFrame = self.primaryLabel.frame;
	CGRect secondaryLabelFrame = self.secondaryLabel.frame;

	CGFloat labelWidth = getIndicatorOffset();

	primaryLabelFrame.size.width = self.primaryLabel.frame.size.width - labelWidth;
	secondaryLabelFrame.size.width = self.secondaryLabel.frame.size.width - labelWidth;

	self.primaryLabel.frame = primaryLabelFrame;
	self.secondaryLabel.frame = secondaryLabelFrame;

	// Moves the image preview to the correct place
	UIImageView *thumbnail = [self safeValueForKey:@"_thumbnailImageView"];
	if (thumbnail) {
		CGRect thumbFrame = thumbnail.frame;
		thumbFrame.origin.x = thumbFrame.origin.x - labelWidth;
		thumbnail.frame = thumbFrame;
	}
}
%end

// This is the view that occasionally asks "Do you want to keep receiving notifications from this app?"
%hook NCAuxiliaryOptionsView
-(void)layoutSubviews {
	CGRect auxFrame = self.frame;

	if (auxFrame.size.width <= 0) return;
	
	auxFrame.size.width = auxFrame.size.width - getIndicatorOffset();
	self.frame = auxFrame;

	float cornerRadius = getCornerRadius();
	if (cornerRadius < 0) cornerRadius = self.frame.size.height / 2;

	UIView *overlayView = [self safeValueForKey:@"_overlayView"];
	overlayView.layer.cornerRadius = cornerRadius;	
	
	%orig;
}

%end

// TODO: Fix this, as it makes notifications with no background but enabled border overlap each other
// %hook NCNotificationListView
// - (CGSize)sizeThatFits:(CGSize)arg1 {
//     CGSize orig = %orig;

// 	if ([preferences boolForKey:@"hideBackground"]) {
// 		orig.height -= 20;
// 	}

//     return orig;
// }
// %end

static float getCornerRadius() {
	if ([[preferences valueForKey:@"roundedCorners"] isEqual:@"none"]) {
		return 0;
	} else if ([[preferences valueForKey:@"roundedCorners"] isEqual:@"round"]) {
		return -1;
	} else if ([[preferences valueForKey:@"roundedCorners"] isEqual:@"custom"]) {
		return [preferences floatForKey:@"customCornerRadius"];
	}

	return 13; // stock
}

static float getIndicatorOffset() {
	float offset = 0;

	if ([[preferences valueForKey:@"style"] isEqual:@"modern"]) {
		if ([[preferences valueForKey:@"indicatorModern"] isEqual:@"icon"]) {
			offset = ([preferences integerForKey:@"indicatorModernSize"] + 21);
		} else if ([[preferences valueForKey:@"indicatorModern"] isEqual:@"dot"] || [[preferences valueForKey:@"indicatorModern"] isEqual:@"triangle"]) {
			offset = ([preferences integerForKey:@"indicatorModernSize"] / 2) + 21;
		} else if ([[preferences valueForKey:@"indicatorModern"] isEqual:@"line"]) {
			offset = 25;
		} else {
			offset = 5;
		}
	}

	return offset;
}

%ctor {
	preferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.initwithframe.velvet"];

	[preferences registerDefaults:@{
		@"enabled": @YES,

		@"style": @"modern",
		@"indicatorClassic": @"icon",
		@"indicatorModern": @"icon",
		@"indicatorModernSize": @32,
		@"colorHeader": @NO,

		@"hideBackground": @NO,
		@"colorBackground": @NO,
		@"colorPrimaryLabel": @NO,
		@"colorSecondaryLabel": @NO,

		@"border": @"none",
		@"borderWidth": @2,

		@"roundedCorners": @"stock",
		@"customCornerRadius": @13,
	}];

	if (![preferences boolForKey:@"enabled"]) return;

	%init;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Home"
                                                           message:@"Would you like to turn the lights on?"
                                                           bundleID:@"com.apple.Home"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Instagram"
                                                           message:@"Somebody liked your post."
                                                           bundleID:@"com.burbn.instagram"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"iTunes Store"
                                                           message:@"Your favourite artist released a new track! ngl this is long"
                                                           bundleID:@"com.apple.MobileStore"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Twitter"
                                                           message:@"I wonder if this ever will be released."
                                                           bundleID:@"com.atebits.Tweetie2"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"YouTube"
                                                           message:@"PewDiePie uploaded a new video."
                                                           bundleID:@"com.google.ios.youtube"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Bill Gates"
                                                           message:@"ETA?!"
                                                           bundleID:@"com.apple.MobileSMS"];

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Bill Gates"
                                                           message:@"Are you still working on that new tweak?"
                                                           bundleID:@"com.apple.MobileSMS"];
	});
}