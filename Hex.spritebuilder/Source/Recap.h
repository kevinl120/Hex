//
//  Recap.h
//  Hex
//
//  Created by Kevin Li on 8/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface Recap : CCNode

@property (nonatomic, assign) int gamemode;

@property (nonatomic, strong) CCLabelTTF* scoreLabel;
@property (nonatomic, strong) CCLabelTTF* highScoreLabel;

@end
