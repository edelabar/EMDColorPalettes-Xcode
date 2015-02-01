//
//  EMDSelectedPalettes.m
//  EMDColorPalettes
//
//  Created by Eric DeLabar on 1/28/15.
//  Copyright (c) 2015 EricDeLabar. All rights reserved.
//

#import "EMDSelectedPalettes.h"
#import <AppKit/AppKit.h>
#import "EMDWrappedPalette.h"

@interface EMDSelectedPalettes ()

@property (nonatomic,copy) NSArray *selectedPalettes;
@property (nonatomic,copy) NSDictionary *palettes;

@end

@implementation EMDSelectedPalettes

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.availablePalettes = [[NSColorList availableColorLists] copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        for (NSString *colorListName in [dictionary allKeys])
        {
            NSColorList *colorList = [NSColorList colorListNamed:colorListName]; // Read from the operating system
            if (!colorList)
            {
                NSColorList *colorListFromDictionary = [EMDSelectedPalettes colorListFromDictionary:dictionary[colorListName] withName:colorListName];
                [colorListFromDictionary writeToFile:nil]; // Save to user's private colorlists directory.
                colorList = colorListFromDictionary;
                self.availablePalettes = [[NSColorList availableColorLists] copy];
            }
            [self selectPalette:colorList.name];
        }
    }
    return self;
}

- (void)setAvailablePalettes:(NSArray *)availablePalettes
{
    [self willChangeValueForKey:@"availablePalettes"];
    _availablePalettes = [availablePalettes copy];
    
    NSMutableDictionary *palettes = [[NSMutableDictionary alloc] initWithCapacity:[availablePalettes count]];
    NSMutableArray *selectedPalettes = [[NSMutableArray alloc] initWithCapacity:[availablePalettes count]];
    
    for (NSColorList *list in availablePalettes)
    {
        EMDWrappedPalette *palette = [self.palettes objectForKey:list.name];
        if (!palette) {
            palette = [EMDWrappedPalette new];
        }
        palette.palette = list;
        [palettes setObject:palette forKey:list.name];
        if (palette.selected) {
            [selectedPalettes addObject:palette.palette];
        }
    }
    
    self.palettes = palettes;
    self.selectedPalettes = selectedPalettes;
    
    [self didChangeValueForKey:@"availablePalettes"];
}

-(BOOL)isPaletteSelected:(NSString *)paletteName
{
    EMDWrappedPalette *palette = self.palettes[paletteName];
    return palette.selected;
}

- (void)selectPalette:(NSString *)paletteName
{
    EMDWrappedPalette *palette = self.palettes[paletteName];
    palette.selected = YES;
    if (![self.selectedPalettes containsObject:palette.palette])
    {
        self.selectedPalettes = [self.selectedPalettes arrayByAddingObject:palette.palette];
    }
}

- (void)deselectPalette:(NSString *)paletteName
{
    EMDWrappedPalette *palette = self.palettes[paletteName];
    palette.selected = NO;
    
    if ([self.selectedPalettes containsObject:palette.palette])
    {
        NSMutableArray *selectedPalettes = [self.selectedPalettes mutableCopy];
        [selectedPalettes removeObject:palette.palette];
        self.selectedPalettes = selectedPalettes;
    }
}

- (NSDictionary *)asDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:[self.selectedPalettes count]];
    for (NSColorList *palette in self.selectedPalettes)
    {
        [dictionary setObject:[EMDSelectedPalettes colorListAsDictionary:palette] forKey:palette.name];
    }
    return [dictionary copy];
}

+ (NSColorList *)colorListFromDictionary:(NSDictionary *)palette withName:(NSString *)name
{
    NSColorList *newColorList = [[NSColorList alloc] initWithName:name];
    
    for (NSString *colorName in palette.allKeys)
    {
        NSDictionary *colorComponents = palette[colorName];
        NSColor *color = [NSColor colorWithRed:[colorComponents[@"red"] floatValue] green:[colorComponents[@"green"] floatValue] blue:[colorComponents[@"blue"] floatValue] alpha:[colorComponents[@"alpha"] floatValue]];
        [newColorList setColor:color forKey:colorName];
    }
    
    return newColorList;
}

+ (NSDictionary *)colorListAsDictionary:(NSColorList *)palette
{
    NSMutableDictionary *colors = [NSMutableDictionary new];
    for (NSString *colorName in [palette allKeys])
    {
        NSColor *color = [palette colorWithKey:colorName];
        [colors setObject:@{
                            @"red":@(color.redComponent),
                            @"green":@(color.greenComponent),
                            @"blue":@(color.blueComponent),
                            @"alpha":@(color.alphaComponent)
                            } forKey:colorName];
    }
    return [colors copy];
}

@end
