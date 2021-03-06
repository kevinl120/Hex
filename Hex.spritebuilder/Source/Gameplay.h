//
//  Gameplay.h
//  Hex
//
//  Created by Kevin Li on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Gameplay : CCNode

@property (nonatomic, assign) float time;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) int moves;

@property (nonatomic, assign) int gamemode;

@end
