//
//  Grid.m
//  Hex
//
//  Created by Kevin Li on 7/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Grid.h"

#import "Hexagon.h"
#import "Recap2.h"

// Grid dimensions. Should not be set to more than 6. Code optimized for 5.
static const int GRID_CIRCLES = 5;

static const int COLORS = 3;

@implementation Grid {
    // Declare the array for the grid
    NSMutableArray *_gridArray;
    // Declare the array for the selected hexagons
    NSMutableArray *_selectedHexagons;
    
    // The height (2*apothem) and the radius of the hexagon
    float _hexagonHeight;
    float _hexagonRadius;
    
    // A boolean used to determine if fillEmptySpaces needs to be run again
    BOOL _runAgain;
    
    // A variable for the current hexagon (Used to make sure no hexagon is interacted with multiple times on a single tap)
    Hexagon *_currentHexagon;
    
    NSInteger _moves;
}


// -----------------------------------------------------------------------
#pragma mark Setup Grid
// -----------------------------------------------------------------------


- (void) didLoadFromCCB {
    //[super onEnter];
    
    // Setup the Grid
    [self setupGrid];

    // Accept touches on the grid
    self.userInteractionEnabled = true;

    // Make it look better (optional) :P
    self.opacity = 0.00f;
    
    // Set the score and moves to zero
    _score = 0;
    _moves = 0;
    
    _runAgain = true;
}


- (void) setupGrid {
    // The number of hexagons in the circle that is being interacted with
    NSInteger hexagonsInCurrentCircle = 0;
    
    
    // Initialize the array for the grid as a blank NSMutableArray. It will be turned into a 2-d array later.
    _gridArray = [[NSMutableArray alloc]init];
    // Initialize the array for the selected hexagons as a blank NSMutableArray.
    _selectedHexagons = [[NSMutableArray alloc]init];
    
    
    // Divide the grid's height by the number of vertical cells in the highest column (which is equal to the number of circles in the grid times 2, minus 1) to find out the height of each cell
    _hexagonHeight = self.contentSize.height / ((GRID_CIRCLES*2)-1);
    
    // Do some math to find the radius of the hexagon
    _hexagonRadius = ((_hexagonHeight*(sqrt(3)))/3);
    
    // x and y are the positions of the hexagons that will be initialized later. The starting position is the center of the grid.
    float x = self.contentSizeInPoints.width/2;
    float y = self.contentSizeInPoints.height/2;
    
    // Loops a number of times equal to the number of circles in the grid.
    // The current circle number is the variable "i"
    for (int i = 0; i < GRID_CIRCLES; i++) {
        
        // Initialize a temporary array used to turn "_gridArray" into a 2-d array
        NSMutableArray *circleArray = [[NSMutableArray alloc]init];
        
        for (int j = 0; j < hexagonsInCurrentCircle; j++) {
            // Load the hexagon onto the screen
            Hexagon *hexagon = (Hexagon*)[CCBReader load:@"Hexagon"];
            hexagon.positionInPoints = ccp(x, y);
            hexagon.scale = 0.06f;
            [self addChild:hexagon];
            
            // Save the circle and number of the hexagon
            hexagon.circle = i;
            hexagon.hexagonNumber = j;
            
            // Give the hexagon a random color
            hexagon.color = [self giveRandomColor:COLORS];
            
            // Add the hexagon to the temporary array
            [circleArray addObject:hexagon];
            
            // Position the next hexagon.
            if (j < i){
                y -= (0.5) * _hexagonHeight;
                x += (1.5) * _hexagonRadius;
            } else if (j < (2 * i)) {
                y -= _hexagonHeight;
            } else if (j < (3 * i)) {
                y -= (0.5) * _hexagonHeight;
                x -= (1.5) * _hexagonRadius;
            } else if (j < (4 * i)) {
                y += (0.5) * _hexagonHeight;
                x -= (1.5) * _hexagonRadius;
            } else if (j < (5 * i)) {
                y += _hexagonHeight;
            } else if (j < (6 * i)) {
                y += (0.5) * _hexagonHeight;
                x += (1.5) * _hexagonRadius;
            }
            
        }
        
        // Add the temporary array to "_gridArray" to form the 2-d array
        [_gridArray addObject:circleArray];
        
        // Reposition x and y after all hexagons in the current circle have been initiated
        x = self.contentSizeInPoints.width/2;
        y = self.contentSizeInPoints.height/2;
        for (int k = 0; k < (i + 1); k++) {
            y += _hexagonHeight;
        }
        
        hexagonsInCurrentCircle += 6;
        
    }
}


