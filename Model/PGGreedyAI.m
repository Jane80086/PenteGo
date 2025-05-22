//
//  PGGreedyAI.m
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGGreedyAI.h"

typedef NS_ENUM(NSInteger, PGTupleType)
{
    PGTupleTypeBlank,
    PGTupleTypeB,
    PGTupleTypeBB,
    PGTupleTypeBBB,
    PGTupleTypeBBBB,
    PGTupleTypeW,
    PGTupleTypeWW,
    PGTupleTypeWWW,
    PGTupleTypeWWWW,
    PGTupleTypePolluted
};

@interface PGGreedyAI()
{
    PGPlayerType _playerType;
}

@end

@implementation PGGreedyAI

- (instancetype)initWithPlayer:(PGPlayerType)playerType {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
    }
    
    return self;
}

- (PGMove *)getBestMove {
    int maxScore = 0;
    PGPoint bestPoint;
    
    int index = 0;
    PGPoint bestPoints[GRID_SIZE * GRID_SIZE];
    
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            if (_grid[i][j] == PGPieceTypeBlank) {
                PGPoint point;
                point.i = i;
                point.j = j;
                
                int score = [self getScoreWithPoint:point];
                if (score == maxScore) {
                    bestPoints[index] = point;
                    index++;
                } else if (score > maxScore) {
                    maxScore = score;
                    index = 0;
                    bestPoints[index] = point;
                    index++;
                }
            }
        }
    }
    
    bestPoint = bestPoints[arc4random_uniform(index)];
    
    PGMove *bestMove = [[PGMove alloc] initWithPlayer:_playerType point:bestPoint];
    [self makeMove:bestMove];
    
    return bestMove;
}

- (int)getScoreWithPoint:(PGPoint)point {
    int score = 0;
    int i = point.i;
    int j = point.j;
    
    // Horizontal
    for (; i > point.i - 5; i--) {
        if (i >= 0 && i + 4 < GRID_SIZE) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; m < i + 5; m++) {
                if (_grid[m][n] == PGPieceTypeBlack) {
                    black++;
                }
                if (_grid[m][n] == PGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self evaluateWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white]];
        }
    }
    
    // Vertical
    i = point.i;
    for (; j > point.j - 5; j--) {
        if (j >= 0 && j + 4 < GRID_SIZE) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; n < j + 5; n++) {
                if (_grid[m][n] == PGPieceTypeBlack) {
                    black++;
                }
                if (_grid[m][n] == PGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self evaluateWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white]];
        }
    }
    
    // Oblique up
    i = point.i;
    j = point.j;
    for (; i > point.i - 5 && j > point.j - 5; i--, j--) {
        if (i >= 0 && j >= 0 && i + 4 < GRID_SIZE && j + 4 < GRID_SIZE) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; m < i + 5 && n < j + 5; m++, n++) {
                if (_grid[m][n] == PGPieceTypeBlack) {
                    black++;
                }
                if (_grid[m][n] == PGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self evaluateWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white]];
        }
    }
    
    // Oblique down
    i = point.i;
    j = point.j;
    for (; i > point.i - 5 && j < point.j + 5; i--, j++) {
        if (i >= 0 && j < GRID_SIZE && i + 4 < GRID_SIZE && j - 4 >= 0) {
            int m = i;
            int n = j;
            int black = 0;
            int white = 0;
            for (; m < i + 5 && n > j - 5; m++, n--) {
                if (_grid[m][n] == PGPieceTypeBlack) {
                    black++;
                }
                if (_grid[m][n] == PGPieceTypeWhite) {
                    white++;
                }
            }
            score += [self evaluateWithTuple:[self getTupleTypeWithBlackNum:black whiteNum:white]];
        }
    }
    
    return score;
}

- (PGTupleType)getTupleTypeWithBlackNum:(int)black whiteNum:(int)white {
    if (black + white == 0) {
        return PGTupleTypeBlank;
    }
    if (black == 1 && white == 0) {
        return PGTupleTypeB;
    }
    if (black == 2 && white == 0) {
        return PGTupleTypeBB;
    }
    if (black == 3 && white == 0) {
        return PGTupleTypeBBB;
    }
    if (black == 4 && white == 0) {
        return PGTupleTypeBBBB;
    }
    if (black == 0 && white == 1) {
        return PGTupleTypeW;
    }
    if (black == 0 && white == 2) {
        return PGTupleTypeWW;
    }
    if (black == 0 && white == 3) {
        return PGTupleTypeWWW;
    }
    if (black == 0 && white == 4) {
        return PGTupleTypeWWWW;
    } else {
        return PGTupleTypePolluted;
    }
}

- (int)evaluateWithTuple:(PGTupleType)tupleType {
    if (_playerType == PGPlayerTypeBlack) {
        switch (tupleType) {
            case PGTupleTypeBlank:
                return 7;
            case PGTupleTypeB:
                return 35;
            case PGTupleTypeBB:
                return 800;
            case PGTupleTypeBBB:
                return 15000;
            case PGTupleTypeBBBB:
                return 800000;
            case PGTupleTypeW:
                return 15;
            case PGTupleTypeWW:
                return 400;
            case PGTupleTypeWWW:
                return 1800;
            case PGTupleTypeWWWW:
                return 100000;
            case PGTupleTypePolluted:
                return 0;
        }
    } else {
        switch (tupleType) {
            case PGTupleTypeBlank:
                return 7;
            case PGTupleTypeB:
                return 15;
            case PGTupleTypeBB:
                return 400;
            case PGTupleTypeBBB:
                return 1800;
            case PGTupleTypeBBBB:
                return 100000;
            case PGTupleTypeW:
                return 35;
            case PGTupleTypeWW:
                return 800;
            case PGTupleTypeWWW:
                return 15000;
            case PGTupleTypeWWWW:
                return 800000;
            case PGTupleTypePolluted:
                return 0;
        }
    }
}

@end
