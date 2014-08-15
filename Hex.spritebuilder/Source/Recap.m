//
//  Recap.m
//  Hex
//
//  Created by Kevin Li on 8/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Recap.h"

#import "Gameplay.h"

@implementation Recap {
    CCLabelTTF *_gameOverLabel;
    
    Gameplay *_gameplay;
}

- (void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    CCActionMoveTo *moveGameOverLabel = [CCActionMoveTo actionWithDuration:0.5f position:ccp(0.5, 0.1)];
    CCActionEaseElasticOut *bounceGameOverLabel = [CCActionEaseElasticOut actionWithAction:moveGameOverLabel];
    [_gameOverLabel runAction:bounceGameOverLabel];
    
    CCActionFadeIn *fadeIn = [CCActionFadeIn actionWithDuration:0.5f];
    [_highScoreLabel runAction:fadeIn];
}

- (void) replay {
    CCTransition *crossFade = [CCTransition transitionCrossFadeWithDuration:1.f];
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay" owner:self];
    _gameplay = (Gameplay *)gameplayScene.children[0];
    _gameplay.positionType = CCPositionTypeNormalized;
    _gameplay.position = ccp(0, 0);
    _gameplay.gamemode = _gamemode;
    [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:crossFade];
}

- (void) menu {
    CCScene *mainScene = [CCBReader loadAsScene: @"MainScene"];
    CCTransition *fade = [CCTransition transitionCrossFadeWithDuration:1.f];
    [[CCDirector sharedDirector] presentScene:mainScene withTransition:fade];
}

@end
