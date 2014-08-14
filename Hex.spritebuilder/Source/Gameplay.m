//
//  Gameplay.m
//  Hex
//
//  Created by Kevin Li on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

#import "Hexagon.h"
#import "Grid.h"
#import "Recap.h"

// Grid dimensions. Circles should not be set to more than 5.
static const int GRID_CIRCLES = 5;
static const int COLORS = 6;

// Hexagon dimensions
static const float _hexagonHeight = 40;
static const float _hexagonRadius = ((_hexagonHeight * (1.732050808)) / 3);


@implementation Gameplay {
    Grid *_grid;
    
    NSMutableArray *_gridArray;
    NSMutableArray *_selectedHexagons;
    Hexagon *_currentHexagon;
    
    BOOL _runAgain;
    
    CCLabelTTF *_scoreLabel;
    NSInteger _score;
    
    CCLabelTTF *_timeLabel;
    float _time;
    
    CGPoint _center;
}

// -----------------------------------------------------------------------
#pragma mark Setup
// -----------------------------------------------------------------------

- (void) onEnterTransitionDidFinish {
    
    [super onEnterTransitionDidFinish];
    
    // Set up the grid
    [self setupGrid];
    
    // Set the score and time to zero
    _score = 0;
    _time = 0;
    
    self.userInteractionEnabled = true;
}

- (void) setupGrid {
    
    // Find the center of the screen
    _center = ccp([CCDirector sharedDirector].viewSize.width/2, [CCDirector sharedDirector].viewSize.height/2);
    
    // Find the sprite frame for the grid based on the number of circles in the grid
    [_grid determineSpriteFrame:GRID_CIRCLES];
    
    // Initialize the array for the grid as a blank NSMutableArray. It will be turned into a 2-d array later.
    _gridArray = [[NSMutableArray alloc] init];
    // Initialize the array for the selected as a blank NSMutableArray
    _selectedHexagons = [[NSMutableArray alloc] init];
    
    
    // The position of the hexagons that will be initialized later. Starts at the center of the grid/screen.
    CGPoint hexagonPosition = _center;
    
    // Load the first hexagon at the center of the screen
    Hexagon *hexagon = (Hexagon *)[CCBReader load:@"Hexagon"];
    hexagon.positionInPoints = hexagonPosition;
    hexagon.scale = 0.06f;
    [self addChild:hexagon];
    
    // Loops a number of times equal to the number of circles in the grid.
    for (int i = 0; i < GRID_CIRCLES; i++) {
        
        // Initialize a temporary array used to turn "_gridArray" into a 2-d array
        NSMutableArray *circleArray = [[NSMutableArray alloc] init];
        
        NSMutableArray *hexagonLoadActions = [[NSMutableArray alloc] init];
        
        // Loops a number of times equal to the number of hexagons in the current circle
        for (int j = 0; j < (i * 6); j++) {
            
            CCActionDelay *delayAction = [CCActionDelay actionWithDuration:0.04];
            
            CCActionCallBlock *action = [CCActionCallBlock actionWithBlock:^{
                // Load the hexagon on to the screen
                Hexagon *hexagon = (Hexagon *)[CCBReader load:@"Hexagon"];
                hexagon.positionInPoints = hexagonPosition;
                hexagon.scale = 0.04f;
                [self addChild:hexagon];
                
                CCActionFadeIn *fadeHexagon = [CCActionFadeIn actionWithDuration:0.5f];
                
                CCActionDelay *anotherDelay = [CCActionDelay actionWithDuration:0.025f];
                
                CCActionScaleTo *scaleHexagon = [CCActionScaleTo actionWithDuration:0.5f scale:0.06f];
                [hexagon runAction:[CCActionSequence actions:fadeHexagon, anotherDelay, scaleHexagon, nil]];
                
                // Save the circle and number of the hexagon
                hexagon.circle = i;
                hexagon.hexagonNumber = j;
                
                // Give the hexagon a random color
                hexagon.color = [self giveRandomColor:COLORS];
                
                // Add the hexagon to the temporary array
                [circleArray addObject:hexagon];
            }];
            
            [hexagonLoadActions addObject:delayAction];
            [hexagonLoadActions addObject:action];
            
            // Position the next hexagon.
            if (j < i){
                hexagonPosition.y -= (0.5) * _hexagonHeight;
                hexagonPosition.x += (1.5) * _hexagonRadius;
            } else if (j < (2 * i)) {
                hexagonPosition.y -= _hexagonHeight;
            } else if (j < (3 * i)) {
                hexagonPosition.y -= (0.5) * _hexagonHeight;
                hexagonPosition.x -= (1.5) * _hexagonRadius;
            } else if (j < (4 * i)) {
                hexagonPosition.y += (0.5) * _hexagonHeight;
                hexagonPosition.x -= (1.5) * _hexagonRadius;
            } else if (j < (5 * i)) {
                hexagonPosition.y += _hexagonHeight;
            } else if (j < (6 * i)) {
                hexagonPosition.y += (0.5) * _hexagonHeight;
                hexagonPosition.x += (1.5) * _hexagonRadius;
            }
        }
        
        // Add the temporary array to "_gridArray" to form the 2-d array
        [_gridArray addObject:circleArray];
        
        // Reposition x and y after all hexagons in the current circle have been initiated
        hexagonPosition = ccp([CCDirector sharedDirector].viewSize.width/2, [CCDirector sharedDirector].viewSize.height/2);
        hexagonPosition.y += (_hexagonHeight * (i + 1));
        
        if ([hexagonLoadActions count] > 0) {
            [self runAction:[CCActionSequence actionWithArray:hexagonLoadActions]];
        }

    }
}

