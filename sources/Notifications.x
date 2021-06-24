#import "Headers.h"
#import "Notifications.h"
#import "VelvetPrefs.h"
#import "ColorSupport.h"
#import "FolderFinder.h"
#import <Contacts/Contacts.h>
#import <UserNotifications/UNNotification.h>
#import <UserNotifications/UNNotificationRequest.h>
#import <UserNotifications/UNNotificationContent.h>

BOOL showCustomMessages = NO;
BOOL isTesting;

%hook NCNotificationShortLookView
%property (retain, nonatomic) VelvetIndicatorView * colorIndicator;
%property (retain, nonatomic) UIView * velvetBorder;
%property (retain, nonatomic) VelvetBackgroundView * velvetBackground;
%property (retain, nonatomic) UIImageView * imageIndicator;
%property (retain, nonatomic) UIImageView * imageIndicatorCorner;
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

%hook NCNotificationStructuredListViewController
- (void)viewDidLayoutSubviews {
	%orig;

	if ([[preferences valueForKey:@"forceModeLockscreen"] isEqual:@"dark"]) {
		self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
	} else if ([[preferences valueForKey:@"forceModeLockscreen"] isEqual:@"light"]) {
		self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
	}
}
%end

%hook NCNotificationShortLookViewController
- (void)viewDidLayoutSubviews {
	%orig;

	NCNotificationShortLookView *view = self.viewForPreview;

	ifDisabled(view) return;

	// Notification view is not yet fully initialized
	if (view.frame.size.width == 0) return;

	if ([[preferences valueForKey:getPreferencesKeyFor(@"forceMode", view)] isEqual:@"dark"]) {
		self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
	} else if ([[preferences valueForKey:getPreferencesKeyFor(@"forceMode", view)] isEqual:@"light"]) {
		self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
	}

	float cornerRadius = getCornerRadius(view);
	if (cornerRadius < 0) cornerRadius = view.frame.size.height / 2;

	UIColor *dominantColor = [self getDominantColor];

	if (view.velvetBackground == nil) {
		VelvetBackgroundView *velvetBackground = [[VelvetBackgroundView alloc] initWithFrame:CGRectZero];
		velvetBackground.layer.continuousCorners = YES;
		velvetBackground.clipsToBounds = YES;

		[view insertSubview:velvetBackground atIndex:(isLockscreen(view) ? 1 : 2)]; // TODO check if this still works on iOS 13 when it's not 1
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

	if (view.imageIndicatorCorner == nil) {
		UIImageView *imageIndicatorCorner = [[UIImageView alloc] initWithFrame:CGRectZero];

		[view insertSubview:imageIndicatorCorner atIndex:4];
		view.imageIndicatorCorner = imageIndicatorCorner;
	}

	view.backgroundMaterialView.layer.cornerRadius = cornerRadius;
	UIView *stackDimmingView = [self.view valueForKey:@"_stackDimmingView"];
	stackDimmingView.layer.cornerRadius = cornerRadius;
	view.velvetBackground.layer.cornerRadius = cornerRadius;

	// Hide and reset everything so we can set it up from scratch in the next steps
	view.imageIndicator.hidden = YES;
	view.imageIndicator.layer.borderWidth = 0;
	view.imageIndicator.layer.borderColor = nil;
	view.imageIndicatorCorner.hidden = YES;
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

		bool hasHeaderGradient = NO;
		for (CALayer *sublayer in header.layer.sublayers) {
			if ([sublayer isKindOfClass:%c(CAGradientLayer)]) {
				hasHeaderGradient = YES;
				((CAGradientLayer *)sublayer).colors = nil;
				break;
			}
		}

		if (!hasHeaderGradient) {
			CAGradientLayer *gradient = [CAGradientLayer layer];
			gradient.startPoint = CGPointMake(0, 0);
			gradient.endPoint = CGPointMake(1, 0);

			[header.layer insertSublayer:gradient atIndex:0];
		}
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

			view.imageIndicatorCorner.frame = CGRectMake((view.imageIndicator.frame.origin.x + view.imageIndicator.frame.size.width) - 13, (view.imageIndicator.frame.origin.y + view.imageIndicator.frame.size.height) - 13, 15, 15);

			if ([self.notificationRequest.sectionIdentifier isEqual:@"com.apple.donotdisturb"] || [self.notificationRequest.sectionIdentifier isEqual:@"com.apple.powerui.smartcharging"]) {
				view.imageIndicator.image = [UIImage systemImageNamed:self.notificationRequest.content.attachmentImage.imageAsset.assetName];
				view.imageIndicator.tintColor = UIColor.labelColor;
				thumbnail.alpha = 0;
			} else {
				UIImage *contactPicture = [self getContactPicture];

				if ([preferences boolForKey:getPreferencesKeyFor(@"useContactPicture", view)] && contactPicture != nil) {			
					view.imageIndicator.image = contactPicture;
					view.imageIndicator.layer.cornerRadius = view.imageIndicator.frame.size.height / 2;
					view.imageIndicator.clipsToBounds = YES;
					view.imageIndicator.contentMode = UIViewContentModeScaleAspectFill;

					if ([preferences boolForKey:getPreferencesKeyFor(@"useContactPictureIcon", view)]) {
						view.imageIndicatorCorner.image = [self getIconForBundleId:self.notificationRequest.sectionIdentifier withMask:YES];
						view.imageIndicatorCorner.hidden = NO;
					}

					NSString *contactBorderColor = getColorFor(@"contactPictureBorder", view);
					if (contactBorderColor) {
						view.imageIndicator.layer.borderWidth = 1;
						view.imageIndicator.layer.borderColor = [contactBorderColor isEqual:@"dominant"] ? dominantColor.CGColor : [UIColor velvetColorFromHexString:contactBorderColor].CGColor;
					}
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
			UIColor *chosenColor = [headerColor isEqual:@"dominant"] ? [dominantColor colorWithAlphaComponent:0.8] : [UIColor velvetColorFromHexString:headerColor];
			if (chosenColor) {
				if ([headerTitleColor isEqual:@"dominant"]) {
					header.titleLabel.textColor = [chosenColor velvetIsDarkColor] ? UIColor.whiteColor : (self.traitCollection.userInterfaceStyle == 1 ? UIColor.blackColor : UIColor.systemGray4Color);
				}
				
				if ([[preferences valueForKey:getPreferencesKeyFor(@"gradientHeader", view)] isEqual:@"no"]) {
					header.backgroundColor = chosenColor;
				} else {
					// This is just so we can check later if there is a background color
					header.backgroundColor = chosenColor;

					CGFloat hue, saturation, brightness, alpha ;
					[chosenColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha ] ;
					UIColor *highlightColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness+0.25 alpha:alpha];

					NSArray *colorArray;
					if ([[preferences valueForKey:getPreferencesKeyFor(@"gradientHeader", view)] isEqual:@"ltr"]) {
						colorArray = @[(id)highlightColor.CGColor, (id)chosenColor.CGColor];
					} else if ([[preferences valueForKey:getPreferencesKeyFor(@"gradientHeader", view)] isEqual:@"center"]) {
						colorArray = @[(id)chosenColor.CGColor, (id)highlightColor.CGColor, (id)chosenColor.CGColor];
					} else if ([[preferences valueForKey:getPreferencesKeyFor(@"gradientHeader", view)] isEqual:@"rtl"]) {
						colorArray = @[(id)chosenColor.CGColor, (id)highlightColor.CGColor];
					}

					for (CALayer *sublayer in header.layer.sublayers) {
						if ([sublayer isKindOfClass:%c(CAGradientLayer)]) {
							((CAGradientLayer *)sublayer).colors = colorArray;

							// Don't know why, but this has to be delayed a bit or header.bounds will be null
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
								((CAGradientLayer *)sublayer).frame = header.bounds;
							});

							break;
						}
					}
				}
			}


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

	NSString *titleColor = getColorFor(@"colorPrimaryLabel", view);
	if (titleColor) {
		if ([backgroundColor isEqual:@"dominant"] && [titleColor isEqual:@"dominant"]) {
			view.notificationContentView.primaryLabel.textColor = [view.velvetBackground.backgroundColor velvetIsDarkColor] ? UIColor.whiteColor : (self.traitCollection.userInterfaceStyle == 1 ? UIColor.blackColor : UIColor.systemGray4Color);
		} else {
			view.notificationContentView.primaryLabel.textColor = [titleColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:titleColor];
		}
	} else {
		view.notificationContentView.primaryLabel.textColor = nil;
	}

	NSString *messageColor = getColorFor(@"colorSecondaryLabel", view);
	if (messageColor) {
		if ([backgroundColor isEqual:@"dominant"] && [messageColor isEqual:@"dominant"]) {
			view.notificationContentView.secondaryLabel.textColor = [view.velvetBackground.backgroundColor velvetIsDarkColor] ? UIColor.whiteColor : (self.traitCollection.userInterfaceStyle == 1 ? UIColor.blackColor : UIColor.systemGray4Color);
		} else {
			view.notificationContentView.secondaryLabel.textColor = [messageColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:messageColor];
		}
		view.notificationContentView.summaryLabel.textColor = view.notificationContentView.secondaryLabel.textColor;
		view.notificationContentView.primarySubtitleLabel.textColor = view.notificationContentView.secondaryLabel.textColor;
	} else {
		view.notificationContentView.secondaryLabel.textColor = nil;
		view.notificationContentView.summaryLabel.textColor = nil;
		view.notificationContentView.primarySubtitleLabel.textColor = nil;
	}

	NSString *headerDateColor = getColorFor(@"colorHeaderDate", view);
	if (headerDateColor) {
		// Yup, this is necessary as sometimes when receiving lockscreen notifications, dateLabel isn't initialized yet. Stupid iOS.
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			header.dateLabel.layer.filters = nil;

			if (header.backgroundColor && [headerDateColor isEqual:@"dominant"]) {
				header.dateLabel.textColor = [header.backgroundColor velvetIsDarkColor] ? UIColor.whiteColor : (self.traitCollection.userInterfaceStyle == 1 ? UIColor.blackColor : UIColor.systemGray4Color);
			} else if (view.velvetBackground.backgroundColor && [headerDateColor isEqual:@"dominant"]) {
				header.dateLabel.textColor = [view.velvetBackground.backgroundColor velvetIsDarkColor] ? UIColor.whiteColor : (self.traitCollection.userInterfaceStyle == 1 ? UIColor.blackColor : UIColor.systemGray4Color);
			} else {
				header.dateLabel.textColor = [headerDateColor isEqual:@"dominant"] ? dominantColor : [UIColor velvetColorFromHexString:headerDateColor];
			}
			
		});
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

	if ([bundleId isEqual:@"com.apple.donotdisturb"] || [bundleId isEqual:@"com.apple.powerui.smartcharging"]) return nil;

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

