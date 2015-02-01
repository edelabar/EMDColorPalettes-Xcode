//
//  IDEWorkspace+EMDColorPalettes.m
//
//  Created/inspired by Kent Sutherland on 9/10/12 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import "IDEWorkspace+EMDColorPalettes.h"
#import "MethodSwizzle.h"
#import "EMDColorPalettes.h"

@implementation IDEWorkspace (EMDColorPalettes)

+ (void)load
{
    MethodSwizzle(self, @selector(_updateIndexableFiles:), @selector(emd__updateIndexableFiles:));
}

- (void)emd__updateIndexableFiles:(id)arg1
{
    [self emd__updateIndexableFiles:arg1];
    
    [[EMDColorPalettes sharedPlugin] indexNeedsUpdate:[self index]];
}

@end
