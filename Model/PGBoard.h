//
//  PGBoard.h
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//
#import "PGMove.h"

static int const GRID_SIZE = 15;

typedef NS_ENUM(NSInteger, PGPieceType) {
    PGPieceTypeBlank,
    PGPieceTypeBlack,
    PGPieceTypeWhite
};

@interface PGBoard : NSObject
{
    @protected
    PGPieceType _grid[GRID_SIZE][GRID_SIZE];
}

- (instancetype)init;
- (void)initBoard;
- (BOOL)isEmpty;
- (BOOL)canMoveAtPoint:(PGPoint)point;
- (void)makeMove:(PGMove *)move;
- (void)undoMove:(PGMove *)move;
- (BOOL)checkWinAtPoint:(PGPoint)point;

- (PGMove *)getBestMove;

@end
