//
//  UIColorPaletteIndexCompletionItem.h
//
//  Created/inspired by Kent Sutherland on 9/10/12 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface DVTSourceCodeSymbolKind : NSObject
{
    NSString *_identifier;
    NSString *_localizedDescription;
    NSArray *_conformedToSymbolKindIdentifiers;
    NSArray *_conformedToSymbolKinds;
    NSArray *_allConformingSymbolKinds;
}

+ (id)sourceCodeSymbolKinds;
+ (id)sourceCodeSymbolKindForIdentifier:(id)arg1;
+ (id)_sourceCodeSymbolKindForExtension:(id)arg1;
+ (void)initialize;
+ (id)classMethodTemplateSymbolKind;
+ (id)instanceMethodTemplateSymbolKind;
+ (id)functionTemplateSymbolKind;
+ (id)classTemplateSymbolKind;
+ (id)namespaceSymbolKind;
+ (id)ibOutletCollectionPropertySymbolKind;
+ (id)ibOutletCollectionVariableSymbolKind;
+ (id)ibOutletCollectionSymbolKind;
+ (id)ibOutletPropertySymbolKind;
+ (id)ibOutletVariableSymbolKind;
+ (id)ibOutletSymbolKind;
+ (id)ibActionMethodSymbolKind;
+ (id)globalVariableSymbolKind;
+ (id)localVariableSymbolKind;
+ (id)unionSymbolKind;
+ (id)typedefSymbolKind;
+ (id)structSymbolKind;
+ (id)protocolSymbolKind;
+ (id)propertySymbolKind;
+ (id)parameterSymbolKind;
+ (id)macroSymbolKind;
+ (id)classVariableSymbolKind;
+ (id)instanceVariableSymbolKind;
+ (id)instanceMethodSymbolKind;
+ (id)functionSymbolKind;
+ (id)fieldSymbolKind;
+ (id)enumConstantSymbolKind;
+ (id)enumSymbolKind;
+ (id)classSymbolKind;
+ (id)classMethodSymbolKind;
+ (id)categorySymbolKind;
+ (id)memberContainerSymbolKind;
+ (id)memberSymbolKind;
+ (id)callableSymbolKind;
+ (id)globalSymbolKind;
+ (id)containerSymbolKind;
@property(readonly) NSString *localizedDescription; // @synthesize localizedDescription=_localizedDescription;
@property(readonly) NSString *identifier; // @synthesize identifier=_identifier;
- (BOOL)conformsToSymbolKind:(id)arg1;
@property(readonly, getter=isContainer) BOOL container;
@property(readonly) NSArray *allConformingSymbolKinds;
@property(readonly) NSArray *conformedToSymbolKinds;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)description;
- (id)initWithSourceCodeSymbolKindExtension:(id)arg1;

@end

@interface IDEIndexCompletionItem : NSObject
{
    void *_completionResult;
    NSString *_displayText;
    NSString *_displayType;
    NSString *_completionText;
    DVTSourceCodeSymbolKind *_symbolKind;
    long long _priority;
    NSString *_name;
}

@property long long priority; // @synthesize priority=_priority;
@property(readonly) NSString *name; // @synthesize name=_name;
@property(readonly) BOOL notRecommended;
@property(readonly) DVTSourceCodeSymbolKind *symbolKind;
@property(readonly) NSAttributedString *descriptionText;
@property(readonly) NSString *completionText;
@property(readonly) NSString *displayType;
@property(readonly) NSString *displayText;
- (void)_fillInTheRest;
- (id)description;
- (id)initWithCompletionResult:(void *)arg1;

@end

@interface UIColorPaletteIndexCompletionItem : IDEIndexCompletionItem

- (id)initWithColorNamed:(NSString *)colorName fromColorList:(NSString *)listName;

@property (nonatomic,copy,readonly) NSColor *color;

@end
