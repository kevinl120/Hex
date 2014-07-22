//
//  Gameplay.m
//  Hex
//
//  Created by Kevin Li on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

#import "Grid.h"


@implementation Gameplay {
    Grid *_grid;
    CCLabelTTF *_instructions;
}

- (void) resetGrid {
    // Reload the level to reset the grid
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}



@end
