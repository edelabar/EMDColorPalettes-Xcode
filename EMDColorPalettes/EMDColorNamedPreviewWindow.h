//
//  EMDColorNamedPreviewWindow.h
//
//  Created/inspired by Friedrich Markgraf on 10/03/13 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import <Cocoa/Cocoa.h>

@interface EMDColorNamedPreviewWindow : NSWindow

@property (nonatomic, strong) NSColor *color;

- (void)setFrameTopRightPoint:(NSPoint)point;

@end