// -----------------------------------------------------------------------
#pragma mark Touch Interaction
// -----------------------------------------------------------------------

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    // Get the location of the touch
    CGPoint touchLocation = [touch locationInWorld];
    
    // Get the hexagon at the touched location
    Hexagon *touchedHexagon = [self hexagonForPosition:touchLocation];
    
    // Add the touched hexagon to the array of selected hexagons and highlight it if it is not equal to nil
    if (touchedHexagon != nil) {
        touchedHexagon.scale = 0.08f;
        _currentHexagon = touchedHexagon;
        [_selectedHexagons addObject:touchedHexagon];
    }
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    // Get the location of the touch
    CGPoint touchLocation = [touch locationInWorld];
    
    // Get the hexagon at that location
    Hexagon *touchedHexagon = [self hexagonForPosition:touchLocation];
    
    // If user drags back onto previous hexagon that was selected, deselect the last hexagon added and "un"-highlight it.
    if ([_selectedHexagons containsObject:touchedHexagon] && [_selectedHexagons indexOfObject:touchedHexagon] == ([_selectedHexagons count] - 2) && ![_currentHexagon isEqual:touchedHexagon]) {
        Hexagon *hexagon = [_selectedHexagons lastObject];
        hexagon.scale = 0.06f;
        [_selectedHexagons removeLastObject];
        _currentHexagon = touchedHexagon;
    }
    // Otherwise, if user drags onto a new hexagon that is adjacent to the previous hexagon, has the same color, and is not equal to nil, schedule the new hexagon to be removed and highlight it.
    else if (![_currentHexagon isEqual:touchedHexagon] && touchedHexagon != nil && ccpDistance(_currentHexagon.positionInPoints, touchedHexagon.positionInPoints) <= _hexagonHeight + 1 && [_currentHexagon.color isEqual:touchedHexagon.color] && ![_selectedHexagons containsObject:touchedHexagon]) {
        touchedHexagon.scale = 0.08f;
        _currentHexagon = touchedHexagon;
        [_selectedHexagons addObject:touchedHexagon];
    }
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // If user selected more than one hexagon,
    if ([_selectedHexagons count] > 1) {
        
        _score += [_selectedHexagons count];
        _scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
        
        [self removeHexagons];
    }
    // Otherwise, if the user selected exactly one hexagon, "un"-highlight that hexagon
    else if ([_selectedHexagons count] == 1) {
        Hexagon *hexagon = _selectedHexagons[0];
        hexagon.scale = 0.06f;
    }
    // Remove all selected hexagons after a touch ends
    [_selectedHexagons removeAllObjects];
}

- (void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    for (int i = 0; i < [_selectedHexagons count]; i++) {
        Hexagon *hexagon = _selectedHexagons[i];
        hexagon.scale = 0.06f;
    }
    [_selectedHexagons removeAllObjects];
}


