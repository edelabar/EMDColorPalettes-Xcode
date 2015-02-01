//
//  WorkspaceUtil.h
//  EMDColorPalettes
//
//  Created by Eric DeLabar on 1/29/15.
//  Copyright (c) 2015 EricDeLabar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMDWorkspace;
@class EMDProject;

@interface WorkspaceUtil : NSObject

@property (nonatomic,readonly) EMDWorkspace *currentWorkspace;
@property (nonatomic,readonly) EMDProject *currentProject;

@end
