#import "Headers.h"
#import "MediaPlayer.h"
#import "VelvetPrefs.h"
#import "ColorSupport.h"

VelvetBackgroundView *velvetArtworkBackground;
UIView *velvetArtworkBorder;
UIColor *velvetArtworkColor;
UIColor *velvetArtworkBorderColor;

BOOL colorFlowInstalled;

%hook CSNotificationAdjunctListViewController

-(void)viewDidLayoutSubviews {
	%orig;
	
	if ([[preferences valueForKey:@"forceModeMediaplayer"] isEqual:@"dark"]) {
		self.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
	} else if ([[preferences valueForKey:@"forceModeMediaplayer"] isEqual:@"light"]) {
		self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
	}
}

%end

%hook CSMediaControlsView

- (void)didMoveToWindow {
	%orig;

	

	if (![preferences boolForKey:@"enableMediaplayer"] || colorFlowLockscreenResizingEnabled()) return;
	NSString *backgroundColor = [preferences valueForKey:@"colorBackgroundMediaplayer"];

	PLPlatterView *platterView = (PLPlatterView *)self.superview.superview;
	MTMaterialView *backgroundMaterialView = platterView.backgroundMaterialView;

	PLPlatterCustomContentView *platterCustomContentView = (PLPlatterCustomContentView *)self.superview;
	if (platterCustomContentView) platterCustomContentView.clipsToBounds = NO;

	float cornerRadius = getCornerRadius();
	if (cornerRadius < 0) cornerRadius = self.frame.size.height / 2;

	if (velvetArtworkBackground == nil) {
		velvetArtworkBackground = [[VelvetBackgroundView alloc] initWithFrame:CGRectZero];
		velvetArtworkBackground.layer.continuousCorners = YES;
		velvetArtworkBackground.clipsToBounds = YES;

		[self insertSubview:velvetArtworkBackground atIndex:0];
	}

	if (velvetArtworkBorder == nil) {
		velvetArtworkBorder = [[UIView alloc] initWithFrame:CGRectZero];

		[velvetArtworkBackground insertSubview:velvetArtworkBorder atIndex:1];
	}

	velvetArtworkBackground.frame = self.superview.frame;

	platterView.layer.cornerRadius = cornerRadius;
	platterView.layer.continuousCorners = YES;
	platterView.clipsToBounds = YES;

	backgroundMaterialView.layer.cornerRadius = cornerRadius;
	backgroundMaterialView.layer.continuousCorners = YES;
	velvetArtworkBackground.layer.cornerRadius = cornerRadius;

	velvetArtworkBorder.hidden = YES;
	velvetArtworkBackground.layer.borderWidth = 0;

	if ([backgroundColor containsString:@"0.00"]) {
		backgroundMaterialView.alpha = 0;
	} else {
		backgroundMaterialView.alpha = 1;
	}

	if (![[preferences valueForKey:@"borderColorMediaplayer"] isEqual:@"none"]) {
		int borderWidth = [preferences integerForKey:@"borderWidthMediaplayer"];
		if ([[preferences valueForKey:@"borderPositionMediaplayer"] isEqual:@"all"]) {
			velvetArtworkBackground.layer.borderWidth = borderWidth;
		} else if ([[preferences valueForKey:@"borderPositionMediaplayer"] isEqual:@"top"]) {
			velvetArtworkBorder.hidden = NO;
			velvetArtworkBorder.frame = CGRectMake(0, 0, self.superview.frame.size.width, borderWidth);
		} else if ([[preferences valueForKey:@"borderPositionMediaplayer"] isEqual:@"right"]) {
			velvetArtworkBorder.hidden = NO;
			velvetArtworkBorder.frame = CGRectMake(self.superview.frame.size.width - borderWidth, 0, borderWidth, self.superview.frame.size.height);
		} else if ([[preferences valueForKey:@"borderPositionMediaplayer"] isEqual:@"bottom"]) {
			velvetArtworkBorder.hidden = NO;
			velvetArtworkBorder.frame = CGRectMake(0, self.superview.frame.size.height - borderWidth, self.superview.frame.size.width, borderWidth);
		} else if ([[preferences valueForKey:@"borderPositionMediaplayer"] isEqual:@"left"]) {
			velvetArtworkBorder.hidden = NO;
			velvetArtworkBorder.frame = CGRectMake(0, 0, borderWidth, self.superview.frame.size.height);
		}
	}

	if (colorFlowLockscreenColoringEnabled()) return;
	updateMediaplayerColors();
}

