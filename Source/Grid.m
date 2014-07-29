//
//  Grid.m
//  Hex
//
//  Created by Kevin Li on 7/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Grid.h"

#import "Hexagon.h"

// Grid dimensions
static const int GRID_CIRCLES = 5;

@implementation Grid {
    // Declare the array for the grid
    NSMutableArray *_gridArray;
    // Declare the array for the selected hexagons
    NSMutableArray *_selectedHexagons;
    
    // The height (2*apothem) and the radius of the hexagon
    float _hexagonHeight;
    float _hexagonRadius;
    
    Hexagon *_currentHexagon;
}


// -----------------------------------------------------------------------
#pragma mark Setup Grid
// -----------------------------------------------------------------------


- (void) didLoadFromCCB {
    // Setup the Grid
    [self setupGrid];

    // Accept touches on the grid
    self.userInteractionEnabled = true;

    // Make it look better (optional) :P
    self.opacity = 0.00f;
    
    // Set the score to zero
    _score = 0;
}


- (void) setupGrid {
    // Declare the variables used in this function
    int hexagonsInCurrentCircle = 0;
    
    
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
    // Used in positioning hexagon.
    
    
    // Loops a number of times equal to the number of circles in the grid.
    // The current circle number is the variable "i"
    for (int i = 0; i < GRID_CIRCLES; i++) {
        
        // Initialize a temporary array used to turn "_gridArray" into a 2-d array
        NSMutableArray *circleArray = [[NSMutableArray alloc]init];
        
        for (int j = 0; j < hexagonsInCurrentCircle; j++) {
            // Load the hexagon onto the screen
            Hexagon *hexagon = (Hexagon*)[CCBReader load:@"Hexagon"];
            hexagon.positionInPoints = ccp(x, y);
            [self addChild:hexagon];
            
            // Give the hexagon a random color
            int randomInt = arc4random() % 3;
            if (randomInt == 1) {
                hexagon.color = [CCColor cyanColor];
            } else if (randomInt == 2) {
                hexagon.color = [CCColor greenColor];
            } else if (randomInt == 0) {
                hexagon.color = [CCColor blueColor];
            }
            
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
    Hexagon *hexagon = [self hexagonForTouchPosition:touchLocation];
    
    if (hexagon != nil) {
        hexagon.scale = 1.2f;
        _currentHexagon = hexagon;
        [_selectedHexagons addObject:hexagon];
    }
}


- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchLocation = [touch locationInNode:self];
    
    Hexagon *hexagon = [self hexagonForTouchPosition:touchLocation];
    
    if ([_selectedHexagons containsObject:hexagon] && ![_currentHexagon isEqual:hexagon]) {
        _currentHexagon = [_selectedHexagons lastObject];
        _currentHexagon.scale = 1.0f;
        [_selectedHexagons removeLastObject];
        _currentHexagon = hexagon;
    } else if (![_currentHexagon isEqual:hexagon] && hexagon != nil && sqrtf(powf(_currentHexagon.positionInPoints.x - hexagon.positionInPoints.x, 2) + (powf(_currentHexagon.positionInPoints.y - hexagon.positionInPoints.y, 2))) <= _hexagonHeight+1 && [_currentHexagon.color isEqual:hexagon.color]) {
        hexagon.scale = 1.2f;
        _currentHexagon = hexagon;
        [_selectedHexagons addObject:hexagon];
    }
}


- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    for (int i = 0; i < [_selectedHexagons count]; i++) {
        [_selectedHexagons[i] removeFromParent];
    }
    _score += (float)(([_selectedHexagons count]+1)/2.0f) * [_selectedHexagons count];
    [_selectedHexagons removeAllObjects];
}


- (Hexagon *) hexagonForTouchPosition:(CGPoint)touchPosition {
    
    int circle = 0;
    int hexagonNumber = 0;
    
    // Get the circle that was touched
    circle = ((sqrtf((powf(self.contentSizeInPoints.width/2 - touchPosition.x, 2)) + (powf(self.contentSizeInPoints.height/2 -  touchPosition.y, 2))) - (_hexagonHeight/2)) / (_hexagonHeight)) + 1;
    
    // Create two temporary variables used to find the hexagon number
    float positionX = self.contentSizeInPoints.width/2;
    float positionY = (self.contentSizeInPoints.height - ((GRID_CIRCLES - circle) * _hexagonHeight)) + _hexagonHeight/2;
    
    // Move the temporary position variables until they are inside the same hexagon that was touched
    while ((sqrtf(powf(positionX - touchPosition.x, 2) + powf(positionY - touchPosition.y, 2))) > (1.5) * _hexagonRadius) {
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

    return _gridArray[circle][hexagonNumber];
}

@end
