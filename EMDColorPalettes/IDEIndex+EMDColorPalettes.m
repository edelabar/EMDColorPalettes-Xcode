//
//  IDEIndex+EMDColorPalettes.m
//
//  Created/inspired by Kent Sutherland on 9/10/12 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import "IDEIndex+EMDColorPalettes.h"
#import "MethodSwizzle.h"
#import "EMDColorPalettes.h"

@implementation IDEIndex (EMDColorPalettes)

+ (void)load
{
    MethodSwizzle(self, @selector(close), @selector(emd_close));
}

- (void)emd_close
{
    [[EMDColorPalettes sharedPlugin] removeColorCompletionsForIndex:self];
    
    [self emd_close];
}

@end
