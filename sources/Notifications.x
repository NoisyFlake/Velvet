#import "Headers.h"
#import "Notifications.h"
#import "VelvetPrefs.h"
#import "ColorSupport.h"

BOOL showCustomMessages = NO;
BOOL isTesting;

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
%property (retain, nonatomic) UIView * velvetBorder;
%property (retain, nonatomic) VelvetBackgroundView * velvetBackground;
%property (retain, nonatomic) UIImageView * imageIndicator;
- (void)layoutSubviews {
	%orig;

	ifDisabled(self) return;

	CGRect frame = self.frame;
	self.velvetBackground.frame = frame;
}
- (CGSize)sizeThatFitsContentWithSize:(CGSize)arg1 {
	ifDisabled(self) return %orig;

    CGSize orig = %orig;

	if ([[preferences valueForKey:getPreferencesKeyFor(@"style", self)] isEqual:@"classic"] && ![[preferences valueForKey:getPreferencesKeyFor(@"colorHeader", self)] isEqual:@"none"]) {
    	orig.height += 10;
	}
    return orig;
}
%end

%hook NCNotificationShortLookViewController
- (void)viewDidLayoutSubviews {
	%orig;

	NCNotificationShortLookView *view = self.viewForPreview;

	ifDisabled(view) return;

	// Notification view is not yet fully initialized
	if (view.frame.size.width == 0) return;

	float cornerRadius = getCornerRadius(view);
	if (cornerRadius < 0) cornerRadius = view.frame.size.height / 2;

	UIColor *dominantColor = [self getDominantColor];

	if (view.velvetBackground == nil) {
		VelvetBackgroundView *velvetBackground = [[VelvetBackgroundView alloc] initWithFrame:CGRectZero];
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
	view.velvetBackground.layer.cornerRadius = cornerRadius;

	// Hide and reset everything so we can set it up from scratch in the next steps
	view.imageIndicator.hidden = YES;
	view.velvetBorder.hidden = YES;
	view.colorIndicator.hidden = YES;
	view.colorIndicator.layer.cornerRadius = 0;
	view.colorIndicator.layer.mask = nil;
	view.velvetBackground.layer.borderWidth = 0;
	view.layer.shadowRadius = 0;

	UIImageView *thumbnail = [view.notificationContentView safeValueForKey:@"_thumbnailImageView"];
	if (thumbnail) thumbnail.alpha = 1;

	PLPlatterHeaderContentView *header = [self.viewForPreview valueForKey:@"_headerContentView"];
	if (header) {
		header.backgroundColor = nil;

		// Actually we'd have to restore the filter we delete later, but currently there is no known way to do this. If people ask, tell them to respring to get back to default.
		header.titleLabel.textColor = UIColor.labelColor;
		header.dateLabel.textColor = UIColor.labelColor;
	}

	PLShadowView *shadowView = [self.viewForPreview valueForKey:@"_shadowView"];
	if (shadowView) {
		if (cornerRadius > 13) {
			shadowView.hidden = YES;
			view.layer.shadowOffset = CGSizeMake(0, 3);
    		view.layer.shadowRadius = 5;
        	view.layer.shadowOpacity = 0.075;
		} else {
			shadowView.hidden = NO;
		}
	}

	if ([[preferences valueForKey:getPreferencesKeyFor(@"style", view)] isEqual:@"modern"]) {
		[self velvetHideHeader:YES];

		if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorModern", view)] isEqual:@"icon"]) {
			view.imageIndicator.hidden = NO;

			float size = [preferences integerForKey:getPreferencesKeyFor(@"indicatorModernSize", view)];

			if (isRTL()) {
				view.imageIndicator.frame = CGRectMake(view.frame.size.width - size - 20, (view.frame.size.height - size)/2, size, size);
			} else {
				view.imageIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);
			}

			if ([self.notificationRequest.sectionIdentifier isEqual:@"com.apple.donotdisturb"]) {
				view.imageIndicator.image = [UIImage systemImageNamed:self.notificationRequest.content.attachmentImage.imageAsset.assetName];
				view.imageIndicator.tintColor = UIColor.labelColor;
				thumbnail.alpha = 0;
			} else {
				if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorRoundedCorner", view)] isEqual:@"stock"]) {
					view.imageIndicator.image = [self getIconForBundleId:self.notificationRequest.sectionIdentifier withMask:YES];
					view.imageIndicator.clipsToBounds = NO;
				} else {
					view.imageIndicator.image = [self getIconForBundleId:self.notificationRequest.sectionIdentifier withMask:NO];
					float cornerRadius = getAppIconCornerRadius(view);
					if (cornerRadius < 0 || cornerRadius > size / 2) cornerRadius = size / 2;
					view.imageIndicator.layer.cornerRadius = cornerRadius;
					view.imageIndicator.clipsToBounds = YES;
				}
			}
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorModern", view)] isEqual:@"dot"]) {
			view.colorIndicator.hidden = NO;

			float size = [preferences integerForKey:getPreferencesKeyFor(@"indicatorModernSize", view)] / 2;

			if (isRTL()) {
				view.colorIndicator.frame = CGRectMake(view.frame.size.width - size - 20, (view.frame.size.height - size)/2, size, size);
			} else {
				view.colorIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);
			}

			view.colorIndicator.layer.cornerRadius = size/2;
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorModern", view)] isEqual:@"triangle"]) {
			view.colorIndicator.hidden = NO;

			float size = [preferences integerForKey:getPreferencesKeyFor(@"indicatorModernSize", view)] / 2;

			if (isRTL()) {
				view.colorIndicator.frame = CGRectMake(view.frame.size.width - size - 20, (view.frame.size.height - size)/2, size, size);
			} else {
				view.colorIndicator.frame = CGRectMake(20, (view.frame.size.height - size)/2, size, size);
			}

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
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorModern", view)] isEqual:@"line"]) {
			view.colorIndicator.hidden = NO;

			float width = 3;
			if (isRTL()) {
				view.colorIndicator.frame = CGRectMake(view.frame.size.width - width - 20, 20, width, view.frame.size.height-40);
			} else {
				view.colorIndicator.frame = CGRectMake(20, 20, width, view.frame.size.height-40);
			}
			view.colorIndicator.layer.cornerRadius = width/2;
			view.colorIndicator.layer.continuousCorners = YES;
		}

		NSString *indicatorColor = getColorFor(@"indicatorModernColor", view);
		if (indicatorColor) view.colorIndicator.backgroundColor = [indicatorColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:indicatorColor];

	} else if ([[preferences valueForKey:getPreferencesKeyFor(@"style", view)] isEqual:@"classic"]) {
		[self velvetHideHeader:NO];

		NSString *headerTitleColor = getColorFor(@"colorHeaderTitle", view);
		if (headerTitleColor) {
			header.titleLabel.layer.filters = nil;
			header.titleLabel.textColor = [headerTitleColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:headerTitleColor];
		}

		NSString *headerColor = getColorFor(@"colorHeader", view);
		if (headerColor) {
			header.backgroundColor = [headerColor isEqual:@"dominant"] ? [dominantColor colorWithAlphaComponent:0.8] : [UIColor velvetColorFromHexString:headerColor];

			// Move the header to the velvetBackground view so that it gets automatically cut off with higher cornerRadius settings
			[view.velvetBackground insertSubview:header atIndex:1];
		}

		// Hide the icon
		((UIView *)header.iconButtons[0]).alpha = 0;

		if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorClassic", view)] isEqual:@"dot"]) {
			view.colorIndicator.hidden = NO;

			float size = 12;
			view.colorIndicator.frame = CGRectMake(14.5, 14.5, size, size);
			view.colorIndicator.layer.cornerRadius = size/2;
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorClassic", view)] isEqual:@"triangle"]) {
			view.colorIndicator.hidden = NO;

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
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorClassic", view)] isEqual:@"icon"]) {
			((UIView *)header.iconButtons[0]).alpha = 1;
		}

		NSString *indicatorColor = getColorFor(@"indicatorClassicColor", view);
		if (indicatorColor) view.colorIndicator.backgroundColor = [indicatorColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:indicatorColor];
	}

	NSString *titleColor = getColorFor(@"colorPrimaryLabel", view);
	if (titleColor) {
		view.notificationContentView.primaryLabel.textColor = [titleColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:titleColor];
	} else {
		view.notificationContentView.primaryLabel.textColor = nil;
	}

	NSString *messageColor = getColorFor(@"colorSecondaryLabel", view);
	if (messageColor) {
		view.notificationContentView.secondaryLabel.textColor = [messageColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:messageColor];
		view.notificationContentView.summaryLabel.textColor = view.notificationContentView.secondaryLabel.textColor;
	} else {
		view.notificationContentView.secondaryLabel.textColor = nil;
		view.notificationContentView.summaryLabel.textColor = nil;
	}

	NSString *headerDateColor = getColorFor(@"colorHeaderDate", view);
	if (headerDateColor) {
		// Yup, this is necessary as sometimes when receiving lockscreen notifications, dateLabel isn't initialized yet. Stupid iOS.
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			header.dateLabel.layer.filters = nil;
			header.dateLabel.textColor = [headerDateColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:headerDateColor];
		});
	}

	NSString *backgroundColor = getColorFor(@"colorBackground", view);
	if (backgroundColor) {
		view.velvetBackground.backgroundColor = [backgroundColor isEqual:@"dominant"] ? [dominantColor colorWithAlphaComponent:0.6] : [UIColor velvetColorFromHexString:backgroundColor];

		// Hide background
		if ([backgroundColor containsString:@"0.00"]) {
			view.backgroundMaterialView.alpha = 0;
			[self velvetHideGroupedNotifications:YES];
		} else {
			view.backgroundMaterialView.alpha = 1;
			[self velvetHideGroupedNotifications:NO];
		}
	} else {
		view.velvetBackground.backgroundColor = nil;
		view.backgroundMaterialView.alpha = 1;
		[self velvetHideGroupedNotifications:NO];
	}

	NSString *borderColor = getColorFor(@"borderColor", view);
	view.velvetBorder.backgroundColor = [borderColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:borderColor];

	if (borderColor) {
		int borderWidth = [preferences integerForKey:getPreferencesKeyFor(@"borderWidth", view)];
		if ([[preferences valueForKey:getPreferencesKeyFor(@"borderPosition", view)] isEqual:@"all"]) {
			view.velvetBackground.layer.borderColor = [borderColor isEqual:@"dominant"] ? dominantColor.CGColor : [UIColor velvetColorFromHexString:borderColor].CGColor;
			view.velvetBackground.layer.borderWidth = borderWidth;
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"borderPosition", view)] isEqual:@"top"]) {
			view.velvetBorder.hidden = NO;
			view.velvetBorder.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"borderPosition", view)] isEqual:@"right"]) {
			view.velvetBorder.hidden = NO;
			view.velvetBorder.frame = CGRectMake(view.frame.size.width - borderWidth, 0, borderWidth, view.frame.size.height);
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"borderPosition", view)] isEqual:@"bottom"]) {
			view.velvetBorder.hidden = NO;
			view.velvetBorder.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, borderWidth);
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"borderPosition", view)] isEqual:@"left"]) {
			view.velvetBorder.hidden = NO;
			view.velvetBorder.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
		}
	}

	if ([self.notificationRequest.sectionIdentifier containsString:@"com.laughingquoll.maple"]) {
		view.colorIndicator.hidden = YES;
		view.imageIndicator.hidden = YES;
	}

}

