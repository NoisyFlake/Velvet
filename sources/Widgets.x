#import "Headers.h"
#import "Widgets.h"
#import "VelvetPrefs.h"
#import "ColorSupport.h"

%hook WGWidgetListItemViewController

-(id)initWithWidgetIdentifier:(NSString *)identifier {
    [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:@selector(velvetColorize) name:[NSString stringWithFormat:@"com.initwithframe.velvet/%@", identifier] object:nil];

    return %orig;
}

-(void)viewWillAppear:(BOOL)arg1 {
    %orig;

    [self velvetColorize];
}

-(void)viewDidLayoutSubviews {
    %orig;

    [self velvetColorize];
}

%new
-(void)velvetColorize {
    UIImage *icon = self.widgetHost.widgetInfo.icon;

    WGWidgetPlatterView *view = (WGWidgetPlatterView *)self.view;

    if (view.velvetBackground == nil) {
		VelvetBackgroundView *velvetBackground = [[VelvetBackgroundView alloc] initWithFrame:CGRectZero];
		velvetBackground.layer.continuousCorners = YES;
		velvetBackground.clipsToBounds = YES;

		[view insertSubview:velvetBackground atIndex:1];
		view.velvetBackground = velvetBackground;
	}

    if (view.velvetFullBorder == nil) {
		UIView *velvetFullBorder = [[UIView alloc] initWithFrame:CGRectZero];
        velvetFullBorder.layer.continuousCorners = YES;
        velvetFullBorder.clipsToBounds = YES;

		[view insertSubview:velvetFullBorder atIndex:3];
		view.velvetFullBorder = velvetFullBorder;
	}

    if (view.velvetBorder == nil) {
		UIView *velvetBorder = [[UIView alloc] initWithFrame:CGRectZero];
        velvetBorder.layer.continuousCorners = YES;
        velvetBorder.clipsToBounds = YES;

		[view.velvetFullBorder insertSubview:velvetBorder atIndex:1];
		view.velvetBorder = velvetBorder;
	}

    

    MTMaterialView *headerBackground = [view safeValueForKey:@"_headerBackgroundView"];
    MTMaterialView *background = [view safeValueForKey:@"_backgroundView"];

    float cornerRadius = getCornerRadius();
    headerBackground.layer.cornerRadius = cornerRadius;
    background.layer.cornerRadius = cornerRadius;
    view.velvetBackground.layer.cornerRadius = cornerRadius;
    view.velvetFullBorder.layer.cornerRadius = cornerRadius;
    view.layer.cornerRadius = cornerRadius;

    view.velvetBackground.frame = view.bounds;
    view.velvetFullBorder.frame = view.bounds;

    // This will actually just move the subview to the correct position, since it might have been inserted too early before content was loaded
    [view insertSubview:view.velvetBackground atIndex:1];
    [view insertSubview:view.velvetFullBorder atIndex:5];

    if (icon) {
        NSString *iconIdentifier = [UIImagePNGRepresentation(icon) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        UIColor *dominantColor = colorCache[iconIdentifier];

        if (dominantColor == nil) {
            dominantColor = [icon velvetDominantColor];
            [colorCache setObject:dominantColor forKey:iconIdentifier];
        }

        headerBackground.backgroundColor = [preferences boolForKey:@"colorHeaderWidget"] ? [dominantColor colorWithAlphaComponent:0.8] : nil;
        view.velvetBackground.backgroundColor = [preferences boolForKey:@"colorBackgroundWidget"] ? [dominantColor colorWithAlphaComponent:0.6] : nil;
        headerBackground.alpha = [preferences boolForKey:@"hideBackgroundWidget"] && ![preferences boolForKey:@"colorHeaderWidget"] ? 0 : 1;
        background.alpha = [preferences boolForKey:@"hideBackgroundWidget"] ? 0 : 1;

        // Fake coloring the entire thing when only background is enabled
        if ([preferences boolForKey:@"colorBackgroundWidget"] && ![preferences boolForKey:@"colorHeaderWidget"]) {
            headerBackground.backgroundColor = [dominantColor colorWithAlphaComponent:0.6];
        }

        view.velvetBorder.backgroundColor = [dominantColor colorWithAlphaComponent:0.8];
        view.velvetFullBorder.layer.borderColor = [dominantColor colorWithAlphaComponent:0.8].CGColor;

        view.velvetBorder.hidden = YES;
        view.velvetFullBorder.layer.borderWidth = 0;

        int borderWidth = [preferences integerForKey:@"borderWidthWidget"];
        if ([[preferences valueForKey:@"borderWidget"] isEqual:@"all"]) {
            view.velvetFullBorder.layer.borderColor = [dominantColor colorWithAlphaComponent:0.8].CGColor;
            view.velvetFullBorder.layer.borderWidth = borderWidth;
        } else if ([[preferences valueForKey:@"borderWidget"] isEqual:@"top"]) {
            view.velvetBorder.hidden = NO;
            view.velvetBorder.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
        } else if ([[preferences valueForKey:@"borderWidget"] isEqual:@"right"]) {
            view.velvetBorder.hidden = NO;
            view.velvetBorder.frame = CGRectMake(view.frame.size.width - borderWidth, 0, borderWidth, view.frame.size.height);
        } else if ([[preferences valueForKey:@"borderWidget"] isEqual:@"bottom"]) {
            view.velvetBorder.hidden = NO;
            view.velvetBorder.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, borderWidth);
        } else if ([[preferences valueForKey:@"borderWidget"] isEqual:@"left"]) {
            view.velvetBorder.hidden = NO;
            view.velvetBorder.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
        }
        
    }
}
%end

%hook WGWidgetInfo 
-(void)_setIcon:(id)arg1 {
    %orig;

    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"com.initwithframe.velvet/%@", self.widgetIdentifier] object:nil];
}
%end

%hook WGWidgetPlatterView
%property (retain, nonatomic) UIView * velvetBorder;
%property (retain, nonatomic) UIView * velvetFullBorder;
%property (retain, nonatomic) VelvetBackgroundView * velvetBackground;

-(CGSize)sizeThatFitsContentWithSize:(CGSize)arg1 {
    CGSize orig = %orig;

    if ([((WGWidgetListItemViewController *)self._viewControllerForAncestor).widgetIdentifier isEqual:@"com.apple.shortcuts.Today-Extension"] && [preferences boolForKey:@"colorHeaderWidget"]) {
        orig.height += 10;
    }

    return orig;
}

-(void)_layoutContentView {
    %orig;

    if ([((WGWidgetListItemViewController *)self._viewControllerForAncestor).widgetIdentifier isEqual:@"com.apple.shortcuts.Today-Extension"] && [preferences boolForKey:@"colorHeaderWidget"]) {
        CGRect frame = self.contentView.frame;
        frame.origin.y += 8;
        self.contentView.frame = frame;
    }
}
%end

static float getCornerRadius() {
	if ([[preferences valueForKey:@"roundedCornersWidget"] isEqual:@"none"]) {
		return 0;
	} else if ([[preferences valueForKey:@"roundedCornersWidget"] isEqual:@"round"]) {
		return -1;
	} else if ([[preferences valueForKey:@"roundedCornersWidget"] isEqual:@"custom"]) {
		return [preferences floatForKey:@"customCornerRadiusWidget"];
	}

	return 13; // stock
}

%ctor {
    preferences = [VelvetPrefs sharedInstance];

    if ([preferences boolForKey:@"enabled"] && [preferences boolForKey:@"enableWidgets"]) {
        colorCache = [VelvetPrefs colorCache];
        %init;
    }
}
