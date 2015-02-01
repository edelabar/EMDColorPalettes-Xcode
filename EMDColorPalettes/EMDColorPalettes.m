//
//  EMDColorPalettes.m
//
//  Created/inspired by Kent Sutherland on 9/10/12 for KSImageNamed.
//  Adapted by Eric DeLabar on 1/27/15 for EMDColorPalettes
//

#import "EMDColorPalettes.h"
#import "EMDColorPaletteIndexCompletionItem.h"
#import "EMDSelectedPalettes.h"
#import "XcodeMisc.h"
#import "EMDColorNamedPreviewWindow.h"
#import "WorkspaceUtil.h"
#import "EMDProject.h"
#import "EMDWorkspace.h"

#import <objc/runtime.h>

static EMDColorPalettes *sharedPlugin;

@interface EMDColorPalettes () {
    NSTimer *_updateTimer;
}

@property (nonatomic, strong) NSMutableDictionary *colorCompletions;
@property (nonatomic, strong) NSMutableSet *indexesToUpdate;
@property (nonatomic, strong) EMDColorNamedPreviewWindow *colorWindow;

@property (nonatomic, strong) NSMenuItem *allPalettesMenuItem;
@property (nonatomic, strong) EMDSelectedPalettes *selectedPalettes;

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) WorkspaceUtil *workspaceUtil;

@end

@implementation EMDColorPalettes

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    if ([self shouldLoadPlugin]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

+ (BOOL)shouldLoadPlugin
{
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    
    return currentApplicationName && [currentApplicationName isEqual:@"Xcode"];
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        
        [self setColorCompletions:[NSMutableDictionary dictionary]];
        [self setIndexesToUpdate:[NSMutableSet set]];
        
        [self setSelectedPalettes:[EMDSelectedPalettes new]];
        self.selectedPalettes.availablePalettes = [[NSColorList availableColorLists] copy];
        
        [self addMenuItem];
        
        self.workspaceUtil = [WorkspaceUtil new];
        [self.workspaceUtil addObserver:self forKeyPath:@"currentProject" options:NSKeyValueObservingOptionNew context:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.workspaceUtil removeObserver:self forKeyPath:@"currentProject"];
    
    [self setColorCompletions:nil];
    [self setIndexesToUpdate:nil];
    [self setColorWindow:nil];
    [self setSelectedPalettes:nil];
}

- (EMDColorNamedPreviewWindow *)colorWindow
{
    if (!_colorWindow) {
        _colorWindow = [[EMDColorNamedPreviewWindow alloc] init];
    }
    return _colorWindow;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentProject"] && self.workspaceUtil.currentProject)
    {
        NSLog(@"Update Menu for project: %@",self.workspaceUtil.currentProject.projectDirectoryPath);
        NSDictionary *projectPalettes = [self getPalettesFromFile];
        if (projectPalettes)
        {
            self.selectedPalettes = [[EMDSelectedPalettes alloc] initWithDictionary:projectPalettes];
        }
        else
        {
            self.selectedPalettes = [EMDSelectedPalettes new];
            
        }
        [self updateColorPalettesMenu];
    }
}

#pragma mark UI

- (void)addMenuItem
{
    self.allPalettesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Install Color Palette" action:nil keyEquivalent:@""];
    [self updateColorPalettesMenu];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Color Palettes"];
    [menu addItem:self.allPalettesMenuItem];
    
    NSMenuItem *colorPalettesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Color Palettes" action:nil keyEquivalent:@""];
    [colorPalettesMenuItem setSubmenu:menu];
    
    NSMenuItem *xCodeWindowMenu = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (xCodeWindowMenu) {
        NSInteger organizerMenuItem = [[xCodeWindowMenu submenu] indexOfItemWithTitle:@"Organizer"];
        [[xCodeWindowMenu submenu] insertItem:colorPalettesMenuItem atIndex:organizerMenuItem +1];
    }
}

- (void)updateColorPalettesMenu
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"All Color Palettes"];
    [menu setAutoenablesItems:NO];
    for (NSColorList *list in self.selectedPalettes.availablePalettes)
    {
        NSString *name = list.name;
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:name action:@selector(installColorPaletteMenuSelected:) keyEquivalent:@""];
        [item setTarget:self];
        [item setState:([self.selectedPalettes isPaletteSelected:name] ? NSOnState : NSOffState)];
        [menu addItem:item];
    }
    [self.allPalettesMenuItem setSubmenu:menu];
}

- (void)installColorPaletteMenuSelected:(id)sender
{
    NSMenuItem *selectedPalette = (NSMenuItem *)sender;
    if ([selectedPalette state] == NSOnState)
    {
        [selectedPalette setState:NSOffState];
        [self removePalette:selectedPalette.title];
    }
    else
    {
        [selectedPalette setState:NSOnState];
        [self addPalette:selectedPalette.title];
    }
    
}

#pragma mark Plist management

- (void)removePalette:(NSString *)paletteName
{
    [self.selectedPalettes deselectPalette:paletteName];
    [self updatePalettes];
}

- (void)addPalette:(NSString *)paletteName
{
    [self.selectedPalettes selectPalette:paletteName];
    [self updatePalettes];
}

- (void)updatePalettes
{
    EMDProject *currentProject = self.workspaceUtil.currentProject;
    id /* Xcode3Group */ supportingFilesGroup = [currentProject findGroupNamed:@"Supporting Files"];
    if(supportingFilesGroup) {
        
        [self writePalettesToGroup:supportingFilesGroup inProject:currentProject];
        
    }
}