%new
-(void)velvetHideHeader:(BOOL)hidden {
	PLPlatterHeaderContentView *header = [self.viewForPreview valueForKey:@"_headerContentView"];

	for (UIView *subview in header.subviews) {
		if ([subview isKindOfClass:%c(UIButton)]) {
			// hide icon
			subview.hidden = hidden;
		}
	}

	header.titleLabel.hidden = hidden;
}

%new
-(void)velvetHideGroupedNotifications:(BOOL)hidden {
	if (self.associatedView) {
		NCNotificationListCell *cell = (NCNotificationListCell *)self.associatedView;
		NCNotificationListView *listView = (NCNotificationListView *)cell.superview;

		NCNotificationListCell *frontCell = [listView _visibleViewAtIndex:0];
		for (UIView *subview in listView.subviews) {
			if ([subview isKindOfClass:%c(NCNotificationListCell)]) {
				subview.hidden = subview != frontCell && listView.grouped && hidden;
			}
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

	if ([bundleId isEqual:@"com.apple.donotdisturb"]) return nil;

	UIImage *icon = [self getIconForBundleId:bundleId withMask:NO];

	NSString *iconIdentifier = [UIImagePNGRepresentation(icon) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
	UIColor *color = colorCache[iconIdentifier];

	if (iconIdentifier != nil && color == nil) {
		color = [icon velvetDominantColor];
		[colorCache setObject:color forKey:iconIdentifier];
	}

	return color;
}

%new
-(UIImage *)getIconForBundleId:(NSString *)bundleId withMask:(BOOL)isMasked {
	UIImage *icon = nil;

	if (bundleId != nil) {
		// icon = [UIImage _applicationIconImageForBundleIdentifier:bundleId format:2 scale:[UIScreen mainScreen].scale];
		SBIconController *iconController = [%c(SBIconController) sharedInstance];
		SBIcon *sbIcon = [iconController.model expectedIconForDisplayIdentifier:bundleId];

		struct CGSize imageSize;
		imageSize.height = 60;
		imageSize.width = 60;

		struct SBIconImageInfo imageInfo;
		imageInfo.size  = imageSize;
		imageInfo.scale = [UIScreen mainScreen].scale;
		imageInfo.continuousCornerRadius = 13; // This actually doesn't do anything

		if (isMasked) {
			icon = [sbIcon generateIconImageWithInfo:imageInfo];
		} else {
			icon = [sbIcon unmaskedIconImageWithInfo:imageInfo];
		}
	}

	if (!icon) {
		// Fallback to the default 20x20 icon
		icon = self.viewForPreview.icons[0];
	}

	return icon;
}
%end

%hook BSUIDefaultDateLabel
-(void)setFrame:(CGRect)frame {
	ifDisabled(self) {
		%orig;
		return;
	}

	// Move the dateLabel into the corner to make room for the centered notification text
	if ([[preferences valueForKey:getPreferencesKeyFor(@"style", self)] isEqual:@"modern"]) {
		if (self.superview.frame.size.width > 0) {
			frame.origin.y -= 3;
		}
	}

	%orig;
}
%end

%hook PLPlatterHeaderContentView
- (CGFloat)_iconTrailingPadding {
	ifDisabled(self) return %orig;

	return [[preferences valueForKey:getPreferencesKeyFor(@"indicatorClassic", self)] isEqual:@"none"] ? -18 : %orig;
}
%end

%hook PLTitledPlatterView
- (CGRect)_mainContentFrame {
	ifDisabled(self) return %orig;

	// needed because else the frame of it cuts of the content after adjustment
	self.customContentView.clipsToBounds = NO;

	CGRect frame = %orig;

	if ([[preferences valueForKey:getPreferencesKeyFor(@"style", self)] isEqual:@"modern"]) {
		frame.origin.y = frame.origin.y - 14;
		if (!isRTL()) {
			frame.origin.x = frame.origin.x + getIndicatorOffset(self);
		}
	} else if ([[preferences valueForKey:getPreferencesKeyFor(@"style", self)] isEqual:@"classic"] && ![[preferences valueForKey:getPreferencesKeyFor(@"colorHeader", self)] isEqual:@"none"]) {
		frame.origin.y = frame.origin.y + 10;
	}

	return frame;
}
%end

%hook NCNotificationContentView
-(void)setPrimaryText:(NSString *)arg1 {

	ifDisabled(self) {
		%orig;
		return;
	}

	if ([preferences boolForKey:getPreferencesKeyFor(@"nameAsTitle", self)]) {

		NCNotificationShortLookViewController *controller = self._viewControllerForAncestor;
		NSString *bundleId = nil;

		if ([controller isKindOfClass:%c(NCNotificationShortLookViewController)]) {
			bundleId = controller.notificationRequest.sectionIdentifier;
		}

		if (arg1 == nil && bundleId != nil && ![bundleId isEqual:@"com.apple.donotdisturb"]) {
			SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleId];
			if (app && app.displayName) {
				arg1 = app.displayName;
			}
		}

	}

	%orig(arg1);
}

- (void)layoutSubviews {
	%orig;

	ifDisabled(self) return;

	CGRect primaryLabelFrame = self.primaryLabel.frame;
	CGRect primarySubtitleLabelFrame = self.primarySubtitleLabel.frame;
	CGRect secondaryLabelFrame = self.secondaryLabel.frame;
	CGRect summaryLabelFrame = self.summaryLabel.frame;

	CGFloat labelWidth = getIndicatorOffset(self);

	// Moves the image preview to the correct place
	UIImageView *thumbnail = [self safeValueForKey:@"_thumbnailImageView"];
	if (thumbnail) {
		CGRect thumbFrame = thumbnail.frame;
		if (!isRTL() || [[preferences valueForKey:getPreferencesKeyFor(@"style", self)] isEqual:@"classic"]) {
			thumbFrame.origin.x = thumbFrame.origin.x - labelWidth;
		}
		thumbnail.frame = thumbFrame;

		NCNotificationShortLookViewController *controller = self._viewControllerForAncestor;
		if ([controller isKindOfClass:%c(NCNotificationShortLookViewController)] && [controller.notificationRequest.sectionIdentifier isEqual:@"com.apple.donotdisturb"] && [[preferences valueForKey:getPreferencesKeyFor(@"style", self)] isEqual:@"modern"]) {
			if (!isRTL()) {
				labelWidth -= thumbnail.frame.size.width;
			}
		}
	}

	primaryLabelFrame.size.width = self.primaryLabel.frame.size.width - labelWidth;
	secondaryLabelFrame.size.width = self.secondaryLabel.frame.size.width - labelWidth;
	primarySubtitleLabelFrame.size.width = self.primarySubtitleLabel.frame.size.width - labelWidth;
	summaryLabelFrame.size.width = self.summaryLabel.frame.size.width - labelWidth;

	self.primaryLabel.frame = primaryLabelFrame;
	self.primarySubtitleLabel.frame = primarySubtitleLabelFrame;
	self.secondaryLabel.frame = secondaryLabelFrame;
	self.summaryLabel.frame = summaryLabelFrame;
}
%end

// This is the view that occasionally asks "Do you want to keep receiving notifications from this app?"
%hook NCAuxiliaryOptionsView
-(void)layoutSubviews {
	ifDisabled(self) {
		%orig;
		return;
	}

	CGRect auxFrame = self.frame;

	if (auxFrame.size.width <= 0) return;

	auxFrame.size.width = auxFrame.size.width - getIndicatorOffset(self);
	self.frame = auxFrame;

	float cornerRadius = getCornerRadius(self);
	if (cornerRadius < 0) cornerRadius = self.frame.size.height / 2;

	UIView *overlayView = [self safeValueForKey:@"_overlayView"];
	overlayView.layer.cornerRadius = cornerRadius;
	overlayView.backgroundColor = nil;

	%orig;
}

%end

// ====================== STATIC HELPER METHODS ====================== //

static float getAppIconCornerRadius(UIView *view) {
	if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorRoundedCorner", view)] isEqual:@"none"]) {
		return 0;
	} else if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorRoundedCorner", view)] isEqual:@"round"]) {
		return -1;
	} else if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorRoundedCorner", view)] isEqual:@"custom"]) {
		return [preferences floatForKey:getPreferencesKeyFor(@"indicatorCustomRoundedCorner", view)];
	}

	return 13; // stock
}

