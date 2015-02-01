//
//  DVTSourceTextView+EMDColorPalettes.m
//
//  Created/inspired by Kent Sutherland on 9/10/12 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import "DVTSourceTextView+EMDColorPalettes.h"
#import "MethodSwizzle.h"
#import "EMDColorPalettes.h"

@implementation DVTSourceTextView (EMDColorPalettes)

+ (void)load
{
    MethodSwizzle(self,
                  @selector(shouldAutoCompleteAtLocation:),
                  @selector(emd_shouldAutoCompleteAtLocation:));
}

- (BOOL)emd_shouldAutoCompleteAtLocation:(unsigned long long)arg1
{
    BOOL shouldAutoComplete = [self emd_shouldAutoCompleteAtLocation:arg1];
    
    if (!shouldAutoComplete) {
        @try {
            //Ensure that color autocomplete automatically pops up when you type colorNamed:
            //Search backwards from the current line
            NSRange range = NSMakeRange(0, arg1);
            NSString *string = [[self textStorage] string];
            NSRange newlineRange = [string rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:range];
            NSString *line = string;
            
            if (newlineRange.location != NSNotFound) {
                NSRange lineRange = NSMakeRange(newlineRange.location, arg1 - newlineRange.location);
                
                if (lineRange.location < [line length] && NSMaxRange(lineRange) < [line length]) {
                    line = [string substringWithRange:lineRange];
                }
            }
            
            for (NSString *nextClassAndMethod in [[EMDColorPalettes sharedPlugin] completionStringsForType:UIColorPaletteCompletionStringTypeClassAndMethod]) {
                if ([line hasSuffix:nextClassAndMethod]) {
                    shouldAutoComplete = YES;
                    break;
                }
            }
        } @catch (NSException *exception) {
            //I'd rather not crash if Xcode chokes on something
        }
    }
    
    return shouldAutoComplete;
}

@end
