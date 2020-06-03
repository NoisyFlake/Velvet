#import "Headers.h"
#import "ColorSupport.h"

NSUserDefaults *preferences;

int style = 0;

BOOL useFirstLineAsTitle = NO;
BOOL useKalmColor = NO;

float iconSize = 32; // 24, 32, 40, 48 are good options

@implementation VelvetIndicatorView
@end

@implementation VelvetBackgroundView
@end

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
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
	
	UIColor *dominantColor;
	UIColor *kalmColor = [%c(KalmAPI) getColor];

	if (useKalmColor && kalmColor != nil) {
		dominantColor = kalmColor;
	} else {
		dominantColor = [self getDominantColor];
	}

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

	if (view.imageIndicator == nil) {
		UIImageView *imageIndicator = [[UIImageView alloc] initWithFrame:CGRectZero];

		[view insertSubview:imageIndicator atIndex:3];
		view.imageIndicator = imageIndicator;
	}

	view.backgroundMaterialView.layer.cornerRadius = cornerRadius;
	UIView *stackDimmingView = [self.view valueForKey:@"_stackDimmingView"];
	stackDimmingView.layer.cornerRadius = cornerRadius;

	switch (style) {
        case 1: { // full bar bottom
			view.colorIndicator.frame = CGRectMake(0, 0, view.frame.size.width, 4);
		} break;
        case 2: { // full bar left
			view.colorIndicator.frame = CGRectMake(0, 0, 4, view.frame.size.height);
		} break;
        case 3: { // rounded bar left
			float width = 3;
			view.colorIndicator.frame = CGRectMake(20, 20, width, view.frame.size.height-40);
			view.colorIndicator.layer.cornerRadius = width/2;
			view.colorIndicator.layer.continuousCorners = YES;
		} break;
        case 4: { // circle left
			float size = 12;
			view.colorIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);
			view.colorIndicator.layer.cornerRadius = size/2;
			view.colorIndicator.layer.continuousCorners = YES;
		} break;
        case 5: { // icon left
			view.imageIndicator.frame = CGRectMake(20, (view.frame.size.height - iconSize)/2, iconSize, iconSize);
			view.imageIndicator.image = [self getIconForBundleId:self.notificationRequest.sectionIdentifier];
		} break;
	}

	if ([[preferences valueForKey:@"style"] isEqual:@"modern"]) {
		[self velvetHideHeader];
	} 

	if ([[preferences valueForKey:@"style"] isEqual:@"classic"] && [preferences boolForKey:@"colorHeader"]) {
		PLPlatterHeaderContentView *header = [self.viewForPreview valueForKey:@"_headerContentView"];
		// header.layer.cornerRadius = cornerRadius;
		header.layer.continuousCorners = YES;
		header.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;

		header.backgroundColor = [dominantColor colorWithAlphaComponent:0.8];

		// Move the header to the velvetBackground view so that it gets automatically cut off with higher cornerRadius settings
		[view.velvetBackground insertSubview:header atIndex:1];

	}

	view.colorIndicator.backgroundColor = dominantColor;

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

	if ([preferences boolForKey:@"colorBorder"]) {
		view.velvetBackground.layer.borderColor = dominantColor.CGColor;
		view.velvetBackground.layer.borderWidth = 2;
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
			if (![preferences boolForKey:@"colorBorder"]) {
				frame.origin.x += 4;
			}
		}
	}

	%orig;
}
%end

%hook PLTitledPlatterView
- (CGRect)_mainContentFrame {
	// needed because else the frame of it cuts of the content after adjustment
	self.customContentView.clipsToBounds = NO;

	CGRect frame = %orig;

	if ([[preferences valueForKey:@"style"] isEqual:@"modern"]) {
		frame.origin.y = frame.origin.y - 14;
	}

	if ([[preferences valueForKey:@"style"] isEqual:@"classic"] && [preferences boolForKey:@"colorHeader"]) {
		frame.origin.y = frame.origin.y + 10;
	}
	
	if (style == 3) {
		frame.origin.x = frame.origin.x + 25;
	}
	if (style == 4) {
		frame.origin.x = frame.origin.x + 32;
	}
	if (style == 5) {
		frame.origin.x = frame.origin.x + (iconSize + 21);
	}
	
	return frame;
}
%end

%hook NCNotificationContentView
- (void)layoutSubviews {
	%orig;

	// If it's a multi-line message with no title, set the first line as title so it's emphasized
	if (useFirstLineAsTitle && self.primaryLabel.text == nil && self.secondaryLabel.text) {
		NSMutableArray *lines = [[self.secondaryLabel.text componentsSeparatedByString:@"\n"] mutableCopy];
		if ([lines count] > 1) {
			self.primaryLabel.text = lines[0];
			[lines removeObjectAtIndex:0];
			self.secondaryLabel.text = [lines componentsJoinedByString:@"\n"];
		}
	}

	CGRect primaryLabelFrame = self.primaryLabel.frame;
	CGRect secondaryLabelFrame = self.secondaryLabel.frame;

	CGFloat labelWidth;
	CGFloat extra = [preferences boolForKey:@"colorBorder"] ? 5 : 0;

	if (style == 3) {
		labelWidth = 25;
	}
	if (style == 4) {
		labelWidth = 32;
	}
	if (style == 5) {
		labelWidth = (iconSize + 21);
	}

	primaryLabelFrame.size.width = self.primaryLabel.frame.size.width - labelWidth - extra;
	secondaryLabelFrame.size.width = self.secondaryLabel.frame.size.width - labelWidth - extra;

	self.primaryLabel.frame = primaryLabelFrame;
	self.secondaryLabel.frame = secondaryLabelFrame;

	// Moves the image preview to the correct place
	UIImageView *thumbnail = [self safeValueForKey:@"_thumbnailImageView"];
	if (thumbnail) {
		CGRect thumbFrame = thumbnail.frame;
		thumbFrame.origin.x = thumbFrame.origin.x - labelWidth - extra;
		thumbnail.frame = thumbFrame;
	}
}
%end

// This is the view that occasionally asks "Do you want to keep receiving notifications from this app?"
%hook NCAuxiliaryOptionsView
-(void)layoutSubviews {
	CGRect auxFrame = self.frame;

	if (auxFrame.size.width <= 0) return;
	
	CGFloat labelWidth;
	CGFloat extra = [preferences boolForKey:@"colorBorder"] ? 5 : 0;

	if (style == 3) {
		labelWidth = 25;
	}
	if (style == 4) {
		labelWidth = 32;
	}
	if (style == 5) {
		labelWidth = (iconSize + 21);
	}
	
	auxFrame.size.width = auxFrame.size.width - labelWidth - extra;
	self.frame = auxFrame;

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

%ctor {
	preferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.initwithframe.velvet"];

	[preferences registerDefaults:@{
		@"enabled": @YES,
		@"style": @"modern",
		@"colorHeader": @NO,
		@"hideBackground": @NO,
		@"colorBackground": @NO,
		@"colorBorder": @NO,
		@"colorPrimaryLabel": @NO,
		@"colorSecondaryLabel": @NO,
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