static float getCornerRadius(UIView *view) {
	if ([[preferences valueForKey:getPreferencesKeyFor(@"roundedCorners", view)] isEqual:@"none"]) {
		return 0;
	} else if ([[preferences valueForKey:getPreferencesKeyFor(@"roundedCorners", view)] isEqual:@"round"]) {
		return -1;
	} else if ([[preferences valueForKey:getPreferencesKeyFor(@"roundedCorners", view)] isEqual:@"custom"]) {
		return [preferences floatForKey:getPreferencesKeyFor(@"customCornerRadius", view)];
	}

	return 13; // stock
}

static float getIndicatorOffset(UIView *view) {
	float offset = 0;

	if ([[preferences valueForKey:getPreferencesKeyFor(@"style", view)] isEqual:@"modern"]) {
		if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorModern", view)] isEqual:@"icon"]) {
			offset = ([preferences integerForKey:getPreferencesKeyFor(@"indicatorModernSize", view)] + 21);
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorModern", view)] isEqual:@"dot"] || [[preferences valueForKey:getPreferencesKeyFor(@"indicatorModern", view)] isEqual:@"triangle"]) {
			offset = ([preferences integerForKey:getPreferencesKeyFor(@"indicatorModernSize", view)] / 2) + 21;
		} else if ([[preferences valueForKey:getPreferencesKeyFor(@"indicatorModern", view)] isEqual:@"line"]) {
			offset = 25;
		} else {
			offset = 5;
		}
	}

	return offset;
}