// -----------------------------------------------------------------------
#pragma mark React to touches
// -----------------------------------------------------------------------

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Get the x and y coordinates of the touch
    CGPoint touchLocation = [touch locationInNode:self];
    
    // Get the Hexagon at that location
    Hexagon *hexagon = [self hexagonForGivenPosition:touchLocation];
    
    // Add the hexagon to the array of hexagons that are scheduled to be removed. Highlight the hexagon to show that it has been scheduled to be removed.
    if (hexagon != nil) {
        hexagon.scale = 0.08f;
        _currentHexagon = hexagon;
        [_selectedHexagons addObject:hexagon];
    }
    
}


- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    // Get the x and y coordinates of the touch
    CGPoint touchLocation = [touch locationInNode:self];
    
    // Get the hexagon at that location
    Hexagon *hexagon = [self hexagonForGivenPosition:touchLocation];
    
    // If user drags back onto previous hexagon that was selected, deselect the last hexagon added and "un"-highlight it.
    if ([_selectedHexagons containsObject:hexagon] && [_selectedHexagons indexOfObject:hexagon] == ([_selectedHexagons count] - 2) && ![_currentHexagon isEqual:hexagon]) {
        
        Hexagon *temporaryHexagon = [_selectedHexagons lastObject];
        temporaryHexagon.scale = 0.06f;
        [_selectedHexagons removeLastObject];
        _currentHexagon = hexagon;
    }
    
    // Otherwise, if user drags onto a new hexagon that is adjacent to the previous hexagon, has the same color, and is not equal to nil, schedule the new hexagon to be removed and highlight it.
    else if (![_currentHexagon isEqual:hexagon] && hexagon != nil && sqrtf(powf(_currentHexagon.positionInPoints.x - hexagon.positionInPoints.x, 2) + (powf(_currentHexagon.positionInPoints.y - hexagon.positionInPoints.y, 2))) <= _hexagonHeight+1 && [_currentHexagon.color isEqual:hexagon.color] && ![_selectedHexagons containsObject:hexagon]) {
        
        hexagon.scale = 0.08f;
        _currentHexagon = hexagon;
        [_selectedHexagons addObject:hexagon];
    }
}


- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if ([_selectedHexagons count] > 1) {
        [self findPattern];
        [self removeHexagons];
        while (_runAgain) {
            [self fillEmptySpaces];
        }
        _runAgain =
        _score += (float)(([_selectedHexagons count]+1)/2.0f) * [_selectedHexagons count];
        [_selectedHexagons removeAllObjects];
        if (_gamemode == 2) {
            _moves++;
            if (_moves >= 10) {
                CCScene *scene = [CCBReader loadAsScene:@"Recap2"];
                Recap2 *recapScreen = (Recap2 *)scene.children[0];
                recapScreen.positionType = CCPositionTypeNormalized;
                recapScreen.position = ccp(0, 0);
                [[CCDirector sharedDirector] replaceScene:scene];
                recapScreen.finalScore.string = [NSString stringWithFormat:@"%d", _score];
            }
        }

    } else if ([_selectedHexagons count] == 0) {
        
    } else {
        Hexagon *hexagon = _selectedHexagons[0];
        hexagon.scale = 0.06f;
        [_selectedHexagons removeAllObjects];
    }
}


- (Hexagon *) hexagonForGivenPosition:(CGPoint)givenPosition {
    
    NSInteger circle = 0;
    NSInteger hexagonNumber = 0;
    
    // Get the circle that was touched
    circle = ((sqrtf((powf(self.contentSizeInPoints.width/2 - givenPosition.x, 2)) + (powf(self.contentSizeInPoints.height/2 -  givenPosition.y, 2))) - (_hexagonHeight/2)) / (_hexagonHeight)) + 1;
    
    // Create two temporary variables used to find the hexagon number
    float positionX = self.contentSizeInPoints.width/2;
    float positionY = (self.contentSizeInPoints.height - ((GRID_CIRCLES - circle) * _hexagonHeight)) + _hexagonHeight/2;
    
    // Move the temporary position variables until they are inside the same hexagon that was touched
    while ((sqrtf(powf(positionX - givenPosition.x, 2) + powf(positionY - givenPosition.y, 2))) > _hexagonRadius) {
        if (hexagonNumber < circle){
            positionY -= (0.5) * _hexagonHeight;
            positionX += (1.5) * _hexagonRadius;
        } else if (hexagonNumber < (2 * circle)) {
            positionY -= _hexagonHeight;
        } else if (hexagonNumber < (3 * circle)) {
            positionY -= (0.5) * _hexagonHeight;
            positionX -= (1.5) * _hexagonRadius;
        } else if (hexagonNumber < (4 * circle)) {
            positionY += (0.5) * _hexagonHeight;
            positionX -= (1.5) * _hexagonRadius;
        } else if (hexagonNumber < (5 * circle)) {
            positionY += _hexagonHeight;
        } else if (hexagonNumber < (6 * circle)) {
            positionY += (0.5) * _hexagonHeight;
            positionX += (1.5) * _hexagonRadius;
        }
        hexagonNumber++;
        
        if (hexagonNumber > 500) {
            return nil;
        }
    }
    
    // Return nil if any value is below zero, or if the circle was greater than the total number of circles in the grid
    if (circle >= GRID_CIRCLES || circle <= 0 || hexagonNumber < 0) {
        
        return nil;
        
    }
    
    if (circle != 0) {
        return _gridArray[circle][hexagonNumber];
    }
}