%end

%hook SBMediaController

- (void)_mediaRemoteNowPlayingInfoDidChange:(id)arg1 {
	%orig;

	if (![preferences boolForKey:@"enableMediaplayer"] || colorFlowLockscreenColoringEnabled()) return;
	updateMediaplayerColors();
}

%end

// ====================== COLORFLOW SUPPORT ====================== //

%hook CSCoverSheetViewController

%new
- (void)velvetColorBorderWithThirdParty:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	colorMediaplayerWithThirdParty(userInfo[@"SecondaryColor"]);
}

- (void)loadView {
	%orig;

	if (![preferences boolForKey:@"enableMediaplayer"]) return;

	if (colorFlowInstalled) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(velvetColorBorderWithThirdParty:) name:@"ColorFlowLockScreenColorizationNotification" object:nil];
	}
}

%end

static float getCornerRadius() {
	if ([[preferences valueForKey:@"roundedCornersMediaplayer"] isEqual:@"none"]) {
		return 0;
	} else if ([[preferences valueForKey:@"roundedCornersMediaplayer"] isEqual:@"round"]) {
		return -1;
	} else if ([[preferences valueForKey:@"roundedCornersMediaplayer"] isEqual:@"custom"]) {
		return [preferences floatForKey:@"customCornerRadiusMediaplayer"];
	}

	return 13; // stock
}

static void updateMediaplayerColors() {
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *dict = (__bridge NSDictionary *)(information);
		if(!dict) return;

        NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
        __block UIImage *artwork = [UIImage imageWithData:artworkData];

		NSString *backgroundColor = [preferences valueForKey:@"colorBackgroundMediaplayer"];
		velvetArtworkColor = [[preferences valueForKey:@"colorBackgroundMediaplayer"] isEqual:@"dominant"] ? [artwork velvetAverageColor] : [UIColor velvetColorFromHexString:backgroundColor];

		NSString *borderColor = [preferences valueForKey:@"borderColorMediaplayer"];
		velvetArtworkBorderColor = [[preferences valueForKey:@"borderColorMediaplayer"] isEqual:@"dominant"] ? [artwork velvetAverageColor] : [UIColor velvetColorFromHexString:borderColor];

		if (backgroundColor != nil) {
			// Needed to recolor when track changes without lockscreen media controls changing
			velvetArtworkBorder.backgroundColor = velvetArtworkBorderColor;
			velvetArtworkBackground.layer.borderColor = velvetArtworkBorderColor.CGColor;
			velvetArtworkBackground.backgroundColor = [[preferences valueForKey:@"colorBackgroundMediaplayer"] isEqual:@"dominant"] ? [velvetArtworkColor colorWithAlphaComponent:0.6] : [UIColor velvetColorFromHexString:backgroundColor];
		}
	});
}

static void colorMediaplayerWithThirdParty(UIColor *color) {
	velvetArtworkBackground.layer.borderColor = color.CGColor;
}

static BOOL colorFlowLockscreenColoringEnabled() {
	return [[%c(CFWPrefsManager) sharedInstance] isLockScreenEnabled] ? YES : NO;
}

static BOOL colorFlowLockscreenResizingEnabled() {
	return [[%c(CFWPrefsManager) sharedInstance] lockScreenFullScreenEnabled] ? YES : NO;
}

%ctor {

	preferences = [VelvetPrefs sharedInstance];

	if ([preferences boolForKey:@"enabled"]) {
		colorFlowInstalled = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ColorFlow5.dylib"];
		%init;
	}
}
