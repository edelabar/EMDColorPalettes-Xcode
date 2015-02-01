//
//  EMDWorkspace.h
//  EMDColorPalettes
//
//  Created by Eric DeLabar on 1/29/15.
//  Copyright (c) 2015 EricDeLabar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDEWorkspace;
@class EMDProject;

@interface EMDWorkspace : NSObject

@property (strong,nonatomic) IDEWorkspace *workspace;
@property (readonly,nonatomic) BOOL isProject;
@property (readonly,copy,nonatomic) NSArray *projects;

@property (readonly,nonatomic) NSString *path;

- (EMDProject *)projectForFilePath:(NSString *)filePath;

@end
