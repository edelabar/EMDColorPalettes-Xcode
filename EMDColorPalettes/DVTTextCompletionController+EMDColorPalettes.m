//
//  DVTTextCompletionController+EMDColorPalettes.m
//
//  Created/inspired by Kent Sutherland on 9/10/12 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import "DVTTextCompletionController+EMDColorPalettes.h"
#import "MethodSwizzle.h"
#import "EMDColorPalettes.h"
#import "EMDColorPaletteIndexCompletionItem.h"

@implementation DVTTextCompletionController (EMDColorPalettes)

+ (void)load
{
    MethodSwizzle(self, @selector(acceptCurrentCompletion), @selector(emd_acceptCurrentCompletion));
}

- (BOOL)emd_acceptCurrentCompletion
{
    BOOL success = [self emd_acceptCurrentCompletion];
    
    if (success) {
        @try {
            NSRange range = [[self textView] selectedRange];
            
            for (NSString *nextClassAndMethod in [[EMDColorPalettes sharedPlugin] completionStringsForType:UIColorPaletteCompletionStringTypeClassAndMethod]) {
                //If an autocomplete causes colorNamed: to get inserted, remove the token and immediately pop up autocomplete
                if (range.location > [nextClassAndMethod length]) {
                    NSString *insertedString = [[[self textView] string] substringWithRange:NSMakeRange(range.location - [nextClassAndMethod length], [nextClassAndMethod length])];
                    
                    if ([insertedString isEqualToString:nextClassAndMethod]) {
                        [[self textView] insertText:@"" replacementRange:range];
                        [self _showCompletionsAtCursorLocationExplicitly:YES];
                    }
                }
            }
        } @catch (NSException *exception) {
            //I'd rather not crash if Xcode chokes on something
        }
    }
    
    return success;
}

@end
