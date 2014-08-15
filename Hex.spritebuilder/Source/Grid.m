//
//  Grid.m
//  Hex
//
//  Created by Kevin Li on 7/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Grid.h"

#import "Hexagon.h"


@implementation Grid

- (void) determineSpriteFrame:(NSInteger)circles {
    // Determine the sprite frame for the grid based on the number of circles in the grid
    if (circles == 2) {
        self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"Resources/2HexGrid.png"];
    } else if (circles == 3) {
        self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"Resources/3HexGrid.png"];
    } else if (circles == 4) {
        self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"Resources/4HexGrid.png"];
    } else if (circles == 5) {
        self.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"Resources/5HexGrid.png"];
    }
    self.opacity = 0.00f;
}


@end
