//
//  Recap.m
//  Hex
//
//  Created by Kevin Li on 8/1/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Recap.h"

@implementation Recap

- (void) menu {
    CCScene *mainScene = [CCBReader loadAsScene: @"MainScene"];
    CCTransition *fade = [CCTransition transitionCrossFadeWithDuration:1.f];
    [[CCDirector sharedDirector] presentScene:mainScene withTransition:fade];
}

@end
