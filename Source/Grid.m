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
static const int GRID_COLUMNS = 9;
static const int GRID_SIDE = 5;
// GRID_SIDE is also equal to ((GRID_COLUMNS+1)/2)

@implementation Grid {
    // Declare the array for the grid. It is the number of columns in the grid
    NSMutableArray *_gridArray;
    
    // The height (2*apothem) and the radius of the hexagon
    float _hexagonHeight;
    float _hexagonRadius;
}

- (void) onEnter {
    [super onEnter];
    
    [self setupGrid];
    
    // Accept touches on the grid
    self.userInteractionEnabled = true;
}


- (void) setupGrid {
    
    // Divide the grid's height by the number of vertical cells in the highest column (which is equal to the number of columns in the grid) to figure out the height of each cell
    _hexagonHeight = self.contentSize.height / GRID_COLUMNS;
    
    // Do some math to find the radius of the hexagon
    _hexagonRadius = ((_hexagonHeight*(sqrt(3)))/3);
    
    
    // columnCount is a value equal to the number of hexagons in the current column
    NSInteger columnCount = GRID_SIDE;
    
    // x and y are the positions of the hexagons that will be initialized later
    float x = (_hexagonRadius);
    float y = self.contentSize.height;
    
    // Position the first hexagon
    for (int i = 0; i < GRID_SIDE; i++) {
        y -= (_hexagonHeight/2);
    }
    
    
    // Initialize the array for the grid as a blank NSMutableArray. It is the number of columns in the grid
    _gridArray = [[NSMutableArray alloc]init];
    
    // Initialize Hexagons
    for (int i = 0; i < GRID_COLUMNS; i++){
        // Loops a number of times equal to the number of columns in the grid
        // The current column number is the variable "i"
        
        // Temporary array used to create the 2-d array "_gridArray"
        NSMutableArray *temporaryArray = [[NSMutableArray alloc]init];
        
        for (int j = 0; j < columnCount; j++) {
            // Load the hexagon onto the screen
            Hexagon *hexagon = (Hexagon*)[CCBReader load:@"Hexagon"];
            hexagon.positionInPoints = ccp(x, y);
            [self addChild:hexagon];
            
            // Add the hexagon to the temporary array
            [temporaryArray addObject: hexagon];
            
            // Positioning for the next hexagon
            y -= _hexagonHeight;
        }
        
        // Add the temporary array to _gridArray to form the 2-d array
        [_gridArray addObject:temporaryArray];
        
        
        // Reposition x and y after all hexagons in current column have been initiated
        for (int k = 0; k < columnCount; k++) {
            y += _hexagonHeight;
        }
        if (i >= ((GRID_COLUMNS-1)/2)) {
            y -= (_hexagonHeight/2);
        } else {
            y += (_hexagonHeight/2);
        }
        x += (1.5)*_hexagonRadius;
        
        
        // Increase the number of hexagons in the next column by 1 if we are not yet halfway through the columns, decrease the number of hexagons in the next column by 1 if we are more than halfway through the columns
        if (i >= ((GRID_COLUMNS-1)/2)) {
            columnCount--;
        } else {
            columnCount++;
        }
    }
}


- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // Get the x and y coordinates of the touch
    CGPoint touchLocation = [touch locationInNode:self];
    
    // Get the Hexagon at that location
    Hexagon *hexagon = [self hexagonForTouchPosition:touchLocation];
    
    // Remove the Hexagon that was touched
    if (hexagon != nil) {
        [hexagon removeFromParent];
    }
}


- (Hexagon *) hexagonForTouchPosition:(CGPoint)touchPosition {
    
    // Get the column that was touched
    int column = touchPosition.x / (1.5*_hexagonRadius);
    
    // Get the row that was touched (Takes multiple steps!). Position is a temporary variable to help find row
    float position = self.contentSize.height;
    int row = 0;
    // columnCount is a value equal to the number of hexagons in the current column (Used in finding row)
    NSInteger columnCount = GRID_SIDE;
    
    // Find the number of hexagons in the column that was touched
    for (int i = 0; i < column; i++) {
        // Increase the number of hexagons in the next column by 1 if we are not yet halfway through the columns, decrease the number of hexagons in the next column by 1 if we are more than halfway through the columns
        if (i >= ((GRID_COLUMNS-1)/2)) {
            columnCount--;
        } else {
            columnCount++;
        }
    }
    
    // Set position to the y value (position) of the first hexagon in the touched column
    for (int i = GRID_COLUMNS; i > columnCount; i--) {
        position -= (_hexagonHeight/2);
    }
    position -= (_hexagonHeight/2);
    
    // Return nil if the user touched above the first hexagon in the touched column
    if (touchPosition.y > (position + _hexagonHeight/2)) {
        return nil;
    }
    
    // Move position until it is in the same hexagon as row
    while (position > (touchPosition.y + (_hexagonHeight/2))){
        position -= (_hexagonHeight);
        row++;
    }
    // Return nil if the user touched below the last hexagon in the touched column
    if (row < columnCount && column < GRID_COLUMNS) {
            return _gridArray[column][row];
    } else {
        return nil;
    }
}

@end
