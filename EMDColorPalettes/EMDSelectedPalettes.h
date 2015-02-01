//
//  EMDSelectedPalettes.h
//  EMDColorPalettes
//
//  Created by Eric DeLabar on 1/28/15.
//  Copyright (c) 2015 EricDeLabar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMDSelectedPalettes : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic,copy) NSArray *availablePalettes;
@property (nonatomic,readonly,copy) NSArray *selectedPalettes;

- (BOOL)isPaletteSelected:(NSString *)paletteName;
- (void)selectPalette:(NSString *)paletteName;
- (void)deselectPalette:(NSString *)paletteName;

- (NSDictionary *)asDictionary;

@end
