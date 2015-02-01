//
//  EMDWrappedPalette.h
//  EMDColorPalettes
//
//  Created by Eric DeLabar on 1/28/15.
//  Copyright (c) 2015 EricDeLabar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface EMDWrappedPalette : NSObject

@property (nonatomic) BOOL selected;
@property (nonatomic,strong) NSColorList *palette;

@end
