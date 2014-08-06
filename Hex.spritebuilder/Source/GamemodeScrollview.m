//
//  GamemodeScrollview.m
//  Hex
//
//  Created by Kevin Li on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GamemodeScrollview.h"

@implementation GamemodeScrollview {

}


- (void) didLoadFromCCB {
    CGSize _screenSize = CGSizeMake([CCDirector sharedDirector].viewSize.width * 2, [CCDirector sharedDirector].viewSize.height);
    [self setContentSize:_screenSize];
}

- (void) play {
    CCScene *gameplayScene = [CCBReader loadAsScene: @"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithColor:[CCColor blackColor] duration:1.0f];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
}

@end
