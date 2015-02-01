//
//  EMDWorkspace.m
//  EMDColorPalettes
//
//  Created by Eric DeLabar on 1/29/15.
//  Copyright (c) 2015 EricDeLabar. All rights reserved.
//

#import "EMDWorkspace.h"
#import "XcodeMisc.h"
#import "EMDProject.h"

@interface EMDWorkspace ()

@property (copy,nonatomic) NSArray *projects;

@end

@implementation EMDWorkspace

- (void)setWorkspace:(IDEWorkspace *)workspace
{
    [self willChangeValueForKey:@"workspace"];
    _workspace = workspace;
    
    if (workspace)
    {
        NSMutableArray *projects = [NSMutableArray new];
        NSSet *containers = [workspace referencedContainers];
        for (id container in containers)
        {
            if ([container isMemberOfClass:NSClassFromString(@"Xcode3Project")])
            {
                EMDProject *project = [[EMDProject alloc] initWithXcode3Project:container];
                [projects addObject:project];
            }
        }
        self.projects = [projects copy];
    }
    
    [self didChangeValueForKey:@"workspace"];
}

- (NSString *)path
{
    return self.workspace.representingFilePath.pathString;
}

- (BOOL)isProject
{
    NSURL *fileURL = [NSURL fileURLWithPath:self.workspace.representingFilePath.pathString];
    return [self isProject:fileURL];
}

- (EMDProject *)projectForFilePath:(NSString *)filePath
{
    for (EMDProject *project in self.projects)
    {
        if ([filePath hasPrefix:project.projectDirectoryPath])
        {
            return project;
        }
    }
    return nil;
}

- (BOOL)isProject:(NSURL *)fileURL
{
    return [fileURL.pathExtension isEqualToString:@"xcodeproj"];
}

@end
