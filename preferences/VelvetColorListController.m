#include "VelvetHeaders.h"

@implementation VelvetColorListController

- (NSArray *)specifiers {
	if (!_specifiers) {
        
        VelvetPrefs *prefs = [VelvetPrefs sharedInstance];

		NSMutableArray *mutableSpecifiers = [[NSMutableArray alloc] init];

        PSSpecifier* noneCell = [PSSpecifier preferenceSpecifierNamed:@"Default" target:self set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
        [noneCell setProperty:NSClassFromString(@"VelvetColorListCell") forKey:@"cellClass"];
        [noneCell setProperty:@"none" forKey:@"key"];
        noneCell.buttonAction = @selector(selectOption:);

        PSSpecifier* dominantCell = [PSSpecifier preferenceSpecifierNamed:@"Automatic" target:self set:nil get:nil detail:Nil cell:PSButtonCell edit:Nil];
        [dominantCell setProperty:NSClassFromString(@"VelvetColorListCell") forKey:@"cellClass"];
        [dominantCell setProperty:@"dominant" forKey:@"key"];
        dominantCell.buttonAction = @selector(selectOption:);

        PSSpecifier* picker = [PSSpecifier preferenceSpecifierNamed:@"Custom"
										target:self
										set:@selector(setPreferenceValue:specifier:)
										get:@selector(readPreferenceValue:)
										detail:Nil
										cell:PSLinkCell
										edit:Nil];

        [picker setProperty:[self specifier].properties[@"key"] forKey:@"key"];
        [picker setProperty:@"Custom" forKey:@"label"];
        [picker setProperty:@"com.initwithframe.velvet" forKey:@"defaults"];
        [picker setProperty:NSClassFromString(@"VelvetColorPicker") forKey:@"cellClass"];
        

        NSString *currentValue = [prefs valueForKey:[self specifier].properties[@"key"]];
        if ([currentValue isEqual:@"none"]) {
            [noneCell setProperty:@YES forKey:@"isActive"];
        } else if ([currentValue isEqual:@"dominant"]) {
            [dominantCell setProperty:@YES forKey:@"isActive"];
        }

        [mutableSpecifiers addObject:noneCell];
        [mutableSpecifiers addObject:dominantCell];
        [mutableSpecifiers addObject:picker];

		_specifiers = mutableSpecifiers;

        // This will update the preview of the selected value in the parentController
        [((PSListController *)[self parentController]) reloadSpecifiers];
	}

	return _specifiers;
}

-(void)selectOption:(PSSpecifier *)specifier {
    VelvetPrefs *prefs = [VelvetPrefs sharedInstance];
    [prefs setValue:specifier.properties[@"key"] forKey:[self specifier].properties[@"key"]];

    [self reloadSpecifiers];
}

@end