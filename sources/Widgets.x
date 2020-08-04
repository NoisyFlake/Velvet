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
        velvetFullBorder.userInteractionEnabled = NO;

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

        NSString *headerColor = getColorFor(@"colorHeaderWidget");
        if (headerColor) {
            headerBackground.backgroundColor = [headerColor isEqual:@"dominant"] ? [dominantColor colorWithAlphaComponent:0.8] : [UIColor velvetColorFromHexString:headerColor];
        } else {
            headerBackground.backgroundColor = nil;
        }

        NSString *backgroundColor = getColorFor(@"colorBackgroundWidget");
        if (backgroundColor) {
            view.velvetBackground.backgroundColor = [backgroundColor isEqual:@"dominant"] ? [dominantColor colorWithAlphaComponent:0.6] : [UIColor velvetColorFromHexString:backgroundColor];

            // Fake coloring the entire thing when only background is enabled
            if (!headerColor) {
                headerBackground.backgroundColor = [backgroundColor isEqual:@"dominant"] ? [dominantColor colorWithAlphaComponent:0.6] : [UIColor velvetColorFromHexString:backgroundColor];
            }

            if ([backgroundColor containsString:@"0.00"]) {
                background.alpha = 0;
                if (!headerColor) {
                    headerBackground.alpha = 0;
                } else {
                    headerBackground.alpha = 1;
                }
            } else {
                background.alpha = 1;
                headerBackground.alpha = 1;
            }
        } else {
            view.velvetBackground.backgroundColor = nil;
            background.alpha = 1;
            headerBackground.alpha = 1;
        }

        view.velvetBorder.hidden = YES;
        view.velvetFullBorder.layer.borderWidth = 0;

        NSString *borderColor = getColorFor(@"borderColorWidget");
        if (borderColor) {
            view.velvetBorder.backgroundColor = [borderColor isEqual:@"dominant"] ? [dominantColor colorWithAlphaComponent:0.8] : [UIColor velvetColorFromHexString:borderColor];
            view.velvetFullBorder.layer.borderColor = [borderColor isEqual:@"dominant"] ? [dominantColor colorWithAlphaComponent:0.8].CGColor : [UIColor velvetColorFromHexString:borderColor].CGColor;
        
            int borderWidth = [preferences integerForKey:@"borderWidthWidget"];
            if ([[preferences valueForKey:@"borderPositionWidget"] isEqual:@"all"]) {
                view.velvetFullBorder.layer.borderWidth = borderWidth;
            } else if ([[preferences valueForKey:@"borderPositionWidget"] isEqual:@"top"]) {
                view.velvetBorder.hidden = NO;
                view.velvetBorder.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
            } else if ([[preferences valueForKey:@"borderPositionWidget"] isEqual:@"right"]) {
                view.velvetBorder.hidden = NO;
                view.velvetBorder.frame = CGRectMake(view.frame.size.width - borderWidth, 0, borderWidth, view.frame.size.height);
            } else if ([[preferences valueForKey:@"borderPositionWidget"] isEqual:@"bottom"]) {
                view.velvetBorder.hidden = NO;
                view.velvetBorder.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, borderWidth);
            } else if ([[preferences valueForKey:@"borderPositionWidget"] isEqual:@"left"]) {
                view.velvetBorder.hidden = NO;
                view.velvetBorder.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
            }

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

-(void)_layoutContentView {
    %orig;

    if (![[preferences valueForKey:@"colorHeaderWidget"] isEqual:@"none"]) {
        CGRect frame = self.contentView.frame;
        frame.origin.y += 4;
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

static NSString *getColorFor(NSString *key) {
	NSString *value = [preferences valueForKey:key];

	if ([value isEqual:@"none"]) return nil;
	return value;
}

%ctor {
    preferences = [VelvetPrefs sharedInstance];

    if ([preferences boolForKey:@"enabled"] && [preferences boolForKey:@"enableWidgets"]) {
        colorCache = [VelvetPrefs colorCache];
        %init;
    }
}