static BOOL isLockscreen(UIView *view) {
	while (view.superview != nil && ![[view _viewControllerForAncestor] isKindOfClass:%c(NCNotificationViewController)]) {
		view = view.superview;
	}

	if ([[view _viewControllerForAncestor] isKindOfClass:%c(NCNotificationViewController)]) {
		return ((NCNotificationViewController *)[view _viewControllerForAncestor]).associatedView ? YES : NO;
	}

	return NO;
}

static NSString *getPreferencesKeyFor(NSString *key, UIView *view) {
	return [NSString stringWithFormat:@"%@%@", key, isLockscreen(view) ? @"Lockscreen" : @"Banner"];
}

static NSString *getColorFor(NSString *key, UIView *view) {
	NSString *value = [preferences valueForKey:getPreferencesKeyFor(key, view)];

	if ([value isEqual:@"none"]) return nil;
	return value;
}

// ====================== NOTIFICATION TESTING ====================== //

static void createTestNotifications(int amount) {
	NSMutableDictionary *installedApps = [[NSMutableDictionary alloc] init];

	NSArray *apps = [[%c(LSApplicationWorkspace) defaultWorkspace] allInstalledApplications];
	for (LSApplicationProxy *app in apps) {
		if ([app.applicationType isEqual:@"User"] ||
			(
				[app.applicationType isEqual:@"System"] &&
				![app.appTags containsObject:@"hidden"] &&
				!app.launchProhibited &&
				!app.placeholder &&
				!app.removedSystemApp
			)
		) {
			[installedApps setObject:[app localizedNameForContext:nil] forKey:app.applicationIdentifier];
		}
	}

	NSArray *bundleIds = [installedApps allKeys];
	for (int i = 0; i < amount; i++) {
		NSString *bundleId = [bundleIds objectAtIndex:(arc4random()%[bundleIds count])];
		NSString *appName = installedApps[bundleId];

		if (i == 4) {
			[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Velvet Notification"
                                                           message:[NSString stringWithFormat:@"This is a second notification for %@", appName]
                                                           bundleID:bundleId];
		}

		[[%c(JBBulletinManager) sharedInstance] showBulletinWithTitle:@"Velvet Notification"
                                                           message:[NSString stringWithFormat:@"This is a test notification for %@", appName]
                                                           bundleID:bundleId];

	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		isTesting = NO;
	});
}

