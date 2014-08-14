//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

#import "Gameplay.h"

@implementation MainScene {
    CCButton *_testButton;
    
    CCLabelTTF *_title;
}

- (void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.5f];
    
    CCActionMoveTo *moveText = [CCActionMoveTo actionWithDuration:1.f position:ccp(0.5, 0.8)];
    CCActionEaseElasticOut *bounce = [CCActionEaseElasticOut actionWithAction:moveText];
    
    [_title runAction:[CCActionSequence actions:delay, bounce, nil]];

}


- (void) play {
    CCScene *gameplayScene = [CCBReader loadAsScene: @"Gameplay"];
    CCTransition *fade = [CCTransition transitionCrossFadeWithDuration:1.f];
    [[CCDirector sharedDirector] presentScene:gameplayScene withTransition:fade];
}


@end
