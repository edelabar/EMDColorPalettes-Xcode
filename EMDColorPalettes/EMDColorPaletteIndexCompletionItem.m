//
//  UIColorPaletteIndexCompletionItem.m
//
//  Created/inspired by Kent Sutherland on 9/10/12 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import "EMDColorPaletteIndexCompletionItem.h"
#import <objc/runtime.h>

@interface UIColorPaletteIndexCompletionItem ()

@property (nonatomic,copy) NSColor *color;

@property (nonatomic,copy) NSString *colorName;
@property (nonatomic,copy) NSString *listName;

@end

@implementation UIColorPaletteIndexCompletionItem

- (id)initWithColorNamed:(NSString *)colorName fromColorList:(NSString *)listName
{
    if ( (self = [super init]) ) {
        
        self.colorName = colorName;
        self.listName = listName;
        
        [self setColor:[[NSColorList colorListNamed:listName] colorWithKey:colorName]];
    }
    return self;
}

- (long long)priority
{
    return 9999;
}

- (NSString *)name
{
    return self.colorName;
}

- (BOOL)notRecommended
{
    return NO;
}

- (DVTSourceCodeSymbolKind *)symbolKind
{
    return nil;
}

- (NSString *)completionText
{
    return [NSString stringWithFormat:@"@\"%@\"", [self displayText]];
}

- (NSString *)displayType
{
    return @"NSString *";
}

- (NSString *)displayText
{
    NSString *displayFormat = @"%@.%@";
    
    return [NSString stringWithFormat:displayFormat, self.listName, self.colorName];
}

- (void)_fillInTheRest
{
    
}


@end
