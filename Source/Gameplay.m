//
//  Gameplay.m
//  Hex
//
//  Created by Kevin Li on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

#import "Grid.h"
#import "Recap.h"


@implementation Gameplay {
    Grid *_grid;
    
    CCLabelTTF *_scoreLabel;
}

- (void) didLoadFromCCB {
    _time = 0;
    [self schedule:@selector(setScore) interval:0.1];
}


- (void) resetGrid {
    // Reload the level to reset the grid
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

- (void) setScore {
    _time += 0.1;
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _grid.score];
    if (_grid.score >= 250) {
        [self unschedule:@selector(setScore)];
        CCScene *scene = [CCBReader loadAsScene:@"Recap"];
        Recap *recapScreen = (Recap *)scene.children[0];
        recapScreen.positionType = CCPositionTypeNormalized;
        recapScreen.position = ccp(0, 0);
        [[CCDirector sharedDirector] replaceScene:scene];
        recapScreen.finalTime.string = [NSString stringWithFormat:@"%f", _time];
        
    }
}



@end
