//
//  PGBoard.m
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGBoard.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface GGBoard : NSObject {
    PGPieceType _grid[GRID_SIZE][GRID_SIZE];
}

@end

@implementation PGBoard

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initBoard];
    }
    
    return self;
}

- (void)initBoard {
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            _grid[i][j] = PGPieceTypeBlank;
        }
    }
}

- (BOOL)isEmpty {
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            if (_grid[i][j] != PGPieceTypeBlank) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)canMoveAtPoint:(PGPoint)point {
    return _grid[point.i][point.j] == PGPieceTypeBlank;
}

- (void)makeMove:(PGMove *)move {
    PGPoint point = move.point;
    if ([self canMoveAtPoint:point]) {
        if (move.playerType == PGPlayerTypeBlack) {
            _grid[point.i][point.j] = PGPieceTypeBlack;
        } else {
            _grid[point.i][point.j] = PGPieceTypeWhite;
        }
    }
}

- (void)undoMove:(PGMove *)move {
    PGPoint point = move.point;
    _grid[point.i][point.j] = PGPieceTypeBlank;
}

- (BOOL)checkWinAtPoint:(PGPoint)point {
    int count = 1;
    int i = point.i;
    int j = point.j;
    
    // Horizontal
    for (j++; j < GRID_SIZE; j++) {
        if (_grid[i][j] == _grid[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    j = point.j;
    for (j--; j >= 0; j--) {
        if (_grid[i][j] == _grid[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Vertical
    i = point.i;
    j = point.j;
    for (i++; i < GRID_SIZE; i++) {
        if (_grid[i][j] == _grid[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i;
    for (i--; i >= 0; i--) {
        if (_grid[i][j] == _grid[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique up
    i = point.i + 1;
    j = point.j + 1;
    for (; i < GRID_SIZE && j < GRID_SIZE; i++, j++) {
        if (_grid[i][j] == _grid[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i - 1;
    j = point.j - 1;
    for (; i >= 0 && j >= 0; i--, j--) {
        if (_grid[i][j] == _grid[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique down
    i = point.i + 1;
    j = point.j - 1;
    for (; i < GRID_SIZE && j >= 0; i++, j--) {
        if (_grid[i][j] == _grid[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i - 1;
    j = point.j + 1;
    for (; i >= 0 && j < GRID_SIZE; i--, j++) {
        if (_grid[i][j] == _grid[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        return NO;
    }
}

- (PGMove *)getBestMove {
    return nil;
}

@end
