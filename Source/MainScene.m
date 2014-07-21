//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void) play {
    CCScene *gameplayScene = [CCBReader loadAsScene: @"Gameplay"];
    CCTransition *transition = [CCTransition transitionFadeWithColor:[CCColor blackColor] duration:1.0f];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:transition];
}

@end
