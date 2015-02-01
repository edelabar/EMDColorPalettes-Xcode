//
//  WorkspaceUtil.m
//  EMDColorPalettes
//
//  Created by Eric DeLabar on 1/29/15.
//  Copyright (c) 2015 EricDeLabar. All rights reserved.
//

#import "WorkspaceUtil.h"
#import "XcodeMisc.h"
#import "EMDWorkspace.h"
#import "EMDProject.h"
#import <objc/runtime.h>

static NSString * const IDEEditorDocumentDidChangeNotification = @"IDEEditorDocumentDidChangeNotification";

@interface WorkspaceUtil ()

@property (strong,nonatomic) NSMutableDictionary *currentProjectIndex;
@property (strong,nonatomic) NSMutableDictionary *workspaceIndex;
@property (strong,nonatomic) NSMutableArray *orphanedDocuments;
@property (copy,nonatomic) NSString *currentWorkspacePath;

@end

@implementation WorkspaceUtil

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(workspaceWindowDidBecomeMain:)
                                                     name:NSWindowDidBecomeMainNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(documentDidChange:)
                                                     name:IDEEditorDocumentDidChangeNotification
                                                   object:nil];
        
        self.workspaceIndex = [NSMutableDictionary new];
        self.currentProjectIndex = [NSMutableDictionary new];
        self.orphanedDocuments = [NSMutableArray new];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)workspaceWindowDidBecomeMain:(NSNotification *)notification
{
    EMDWorkspace *xcworkspace = [self workspaceFromWindowNotification:notification];
    if (xcworkspace && self.currentWorkspacePath)
    {
        [self willChangeValueForKey:@"currentProject"];
        [self willChangeValueForKey:@"currentWorkspace"];
        
        self.currentWorkspacePath = xcworkspace.path;
        self.workspaceIndex[self.currentWorkspacePath] = xcworkspace;
        
        [self didChangeValueForKey:@"currentWorkspace"];
        
        if (!self.currentProject && [self.orphanedDocuments count])
        {
            for (NSString *documentPath in self.orphanedDocuments)
            {
                EMDProject *project = [self.currentWorkspace projectForFilePath:documentPath];
                
                if (project) {
                    self.currentProjectIndex[self.currentWorkspacePath] = project;
                    [self.orphanedDocuments removeObject:documentPath];
                    break;
                }
            }
        }
        
        [self didChangeValueForKey:@"currentProject"];
    }
}

- (EMDWorkspace *)workspaceFromWindowNotification:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:objc_getClass("IDEWorkspaceWindow")]) {
        NSWindow *workspaceWindow = (NSWindow *)[notification object];
        NSWindowController *workspaceWindowController = (NSWindowController *)workspaceWindow.windowController;
        IDEWorkspace *workspace = (IDEWorkspace *)[workspaceWindowController valueForKey:@"_workspace"];
        
        EMDWorkspace *wrappedWorkspace = [EMDWorkspace new];
        wrappedWorkspace.workspace = workspace;
        
        return wrappedWorkspace;
    }
    return nil;
}

- (void)documentDidChange:(NSNotification *)notification
{
    id currentDocument /*IDESourceCodeDocument*/ = notification.object;
    id currentDocumentPath /*DVTFilePath*/ = [currentDocument filePath];
    
    EMDProject *project = [self.currentWorkspace projectForFilePath:[currentDocumentPath pathString]];
    
    if (project) {
        [self willChangeValueForKey:@"currentProject"];
        
        self.currentProjectIndex[self.currentWorkspacePath] = project;
        
        [self didChangeValueForKey:@"currentProject"];
    } else {
        [self.orphanedDocuments addObject:[currentDocumentPath pathString]];
    }
}

- (EMDWorkspace *)currentWorkspace
{
    return self.workspaceIndex[self.currentWorkspacePath];
}

- (EMDProject *)currentProject
{
    return self.currentProjectIndex[self.currentWorkspacePath];
}

@end
