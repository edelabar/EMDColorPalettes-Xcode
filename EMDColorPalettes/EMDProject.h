//
//  EMDProject.h
//  EMDColorPalettes
//
//  Created by Eric DeLabar on 1/29/15.
//  Copyright (c) 2015 EricDeLabar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Xcode3Project;
@class PBXProject;

@interface EMDProject : NSObject

- (instancetype)initWithXcode3Project:(Xcode3Project *)project;

@property (readonly,nonatomic) id /* Xcode3Group */ rootGroup;
@property (readonly,nonatomic) PBXProject *xcodeProject;
@property (readonly,nonatomic) NSString *projectDirectoryPath;

- (id)findGroupNamed:(NSString *)targetName;
- (id)findGroupNamed:(NSString *)targetName fromRoot:(id /* Xcode3Group */)root;
- (BOOL)group:(id /* Xcode3Group */)group containsGroupNamed:(NSString *)targetName;

- (id /* Xcode3FileReference */)fileItemNamed:(NSString *)fileName inGroup:(id /* Xcode3Group */)group;
- (NSDictionary *)readFileNamed:(NSString *)fileName inGroup:(id /* Xcode3Group */)group;
- (NSURL *)writeFileNamed:(NSString *)fileName inGroup:(id /* Xcode3Group */)group withDictionary:(NSDictionary *)data;

- (void)addFileToCopyBundleResourcesPhase:(id)fileReference;

@end