- (void) removeHexagons {
    float durationOfAnimation = 0.5f;
    
    for (int i = 0; i < [_selectedHexagons count]; i++) {
        Hexagon *temporaryHexagon = _selectedHexagons[i];
        
//        // Animations that occur when a hexagon is removed.
//        CCActionScaleTo *scaleHexagon = [CCActionScaleTo actionWithDuration:durationOfAnimation scale:0.001f];
//        CCActionRotateBy *rotateHexagon = [CCActionRotateBy actionWithDuration:durationOfAnimation angle:180.f];
//        CCActionFadeTo *fadeHexagon = [CCActionFadeTo actionWithDuration:durationOfAnimation];
//
//        [temporaryHexagon runAction:scaleHexagon];
//        [temporaryHexagon runAction:rotateHexagon];
//        [temporaryHexagon runAction:fadeHexagon];
        
        temporaryHexagon.removed = true;
    }
}


- (void) fillEmptySpaces {
    
    _runAgain = false;
    
    for (int i = 0; i < 6; i++) {
        for (int j = (GRID_CIRCLES - 1); j > 0; j--) {
            int circle = j;
            int hexagonNumber = circle * i;
            
            Hexagon *temporaryHexagon = _gridArray[circle][hexagonNumber];
            
            if (temporaryHexagon.removed) {
                if (temporaryHexagon.circle == (GRID_CIRCLES - 1)) {
                    temporaryHexagon.color = [self giveRandomColor:COLORS];
                    temporaryHexagon.scale = 0.06f;
                    temporaryHexagon.removed = false;
                } else {
                    Hexagon *anotherTemporaryHexagon = _gridArray[circle + 1][(circle + 1) * i];
                    temporaryHexagon.color = anotherTemporaryHexagon.color;
                    
                    temporaryHexagon.scale = 0.06f;
                    anotherTemporaryHexagon.removed = true;
                    temporaryHexagon.removed = false;
                    
                    _runAgain = true;
                }
                
            }
            
        }
    }
    
    for (int i = 0; i < 24; i++) {
        if (i % 4 != 0) {
            Hexagon *temporaryHexagon = _gridArray[GRID_CIRCLES - 1][i];
            if (temporaryHexagon.removed) {
                temporaryHexagon.color = [self giveRandomColor:COLORS];
                temporaryHexagon.scale = 0.06f;
                temporaryHexagon.removed = false;
            }
        }
    }
    
    NSInteger temporaryInteger = 1;
    for (int i = 0; i < 18; i++) {
        if (i % 3 != 0) {
            temporaryInteger += 2;
            Hexagon *temporaryHexagon = _gridArray[GRID_CIRCLES-2][i];
            if (temporaryHexagon.removed) {
                Hexagon *anotherTemporaryHexagon;
                if (temporaryInteger > 23) {
                   anotherTemporaryHexagon = _gridArray[GRID_CIRCLES - 1][23];
                } else {
                    anotherTemporaryHexagon = _gridArray[GRID_CIRCLES-1][temporaryInteger];
                }
                temporaryHexagon.color = anotherTemporaryHexagon.color;
                temporaryHexagon.scale = 0.06f;
                temporaryHexagon.removed = false;
                anotherTemporaryHexagon.removed = true;
                _runAgain = true;
            }
        }
    }
    
    
    
    
    
    
}


- (CCColor *) giveRandomColor:(NSInteger)numberOfColors {
    // Return a random color
    
    NSInteger randomInt = arc4random() % numberOfColors;
    
    switch (randomInt) {
        case 0:
            return [CCColor cyanColor];
        case 1:
            return [CCColor greenColor];
        case 2:
            return [CCColor blueColor];
        case 3:
            return [CCColor magentaColor];
        case 4:
            return [CCColor redColor];
        default:
            return [CCColor blackColor];
    }
}


- (void) findPattern {
    CCLabelTTF *triangleLabel = [CCLabelTTF labelWithString:@"Triangle" fontName:@"Helvetica" fontSize:20];
    [self addChild:triangleLabel];
    triangleLabel.positionInPoints = ccp(self.contentSizeInPoints.width/2, self.contentSizeInPoints.height/2);
    CCActionFadeOut *fadeText = [CCActionFadeOut actionWithDuration:0.5f];
    [triangleLabel runAction:fadeText];
    [triangleLabel removeFromParent];
}

@end