- (Hexagon *) hexagonForPosition:(CGPoint)position {
    
    // Find circle that was touched
    NSInteger circle = ((ccpDistance(_center, position) - (_hexagonHeight/2)) / (_hexagonHeight - 4)) + 1;
    
    // Find the hexagon number within the circle that was touched
    NSInteger hexagonNumber = 0;
    
    // Create a temporary point used to find the hexagon number
    CGPoint temporaryPosition = ccp(_center.x, _center.y + (circle * _hexagonHeight));
    
    // Move the temporary position variables until they are inside the same hexagon that was touched
    while (ccpDistance(temporaryPosition, position) > _hexagonRadius) {
        if (hexagonNumber < circle){
            temporaryPosition.y -= (0.5) * _hexagonHeight;
            temporaryPosition.x += (1.5) * _hexagonRadius;
        } else if (hexagonNumber < (2 * circle)) {
            temporaryPosition.y -= _hexagonHeight;
        } else if (hexagonNumber < (3 * circle)) {
            temporaryPosition.y -= (0.5) * _hexagonHeight;
            temporaryPosition.x -= (1.5) * _hexagonRadius;
        } else if (hexagonNumber < (4 * circle)) {
            temporaryPosition.y += (0.5) * _hexagonHeight;
            temporaryPosition.x -= (1.5) * _hexagonRadius;
        } else if (hexagonNumber < (5 * circle)) {
            temporaryPosition.y += _hexagonHeight;
        } else if (hexagonNumber < (6 * circle)) {
            temporaryPosition.y += (0.5) * _hexagonHeight;
            temporaryPosition.x += (1.5) * _hexagonRadius;
        }
        hexagonNumber++;
        
        if (hexagonNumber > 25) {
            return nil;
        }
    }
    
    // Return nil if any value is below zero, or if the circle was greater than the total number of circles in the grid
    if (circle >= GRID_CIRCLES || circle <= 0 || hexagonNumber < 0) {
        return nil;
    } else {
        return _gridArray[circle][hexagonNumber];
    }
}


// -----------------------------------------------------------------------
#pragma mark Game Mechanics
// -----------------------------------------------------------------------

- (void) removeHexagons {
    for (int i = 0; i < [_selectedHexagons count]; i++) {
        Hexagon *hexagon = _selectedHexagons[i];
        hexagon.removed = true;
    }
    [self fillEmptySpaces];
}

- (void) fillEmptySpaces {
    do {
        [self fillMainLanes];
    } while (_runAgain);
    
    do {
        [self fillFourthCircle];
        [self fillThirdCircle];
        [self fillSecondCircle];
    } while (_runAgain);
    
}

- (void) fillMainLanes {
    
    _runAgain = false;
    
    for (int i = 0; i < 6; i++) {
        for (int j = (GRID_CIRCLES - 1); j > 0; j--) {
            int circle = j;
            int hexagonNumber = circle * i;
            
            Hexagon *hexagon = _gridArray[circle][hexagonNumber];
            
            if (hexagon.removed) {
                if (hexagon.circle == (GRID_CIRCLES - 1)) {
                    hexagon.color = [self giveRandomColor:COLORS];
                    hexagon.scale = 0.06f;
                    hexagon.removed = false;
                } else {
                    Hexagon *temporaryHexagon = _gridArray[circle + 1][(circle + 1) * i];
                    hexagon.color = temporaryHexagon.color;
                    hexagon.scale = 0.06f;
                    temporaryHexagon.removed = true;
                    [self moveConnectedHexagon:temporaryHexagon toOtherHexagon:hexagon];
                    hexagon.removed = false;
                    
                    _runAgain = true;
                }
            }
        }
    }
}

- (void) fillFourthCircle {
    
    _runAgain = false;
    
    for (int i = 0; i < 24; i++) {
        if (i % 4 != 0) {
            Hexagon *hexagon = _gridArray[4][i];
            if (hexagon.removed) {
                hexagon.color = [self giveRandomColor:COLORS];
                hexagon.scale = 0.06f;
                hexagon.removed = false;
            }
        }
    }
}

- (void) fillThirdCircle {
    NSInteger temporaryInteger = 1;
    for (int i = 0; i < 18; i++) {
        if (i % 3 != 0) {
            Hexagon *hexagon = _gridArray[3][i];
            if (hexagon.removed) {
                Hexagon *temporaryHexagon = _gridArray[4][temporaryInteger];
                hexagon.color = temporaryHexagon.color;
                hexagon.scale = 0.06f;
                hexagon.removed = false;
                temporaryHexagon.removed = true;
                [self moveConnectedHexagon:temporaryHexagon toOtherHexagon:hexagon];
                _runAgain = true;
            }
            temporaryInteger += 2;
        }
    }
}

