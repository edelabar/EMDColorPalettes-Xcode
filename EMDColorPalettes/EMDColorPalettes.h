//
//  EMDColorPalettes.h
//
//  Created/inspired by Kent Sutherland on 9/10/12 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import <AppKit/AppKit.h>

typedef NS_ENUM(NSInteger, UIColorPaletteCompletionStringType) {
    UIColorPaletteCompletionStringTypeClassAndMethod = 0,
    UIColorPaletteCompletionStringTypeMethodDeclaration = 1,
    UIColorPaletteCompletionStringTypeMethodName = 2,
};

@class EMDColorNamedPreviewWindow;

@interface EMDColorPalettes : NSObject

+ (instancetype)sharedPlugin;
+ (BOOL)shouldLoadPlugin;

@property (nonatomic, strong, readonly) NSBundle *bundle;
@property (nonatomic, strong, readonly)  EMDColorNamedPreviewWindow *colorWindow;

- (void)indexNeedsUpdate:(id)index; //IDEIndex
- (void)removeColorCompletionsForIndex:(id)index; //IDEIndex
- (NSArray *)colorCompletionsForIndex:(id)index; //IDEIndex

- (NSSet *)completionStringsForType:(UIColorPaletteCompletionStringType)type;

@end