//
//  DVTTextCompletionListWindowController+EMDColorPalettes.m
//
//  Created/inspired by Jack Chen on 10/24/13 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import "DVTTextCompletionListWindowController+EMDColorPalettes.h"
#import "MethodSwizzle.h"
#import "EMDColorPalettes.h"
#import "EMDColorPaletteIndexCompletionItem.h"
#import "EMDColorNamedPreviewWindow.h"

@implementation DVTTextCompletionListWindowController (EMDColorPalettes)

+ (void)load
{
    MethodSwizzle(self, @selector(showInfoPaneForCompletionItem:), @selector(emd_showInfoPaneForCompletionItem:));
    MethodSwizzle(self, @selector(_hideWindow), @selector(emd__hideWindow));
}

- (void)emd_showInfoPaneForCompletionItem:(id)item
{
    [self emd_showInfoPaneForCompletionItem:item];
    
    if ([item isKindOfClass:[UIColorPaletteIndexCompletionItem class]]) {
        UIColorPaletteIndexCompletionItem *paletteItem = (UIColorPaletteIndexCompletionItem *)item;
        NSColor *color = paletteItem.color;
        [self showPreviewForColor:color];
    }
}

- (void)emd__hideWindow
{
    [[EMDColorPalettes sharedPlugin].colorWindow orderOut:self];
    [self emd__hideWindow];
}

- (void)showPreviewForColor:(NSColor *)color
{
    EMDColorNamedPreviewWindow *colorWindow = [EMDColorPalettes sharedPlugin].colorWindow;
    colorWindow.color = color;
    
    if (!color) {
        [colorWindow orderOut:self];
    } else {
        NSRect imgRect = NSMakeRect(0.0, 0.0, 50.0, 50.0);
        NSWindow *completionListWindow = [self window];
        
        if ([completionListWindow isVisible]) {
            NSRect completionListWindowFrame = completionListWindow ? completionListWindow.frame : NSMakeRect(imgRect.size.width, imgRect.size.height, 0.0, 0.0);
            
            [colorWindow setFrameTopRightPoint:NSMakePoint(completionListWindowFrame.origin.x - 1.0,
                                                           completionListWindowFrame.origin.y + completionListWindowFrame.size.height)];
            
            [[NSApp keyWindow] addChildWindow:colorWindow ordered:NSWindowAbove];
        }
    }
}

@end