- (NSDictionary *)getPalettesFromFile
{
    EMDProject *currentProject = self.workspaceUtil.currentProject;
    id /* Xcode3Group */ supportingFilesGroup = [currentProject findGroupNamed:@"Supporting Files"];
    if(supportingFilesGroup) {
        
        return [currentProject readFileNamed:@"ColorPalettes.plist" inGroup:supportingFilesGroup];
        
    }
    return nil;
}

- (void)writePalettesToGroup:(id /* Xcode3Group */)group inProject:(EMDProject *)project {
    
    id fileItem = [project fileItemNamed:@"ColorPalettes.plist" inGroup:group];
    BOOL fileExists = fileItem != nil;
    
    NSDictionary *palettesDictionary = [self.selectedPalettes asDictionary];
    NSURL *urlToFile = [project writeFileNamed:@"ColorPalettes.plist" inGroup:group withDictionary:palettesDictionary];
    
    if (!fileExists)
    {
        PBXGroup *pbxGroup = [group group];
        NSArray *fileReferences = [pbxGroup addFiles:@[[urlToFile path]] copy:NO createGroupsRecursively:NO];
        [project addFileToCopyBundleResourcesPhase:fileReferences[0]];
    }
}

#pragma mark NSColorList indexing

- (void)indexNeedsUpdate:(id)index
{
    //Coalesce completion rebuilds to avoid hangs when Xcode rebuilds an index one file a time
    [[self indexesToUpdate] addObject:index];
    
    [_updateTimer invalidate];
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(_rebuildCompletionsTimerFired:) userInfo:nil repeats:NO];
}

- (void)removeColorCompletionsForIndex:(id)index
{
    NSString *workspaceName = [index workspaceName];
    
    if (workspaceName && [[self colorCompletions] objectForKey:workspaceName]) {
        [[self colorCompletions] removeObjectForKey:workspaceName];
    }
}

- (NSArray *)colorCompletionsForIndex:(id)index
{
    NSArray *completions = [[self colorCompletions] objectForKey:[index workspaceName]];
    
    if (!completions) {
        completions = [self _rebuildCompletionsForIndex:index];
    }
    
    return completions;
}

- (NSSet *)completionStringsForType:(UIColorPaletteCompletionStringType)type
{
    //Pulls completions out of Completions.plist and creates arrays so the rest of the plugin can do lookups to see if it should be autocompleting a particular method
    //The three different strings are needed because this plugin does raw string matching rather than doing anything fancy like looking at the AST
    static NSMutableSet *classAndMethodCompletionStrings;
    static NSMutableSet *methodDeclarationCompletionStrings;
    static NSMutableSet *methodNameCompletionStrings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *completionsURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"Completions" withExtension:@"plist"];
        NSArray *completionStrings = [NSArray arrayWithContentsOfURL:completionsURL];
        
        classAndMethodCompletionStrings = [[NSMutableSet alloc] init];
        methodDeclarationCompletionStrings = [[NSMutableSet alloc] init];
        methodNameCompletionStrings = [[NSMutableSet alloc] init];
        
        for (NSDictionary *nextCompletionDictionary in completionStrings) {
            [classAndMethodCompletionStrings addObject:[nextCompletionDictionary objectForKey:@"classAndMethod"]];
            [methodDeclarationCompletionStrings addObject:[nextCompletionDictionary objectForKey:@"methodDeclaration"]];
            [methodNameCompletionStrings addObject:[nextCompletionDictionary objectForKey:@"methodName"]];
        }
    });
    
    NSSet *completionStrings = nil;
    
    if (type == UIColorPaletteCompletionStringTypeClassAndMethod) {
        completionStrings = classAndMethodCompletionStrings;
    } else if (type == UIColorPaletteCompletionStringTypeMethodDeclaration) {
        completionStrings = methodDeclarationCompletionStrings;
    } else if (type == UIColorPaletteCompletionStringTypeMethodName) {
        completionStrings = methodNameCompletionStrings;
    }
    
    return completionStrings;
}

#pragma mark - Private

- (void)_rebuildCompletionsTimerFired:(NSTimer *)timer
{
    for (id nextIndex in [self indexesToUpdate]) {
        [self _rebuildCompletionsForIndex:nextIndex];
    }
    
    [[self indexesToUpdate] removeAllObjects];
    
    _updateTimer = nil;
}

- (NSArray *)_rebuildCompletionsForIndex:(id)index
{
    NSString *workspaceName = [index workspaceName];
    NSArray *completions = nil;
    
    if (workspaceName) {
        if ([[self colorCompletions] objectForKey:workspaceName]) {
            [[self colorCompletions] removeObjectForKey:workspaceName];
        }
        
        completions = [self _colorCompletionsForIndex:index];
        
        if (completions) {
            [[self colorCompletions] setObject:completions forKey:workspaceName];
        }
    }
    
    return completions;
}

- (NSArray *)_colorCompletionsForIndex:(id)index
{
    NSMutableArray *completionItems = [NSMutableArray array];
    NSMutableDictionary *colorCompletionItems = [NSMutableDictionary dictionary];
    
    self.selectedPalettes.availablePalettes = [[NSColorList availableColorLists] copy];
    for (NSColorList *list in self.selectedPalettes.selectedPalettes)
    {
        for (NSString *colorName in list.allKeys)
        {
            NSString *colorKey = [NSString stringWithFormat:@"%@.%@",list.name,colorName];
            if (![colorCompletionItems objectForKey:colorKey]) {
                
                UIColorPaletteIndexCompletionItem *colorCompletion = [[UIColorPaletteIndexCompletionItem alloc] initWithColorNamed:colorName fromColorList:list.name];
                
                [completionItems addObject:colorCompletion];
                [colorCompletionItems setObject:colorCompletion forKey:colorKey];
                
            }
        }
    }
    
    [self updateColorPalettesMenu];
    
    return completionItems;
}
    

@end
