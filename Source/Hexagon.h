//
//  Hexagon.h
//  Hex
//
//  Created by Kevin Li on 7/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Hexagon : CCSprite

// Variables that determine the position of the hexagon
@property (nonatomic, assign) int circle;
@property (nonatomic, assign) int hexagonNumber;

// Variable to store if the hexagon was removed
@property (nonatomic, assign) BOOL removed;

@end
