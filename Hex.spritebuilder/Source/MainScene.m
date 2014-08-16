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
    CCButton *_timeButton;
    CCButton *_movesButton;
    CCButton *_pointsButton;
    
    CCLabelTTF *_title;
    
    Gameplay *_gameplay;
}

- (void) didLoadFromCCB {

}

- (void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.4f];
    
    CCActionMoveTo *moveTitle = [CCActionMoveTo actionWithDuration:1.f position:ccp(0.5, 0.8)];
    CCActionEaseElasticOut *bounceTitle = [CCActionEaseElasticOut actionWithAction:moveTitle];
    
    [_title runAction:[CCActionSequence actions:delay, bounceTitle, nil]];
    
    CCActionMoveTo *movePointsButton = [CCActionMoveTo actionWithDuration:1.f position:ccp(0.5, 0.55)];
    CCActionMoveTo *moveTimeButton = [CCActionMoveTo actionWithDuration:1.f position:ccp(0.5, 0.4)];
    CCActionMoveTo *moveMovesButton = [CCActionMoveTo actionWithDuration:1.f position:ccp(0.5, 0.25)];
    
    CCActionEaseElasticOut *bounceTimeButton = [CCActionEaseElasticOut actionWithAction:moveTimeButton];
    CCActionEaseElasticOut *bounceMovesButton = [CCActionEaseElasticOut actionWithAction:moveMovesButton];
    CCActionEaseElasticOut *bouncePointsButton = [CCActionEaseElasticOut actionWithAction:movePointsButton];
    
    [_timeButton runAction:[CCActionSequence actions:delay, bounceTimeButton, nil]];
    [_movesButton runAction:[CCActionSequence actions:delay, bounceMovesButton, nil]];
    [_pointsButton runAction:[CCActionSequence actions:delay, bouncePointsButton, nil]];
}

- (void) timeMode {
    [self animateExit];
    
    CCActionCallBlock *loadGameplay = [CCActionCallBlock actionWithBlock:^{
        CCTransition *crossFade = [CCTransition transitionCrossFadeWithDuration:1.f];
        CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay" owner:self];
        _gameplay = (Gameplay *)gameplayScene.children[0];
        _gameplay.positionType = CCPositionTypeNormalized;
        _gameplay.position = ccp(0, 0);
        _gameplay.gamemode = 1;
        [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:crossFade];
    }];
    
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.8f];
    
    [self runAction:[CCActionSequence actions:delay, loadGameplay, nil]];
}

- (void) movesMode {
    [self animateExit];
    
    CCActionCallBlock *loadGameplay = [CCActionCallBlock actionWithBlock:^{
        CCTransition *crossFade = [CCTransition transitionCrossFadeWithDuration:1.f];
        CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay" owner:self];
        _gameplay = (Gameplay *)gameplayScene.children[0];
        _gameplay.positionType = CCPositionTypeNormalized;
        _gameplay.position = ccp(0, 0);
        [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:crossFade];
        _gameplay.gamemode = 2;
    }];
    
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.8f];
    
    [self runAction:[CCActionSequence actions:delay, loadGameplay, nil]];
}

- (void) pointsMode {
    [self animateExit];
    
    CCActionCallBlock *loadGameplay = [CCActionCallBlock actionWithBlock:^{
        CCTransition *crossFade = [CCTransition transitionCrossFadeWithDuration:1.f];
        CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay" owner:self];
        _gameplay = (Gameplay *)gameplayScene.children[0];
        _gameplay.positionType = CCPositionTypeNormalized;
        _gameplay.position = ccp(0, 0);
        [[CCDirector sharedDirector] replaceScene:gameplayScene withTransition:crossFade];
        _gameplay.gamemode = 3;
    }];
    
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.8f];
    
    [self runAction:[CCActionSequence actions:delay, loadGameplay, nil]];
}


- (void) animateExit {
    CCActionScaleTo *scaleButtonUp = [CCActionScaleTo actionWithDuration:0.05f scale:1.25f];
    CCActionEaseSineIn *easeScaleUp = [CCActionEaseSineIn actionWithAction:scaleButtonUp];
    
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.075f];
    
    CCActionScaleTo *scaleButtonDown = [CCActionScaleTo actionWithDuration:0.5f scale:0.001];
    CCActionEaseSineIn *easeScaleDown = [CCActionEaseSineIn actionWithAction:scaleButtonDown];
    
    [_pointsButton runAction:[CCActionSequence actions:[easeScaleUp copy], delay, [easeScaleDown copy], nil]];
    [_timeButton runAction:[CCActionSequence actions:delay, [easeScaleUp copy], delay, [easeScaleDown copy], nil]];
    [_movesButton runAction:[CCActionSequence actions:delay, delay, [easeScaleUp copy], delay, [easeScaleDown copy], nil]];
    
    
    CCActionMoveTo *moveTitleDown = [CCActionMoveTo actionWithDuration:0.1f position:ccp(0.5, 0.75)];
    CCActionEaseSineOut *easeTitleDown = [CCActionEaseSineOut actionWithAction:moveTitleDown];
    
    CCActionDelay *anotherDelay = [CCActionDelay actionWithDuration:0.05f];
    
    CCActionMoveTo *moveTitleUp = [CCActionMoveTo actionWithDuration:0.5f position:ccp(0.5, 1.1)];
    CCActionEaseIn *easeTitleUp = [CCActionEaseIn actionWithAction:moveTitleUp rate:5.f];

    
    [_title runAction:[CCActionSequence actions:easeTitleDown, anotherDelay, easeTitleUp, nil]];
}


@end