%new
-(UIImage *)getContactPicture {
	UIImage *contactPicture = nil;

	if ([self.notificationRequest.sectionIdentifier isEqual:@"com.apple.MobileSMS"]) {
		
		if (self.notificationRequest.userNotification.request.content.userInfo == nil) return nil;

		NSString *identifier = [self.notificationRequest.userNotification.request.content.userInfo valueForKey:@"CKBBContextKeySenderPersonCentricID"];
		if (identifier != nil) {
			// DMs
			CNContactStore *contactStore = [[CNContactStore alloc] init];
			NSArray *keys = @[CNContactIdentifierKey, CNContactImageDataKey];
			CNContact *contact = [contactStore unifiedContactWithIdentifier:identifier keysToFetch:keys error:nil];

			if (contact && contact.imageData != nil) {
				contactPicture = [UIImage imageWithData:contact.imageData scale:[UIScreen mainScreen].scale];
			}
		} else {
			// Groups
			identifier = [[self.notificationRequest.context valueForKey:@"userInfo"] valueForKey:@"CKBBContextKeyChatGroupID"];

			// Unfortunately it is not possible to access sharedConversationList outside of the messages app

			// CKConversationList *conversationList = [%c(CKConversationList) sharedConversationList];
			// CKConversation *conversation = [conversationList conversationForExistingChatWithGroupID:identifier];
			// CNGroupIdentity *identity = conversation._conversationVisualIdentity;

			// if (identity && identity.groupPhoto != nil) {
			// 	contactPicture = [UIImage imageWithData:identity.groupPhoto scale:[UIScreen mainScreen].scale];
			// }
		}
	
	} else if ([self.notificationRequest.sectionIdentifier isEqual:@"net.whatsapp.WhatsApp"]) {

		if (self.notificationRequest.threadIdentifier == nil) return nil;

		NSString *chatId = [self.notificationRequest.threadIdentifier componentsSeparatedByString:@"@"][0];
		NSFileManager *fileManager = [[NSFileManager alloc] init];

		NSString *file;
		NSString *whatsAppPicture;
		NSString *containerPath = [FolderFinder findSharedFolder:@"group.net.whatsapp.WhatsApp.shared"];
		NSString *picturesPath = [NSString stringWithFormat:@"%@/Media/Profile", containerPath];
		NSEnumerator *files = [[fileManager contentsOfDirectoryAtPath:picturesPath error:nil] reverseObjectEnumerator];

		while (file = [files nextObject]) {
			NSArray *parts = [file componentsSeparatedByString:@"-"];

			// DMs
			if ([parts count] == 2) {
				if ([chatId isEqualToString:parts[0]]){
					whatsAppPicture = file;
					break;
				}
			}

			// Groups
			if ([parts count] == 3) {
				if ([chatId isEqualToString:[NSString stringWithFormat:@"%@-%@", parts[0], parts[1]]]){
					whatsAppPicture = file;
					break;
				}
			}
		}

		if (whatsAppPicture != nil) {
			contactPicture = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", picturesPath, whatsAppPicture]];
		}
	}

	return contactPicture;
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

		if (arg1 == nil && bundleId != nil && ![bundleId isEqual:@"com.apple.donotdisturb"] && ![bundleId isEqual:@"com.apple.powerui.smartcharging"]) {
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
		if ([controller isKindOfClass:%c(NCNotificationShortLookViewController)] && ([controller.notificationRequest.sectionIdentifier isEqual:@"com.apple.donotdisturb"] || [controller.notificationRequest.sectionIdentifier isEqual:@"com.apple.powerui.smartcharging"]) && [[preferences valueForKey:getPreferencesKeyFor(@"style", self)] isEqual:@"modern"]) {
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
        message:@"Someone is at your front door"
        bundleID:@"com.apple.Home"];

		// [[%c(JBBulletinManager) sharedInstance]
		// 	showBulletinWithTitle:@"Award received!"
		// 	message:@"You received a platinum award"
		// 	bundleID:@"com.christianselig.Apollo"];

		[[%c(JBBulletinManager) sharedInstance]
			showBulletinWithTitle:@""
			message:@"noisyflake, himynameisubik and 2 others liked your photo"
			bundleID:@"com.burbn.instagram"];

		[[%c(JBBulletinManager) sharedInstance]
			showBulletinWithTitle:@"Twitter"
			message:@"#Velvet is now trending on Twitter"
			bundleID:@"com.atebits.Tweetie2"];

		// [[%c(JBBulletinManager) sharedInstance]
		// 	showBulletinWithTitle:@"Tim Cook"
		// 	message:@"ETA?!"
		// 	bundleID:@"com.apple.MobileSMS"];

		[[%c(JBBulletinManager) sharedInstance]
			showBulletinWithTitle:@"Tim Cook"
			message:@"Looks like there's no need for iOS 15"
			bundleID:@"com.apple.MobileSMS"];
	});
}

static BOOL isRTL() {
	return [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

// ---- Enable this when creating mockup screenshots to force iMessages to belong to a specific contact for the contact picture ---- //
// %hook NCNotificationRequest
// -(NSDictionary *)context {
// 	NSDictionary *orig = %orig;
// 	NSMutableDictionary *mutable = (orig == nil) ? [NSMutableDictionary new] : [orig mutableCopy];
// 	NSMutableDictionary *mutableInfo = ([mutable valueForKey:@"userInfo"] == nil) ? [NSMutableDictionary new] : [[mutable valueForKey:@"userInfo"] mutableCopy];

// 	[mutableInfo setObject:@"CCB8AEBD-CA4A-448C-AB41-80DF87E52524:ABPerson" forKey:@"CKBBContextKeySenderPersonCentricID"];
// 	[mutable setObject:mutableInfo forKey:@"userInfo"];

// 	return mutable;
// }
// %end

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
