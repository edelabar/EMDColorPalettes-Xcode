//
//  IDEIndexCompletionStrategy+EMDColorPalettes.m
//
//  Created/inspired by Kent Sutherland on 9/10/12 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import "IDEIndexCompletionStrategy+EMDColorPalettes.h"
#import "EMDColorPalettes.h"
#import "MethodSwizzle.h"


@implementation IDEIndexCompletionStrategy (EMDColorPalettes)

+ (void)load
{
    // Xcode 5 completion method
    MethodSwizzle(self,
                  @selector(completionItemsForDocumentLocation:context:areDefinitive:),
                  @selector(emd_completionItemsForDocumentLocation:context:areDefinitive:));
    
    // Xcode 6 completion method
    MethodSwizzle(self,
                  @selector(completionItemsForDocumentLocation:context:highlyLikelyCompletionItems:areDefinitive:),
                  @selector(emd_completionItemsForDocumentLocation:context:highlyLikelyCompletionItems:areDefinitive:));
}

/*
 arg1 = DVTTextDocumentLocation
 arg2 = NSDictionary
 DVTTextCompletionContextSourceCodeLanguage <DVTSourceCodeLanguage>
 DVTTextCompletionContextTextStorage <DVTTextStorage>
 DVTTextCompletionContextTextView <DVTSourceTextView>
 IDETextCompletionContextDocumentKey <IDESourceCodeDocument>
 IDETextCompletionContextEditorKey <IDESourceCodeEditor>
 IDETextCompletionContextPlatformFamilyNamesKey (macosx, iphoneos?)
 IDETextCompletionContextUnsavedDocumentStringsKey <NSDictionary>
 IDETextCompletionContextWorkspaceKey <IDEWorkspace>
 arg3 = unsure, not changing it
 returns = IDEIndexCompletionArray
 */
- (id)emd_completionItemsForDocumentLocation:(id)arg1 context:(id)arg2 areDefinitive:(char *)arg3
{
    id items = [self emd_completionItemsForDocumentLocation:arg1 context:arg2 areDefinitive:arg3];
    id sourceTextView = [arg2 objectForKey:@"DVTTextCompletionContextTextView"];
    DVTCompletingTextView *textStorage = [arg2 objectForKey:@"DVTTextCompletionContextTextStorage"];
    
    [self emdcolorpalettes_checkForColorCompletionItems:items sourceTextView:sourceTextView textStorage:textStorage];
    
    return items;
}

- (id)emd_completionItemsForDocumentLocation:(id)arg1 context:(id)arg2 highlyLikelyCompletionItems:(id *)arg3 areDefinitive:(char *)arg4
{
    id items = [self emd_completionItemsForDocumentLocation:arg1 context:arg2 highlyLikelyCompletionItems:arg3 areDefinitive:arg4];
    id sourceTextView = [arg2 objectForKey:@"DVTTextCompletionContextTextView"];
    DVTCompletingTextView *textStorage = [arg2 objectForKey:@"DVTTextCompletionContextTextStorage"];
    
    [self emdcolorpalettes_checkForColorCompletionItems:items sourceTextView:sourceTextView textStorage:textStorage];
    
    return items;
}

// Returns void because this modifies items in place
- (void)emdcolorpalettes_checkForColorCompletionItems:(id)items sourceTextView:(id)sourceTextView textStorage:(id)textStorage
{
    void(^buildColorCompletions)() = ^{
        NSRange selectedRange = [sourceTextView selectedRange];
        
        @try {
            NSString *string = [textStorage string];
            id item;
            
            //Xcode 5.1 added sourceModelService and moved sourceModelItemAtCharacterIndex: into it
            if ([textStorage respondsToSelector:@selector(sourceModelItemAtCharacterIndex:)]) {
                item = [textStorage sourceModelItemAtCharacterIndex:selectedRange.location];
            } else {
                item = [[textStorage sourceModelService] sourceModelItemAtCharacterIndex:selectedRange.location];
            }
            
            id previousItem = [item previousItem];
            NSString *itemString = nil;
            BOOL atColorNamed = NO;
            
            if (item) {
                NSRange itemRange = [item range];
                
                if (NSMaxRange(itemRange) > selectedRange.location) {
                    itemRange.length -= NSMaxRange(itemRange) - selectedRange.location;
                }
                
                itemString = [string substringWithRange:itemRange];
                
                //Limit search to a single line
                //itemRange can be massive in some situations, such as -(void)<autocomplete>
                NSRange newlineRange = [itemString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
                
                if (newlineRange.location != NSNotFound) {
                    itemRange.length = itemRange.length - newlineRange.location;
                    itemRange.location = itemRange.location + newlineRange.location;
                    
                    //Extra range check to prevent huge itemRange.location
                    //Checking length and NSMaxRange in case NSMaxRange overflows
                    if (itemRange.length < [string length] && NSMaxRange(itemRange) < [string length]) {
                        itemString = [string substringWithRange:itemRange];
                    }
                }
                
                for (NSString *nextMethodDeclaration in [[EMDColorPalettes sharedPlugin] completionStringsForType:UIColorPaletteCompletionStringTypeMethodDeclaration]) {
                    NSRange colorNamedRange = [itemString rangeOfString:nextMethodDeclaration];
                    
                    if (colorNamedRange.location != NSNotFound) {
                        atColorNamed = YES;
                        
                        //We might be past colorNamed, such as 'colorNamed:@"name"] draw<insertion point>'
                        //For now just check if the insertion point is past the closing bracket. This won't work if an image has a bracket in the name and other edge cases.
                        //It'd probably be cleaner to use the source model to determine this
                        NSRange closeBracketRange = [itemString rangeOfString:@"]" options:0 range:NSMakeRange(colorNamedRange.location, [itemString length] - colorNamedRange.location)];
                        
                        if (closeBracketRange.location != NSNotFound) {
                            atColorNamed = NO;
                        }
                    }
                }
            }
            
            if (!atColorNamed && previousItem) {
                NSRange previousItemRange = [previousItem range];
                
                if (NSMaxRange(previousItemRange) > selectedRange.location) {
                    previousItemRange.length -= NSMaxRange(previousItemRange) - selectedRange.location;
                }
                
                //Enlarge previousItemRange to ensure we're at a method call and not a variable declaration or something else
                //For example, previousItemRange could be hitting a variable declaration such as "UIColor *colorNamed = ["
                if (previousItemRange.location > 0) {
                    previousItemRange.location--;
                    previousItemRange.length += 2;
                }
                
                NSString *previousItemString = [string substringWithRange:previousItemRange];
                
                if ([[[EMDColorPalettes sharedPlugin] completionStringsForType:UIColorPaletteCompletionStringTypeMethodDeclaration] containsObject:previousItemString]) {
                    atColorNamed = YES;
                }
            }
            
            if (atColorNamed) {
                //Find index
                id document = [[[sourceTextView window] windowController] document];
                id index = [((IDEWorkspace *)[document workspace]) index];
                NSArray *completions = [[EMDColorPalettes sharedPlugin] colorCompletionsForIndex:index];
                
                if ([completions count] > 0) {
                    [items removeAllObjects];
                    [items addObjectsFromArray:completions];
                }
            }
        } @catch (NSException *exception) {
            //Handle this or something
        }
    };
    
    //Ensure this runs on the main thread since we're using NSTextStorage
    if ([NSThread isMainThread]) {
        buildColorCompletions();
    } else {
        dispatch_sync(dispatch_get_main_queue(), buildColorCompletions);
    }
}


@end
