#import "Headers.h"

@implementation VelvetBackgroundView
@end

@implementation VelvetIndicatorView
@end

@implementation NSNotificationCenter (Velvet)

- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object {

        [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:object];
        [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];

}

@end