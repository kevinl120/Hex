//
//  Gameplay.m
//  Hex
//
//  Created by Kevin Li on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

#import "Grid.h"
#import "Hexagon.h"

@implementation Gameplay {
    Grid *_grid;
    CCTimer *_timer;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _timer = [[CCTimer alloc] init];
    }
    
    return self;
}

////- (void) didLoadFromCCB {
//    Hexagon *hexagon = (Hexagon*)[CCBReader load:@"Hexagon"];
//    hexagon.anchorPoint = ccp(0, 0);
//    hexagon.position = ccp(0, 0);
//    [self addChild:hexagon];
//}


@end