static void testRegular() {
	if (isTesting) return; // Prevent unnecessary spam
	isTesting = YES;

	createTestNotifications(1);
}

static void testLockscreen() {
	if (isTesting) return; // Prevent unnecessary spam
	isTesting = YES;

	[[%c(SBLockScreenManager) sharedInstance] lockUIFromSource:1 withOptions:nil];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
		createTestNotifications(5);
	});
}

static void testCustom() {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {

		[[%c(JBBulletinManager) sharedInstance]
        showBulletinWithTitle:@"Home"
        message:@"Would you like to turn the lights on?"
        bundleID:@"com.apple.Home"];

		[[%c(JBBulletinManager) sharedInstance]
			showBulletinWithTitle:@"iTunes Store"
			message:@"Your favourite artist released a new track!"
			bundleID:@"com.apple.MobileStore"];

		[[%c(JBBulletinManager) sharedInstance]
			showBulletinWithTitle:@"Twitter"
			message:@"By @NoisyFlake & @HiMyNameIsUbik"
			bundleID:@"com.atebits.Tweetie2"];

		[[%c(JBBulletinManager) sharedInstance]
			showBulletinWithTitle:@"Tim Cook"
			message:@"ETA?!"
			bundleID:@"com.apple.MobileSMS"];

		[[%c(JBBulletinManager) sharedInstance]
			showBulletinWithTitle:@"Tim Cook"
			message:@"This looks even better than iOS 14!"
			bundleID:@"com.apple.MobileSMS"];
	});
}

static BOOL isRTL() {
	return [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

%ctor {
	preferences = [VelvetPrefs sharedInstance];

	if ([preferences boolForKey:@"enabled"]) {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)testRegular, CFSTR("com.initwithframe.velvet/testRegular"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)testLockscreen, CFSTR("com.initwithframe.velvet/testLockscreen"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		colorCache = [VelvetPrefs colorCache];
		%init;

		if (showCustomMessages) testCustom();
	}
}
