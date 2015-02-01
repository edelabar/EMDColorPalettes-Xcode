//
//  EMDProject.m
//  EMDColorPalettes
//
//  Created by Eric DeLabar on 1/29/15.
//  Copyright (c) 2015 EricDeLabar. All rights reserved.
//

#import "EMDProject.h"
#import "XcodeMisc.h"

@interface EMDProject ()

@property (nonatomic,copy) NSURL *projectFileURL;
@property (nonatomic,readonly) NSString *sourceDirectory;

@end

@implementation EMDProject

- (instancetype)initWithXcode3Project:(Xcode3Project *)container
{
    self = [super init];
    if (self) {
        _xcodeProject = [container pbxProject];
        _sourceDirectory = [[self.xcodeProject path] stringByDeletingPathExtension];
        _rootGroup = [container rootGroup];
        _projectFileURL = [NSURL fileURLWithPath:_xcodeProject.path];
    }
    return self;
}

- (NSString *)projectDirectoryPath
{
    return [[self.projectFileURL URLByDeletingLastPathComponent] path];
}

- (id) findGroupNamed:(NSString *)targetName {
    return [self findGroupNamed:targetName fromRoot:self.rootGroup];
}
 
// breadth first search for the first hit for targetName
- (id) findGroupNamed:(NSString *)targetName fromRoot:(id /* Xcode3Group */)root {
    
    if(root == nil) return nil;
    
    NSMutableArray * queue = [[NSMutableArray alloc] init];
    [queue addObject:root];
    
    while([queue count] > 0) {
        id node = [queue objectAtIndex:0];
        [queue removeObjectAtIndex:0];
        
        NSString * nodeName = [node name];
        if([nodeName caseInsensitiveCompare:targetName] == NSOrderedSame) {
            return node;
        } else {
            if([node respondsToSelector:@selector(subitems)]) {
                NSArray * subitems = [node subitems];
                for(id item in subitems) {
                    [queue addObject:item];
                }
            }
        }
    }
    
    return nil;
}

- (BOOL) group:(id /* Xcode3Group */)group containsGroupNamed:(NSString *)targetName {
    
    BOOL found = NO;
    if([group respondsToSelector:@selector(subitems)]) {
        NSArray * subitems = [group subitems];
        for(id item in subitems) {
            if([[item name] caseInsensitiveCompare:targetName] == NSOrderedSame) {
                found = YES;
                break;
            }
        }
    }
    
    return found;
}

/// Returns Xcode3FileReference for the file if it exists
- (id)fileItemNamed:(NSString *)fileName inGroup:(id /* Xcode3Group */)group
{
    if([group respondsToSelector:@selector(subitems)]) {
        NSArray *subitems = [group subitems];
        for(id /*Xcode3FileReference*/ item in subitems) {
            if([[item name] caseInsensitiveCompare:fileName] == NSOrderedSame) {
                return item;
            }
        }
    }
    return nil;
}

- (NSURL *)urlToFileNamed:(NSString *)fileName inGroup:(id /* Xcode3Group */)group
{
    NSString *pathToFile;
    if ([[group path] length])
    {
        pathToFile = [NSString stringWithFormat:@"%@/%@/%@",self.sourceDirectory,[group path],fileName];
    }
    else
    {
        pathToFile = [NSString stringWithFormat:@"%@/%@",self.sourceDirectory,fileName];
    }
    return[[NSURL fileURLWithPath:pathToFile] standardizedURL];
}

- (NSDictionary *)readFileNamed:(NSString *)fileName inGroup:(id /* Xcode3Group */)group
{
    NSDictionary *dictionary;
    
    id item = [self fileItemNamed:fileName inGroup:group];
    if (item)
    {
        NSURL *urlToFile = [self urlToFileNamed:fileName inGroup:group];
        
        dictionary = [[NSDictionary alloc] initWithContentsOfURL:urlToFile];
    }
    
    return dictionary;
}

- (NSURL *)writeFileNamed:(NSString *)fileName inGroup:(id /* Xcode3Group */)group withDictionary:(NSDictionary *)dictionary
{
    NSURL *urlToFile = [self urlToFileNamed:fileName inGroup:group];
    
    [dictionary writeToURL:urlToFile atomically:YES];
    return urlToFile;
}

- (void)addFileToCopyBundleResourcesPhase:(id)fileReference
{
    for(id target in [self.xcodeProject targets]) {
        
        // try to find the copy files build phase, for if we need to add any frameworks to it (e.g. Syphon)
        NSArray * buildPhases = [target buildPhases];
        NSUInteger copyPhaseIdx = [buildPhases indexOfObjectPassingTest:^BOOL(PBXBuildPhase *buildPhase, NSUInteger i, BOOL *s) {
            return [[buildPhase name] isEqualTo:[PBXResourcesBuildPhase defaultName]];
        }];
        
        PBXResourcesBuildPhase *copyPhase = nil;
        
        if (copyPhaseIdx != NSNotFound) {
            copyPhase = buildPhases[copyPhaseIdx];
            [copyPhase addReference:fileReference];
        }
    }

}

@end