- (void) fillSecondCircle {
    NSInteger   temporaryInteger = 1;
    for (int i = 1; i < 12; i += 2) {
        Hexagon *hexagon = _gridArray[2][i];
        if (hexagon.removed) {
            NSInteger randomInt = arc4random() % 2;
            if (randomInt == 0) {
                Hexagon *temporaryHexagon = _gridArray[3][temporaryInteger];
                hexagon.color = temporaryHexagon.color;
                hexagon.scale = 0.06f;
                hexagon.removed = false;
                temporaryHexagon.removed = true;
                _runAgain = true;
            } else if (randomInt == 1) {
                Hexagon *temporaryHexagon = _gridArray[3][temporaryInteger + 1];
                hexagon.color = temporaryHexagon.color;
                hexagon.scale = 0.06f;
                hexagon.removed = false;
                temporaryHexagon.removed = true;
                [self moveConnectedHexagon:temporaryHexagon toOtherHexagon:hexagon];
                _runAgain = true;
            }
        }
        temporaryInteger += 3;
    }
}

// -----------------------------------------------------------------------
#pragma mark Animations
// -----------------------------------------------------------------------

- (void) moveConnectedHexagon:(Hexagon *)hexagonToAnimate toOtherHexagon:(Hexagon *)hexagonToMoveTo {
    hexagonToMoveTo.opacity = 0.0f;
    CGPoint lastHexagonPosition = hexagonToAnimate.position;
    CCActionMoveTo *moveHexagon = [CCActionMoveTo actionWithDuration:0.5f position:hexagonToMoveTo.position];
    
    CCActionDelay *delay = [CCActionDelay actionWithDuration:0.55f];
    
    CCActionCallBlock *actionAfterAnimation = [CCActionCallBlock actionWithBlock:^{
        hexagonToAnimate.position = lastHexagonPosition;
        CCActionFadeIn *fadeHexagonIn = [CCActionFadeIn actionWithDuration:0.3f];
        [hexagonToAnimate runAction:fadeHexagonIn];
        hexagonToMoveTo.opacity = 1.0f;
    }];
    
    [hexagonToAnimate runAction:[CCActionSequence actions:moveHexagon, delay, actionAfterAnimation, nil]];
}




// -----------------------------------------------------------------------
#pragma mark User Interface
// -----------------------------------------------------------------------

- (void) resetGrid {
    // Reload the level to reset the grid
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

// -----------------------------------------------------------------------
#pragma mark Methods to make life easier
// -----------------------------------------------------------------------

- (CCColor *) giveRandomColor:(NSInteger)numberOfColors {
    // Return a random color
    
    //NSInteger randomInt = 4;
    NSInteger randomInt = arc4random() % numberOfColors;
    
    switch (randomInt) {
        case 0:
            return [CCColor colorWithRed:0.f green:1.f blue:1.f alpha:1.f];
        case 1:
            return [CCColor colorWithRed:0.f green:0.8f blue:0.f alpha:1.f];
        case 2:
            return [CCColor colorWithRed:1.f green:0.f blue:0.f alpha:1.f];
        case 3:
            return [CCColor colorWithRed:1.f green:0.65f blue:0.f alpha:1.f];
        case 4:
            return [CCColor colorWithRed:0.75f green:1.f blue:0.f alpha:1.f];
        case 5:
            return [CCColor colorWithRed:0.6f green:0.6f blue:1.f alpha:1.f];
        default:
            return [CCColor blackColor];
    }
}



//- (void) setScore {
//    _time += 0.1;
//
//    _scoreLabel.string = [NSString stringWithFormat:@"%d", _grid.score];
//    if (_grid.score >= 250) {
//        [self unschedule:@selector(setScore)];
//        CCScene *scene = [CCBReader loadAsScene:@"Recap"];
//        Recap *recapScreen = (Recap *)scene.children[0];
//        recapScreen.positionType = CCPositionTypeNormalized;
//        recapScreen.position = ccp(0, 0);
//        [[CCDirector sharedDirector] replaceScene:scene];
//        recapScreen.finalTime.string = [NSString stringWithFormat:@"%f", _time];
//
//    }
//}



@end
