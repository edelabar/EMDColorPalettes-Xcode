//
//  EMDColorNamedPreviewWindow.m
//
//  Created/inspired by Friedrich Markgraf on 10/03/13 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import "EMDColorNamedPreviewWindow.h"

@interface EMDColorNamedPreviewWindow () {
    NSView *_contentView;
    NSPoint _frameTopRightPoint;
}
@end

@implementation EMDColorNamedPreviewWindow

- (instancetype)init
{
    NSRect frame = NSMakeRect(0.0, 0.0, 50.0, 50.0);
    if ( (self = [super initWithContentRect:frame
                                  styleMask:NSBorderlessWindowMask
                                    backing:NSBackingStoreBuffered
                                      defer:NO]) ) {
        self.hasShadow = YES;
        _frameTopRightPoint = NSMakePoint(10.0, 50.0);
        
        _contentView = [[NSView alloc] initWithFrame:frame];
        self.contentView = _contentView;
    }
    return self;
}

- (void)setColor:(NSColor *)color
{
    _color = color;
    [self _updateDisplay];
}

- (void)setFrameTopRightPoint:(NSPoint)point
{
    _frameTopRightPoint = point;
    [self _updateDisplay];
}

- (void)_updateDisplay
{
    if (!_color) {
        return;
    }
    
    [self setBackgroundColor:_color];
    
    NSRect displayFrame = NSMakeRect(_frameTopRightPoint.x - 50.0,
                                     _frameTopRightPoint.y - 50.0,
                                     50.0,
                                     50.0);
    
    [self setFrame:displayFrame display:YES animate:NO];
}

@end
