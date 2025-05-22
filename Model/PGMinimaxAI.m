//
//  PGMinimaxAI.m
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGMinimaxAI.h"

typedef NS_ENUM(NSInteger, PGTupleType)
{
    PGTupleTypeLiveOne = 10,
    PGTupleTypeDeadOne = 1,
    PGTupleTypeLiveTwo = 100,
    PGTupleTypeDeadTwo = 10,
    PGTupleTypeLiveThree = 1000,
    PGTupleTypeDeadThree = 100,
    PGTupleTypeLiveFour = 10000,
    PGTupleTypeDeadFour = 1000,
    PGTupleTypeFive = 100000
};

typedef struct {
    PGPoint point;
    int score;
} PGPointHelper;

@interface PGMinimaxAI()
{
    PGPlayerType _playerType;
    PGMove *_bestMove;
    int _maxDepth;
}

@end

@implementation PGMinimaxAI

- (instancetype)initWithPlayer:(PGPlayerType)playerType {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
    }
    
    return self;
}

- (void)setDepth:(int)depth {
    _maxDepth = depth;
}

- (PGMove *)getBestMove {
    int score;
    
    // iterative deepening
    for (int deep = 2; deep <= _maxDepth; deep += 2) {
        score = [self MinimaxWithDepth:deep who:1 alpha:-[self maxEvaluateValue] beta:[self maxEvaluateValue]];
        if (score >= PGTupleTypeLiveFour) {
            [self makeMove:_bestMove];
            return _bestMove;
        }
    }
    
    [self makeMove:_bestMove];
    return _bestMove;
}

- (int)MinimaxWithDepth:(int)depth who:(int)who alpha:(int)alpha beta:(int)beta {
    if (depth == 0 || [self finished]) {
        return who * [self evaluate];
    }
    
    int score;
    PGMove *bestMove;
    NSMutableArray *moves = [self getPossibleMoves];
    
    // moves are empty???
    
    if (who > 0) {
        for (PGMove *move in moves) {
            [self makeMove:move];
            [self switchPlayer];
            score = [self MinimaxWithDepth:depth - 1 who:-who alpha:alpha beta:beta];
            [self switchPlayer];
            [self undoMove:move];

            if (score > alpha) {
                alpha = score;
                bestMove = move;
                if (alpha >= beta) {
                    break;
                }
            }
        }
        
        _bestMove = bestMove;
        
        return alpha;
    } else {
        for (PGMove *move in moves) {
            [self makeMove:move];
            [self switchPlayer];
            score = [self MinimaxWithDepth:depth - 1 who:-who alpha:alpha beta:beta];
            [self switchPlayer];
            [self undoMove:move];
            
            if (score < beta) {
                beta = score;
                if (alpha >= beta) {
                    break;
                }
            }
        }
        
        return beta;
    }
}

- (NSMutableArray *)getPossibleMoves {
    NSMutableArray *moves = [NSMutableArray array];
    PGPointHelper points[GRID_SIZE * GRID_SIZE];
    int index = 0;
    
    for (int i = 0; i < GRID_SIZE; i++) {
        for (int j = 0; j < GRID_SIZE; j++) {
            PGPoint point;
            point.i = i;
            point.j = j;
            
            if ([self isNeighbour:point]) {
                PGPointHelper pointHelper;
                pointHelper.point = point;
                pointHelper.score = [self getScoreWithPoint:point];
                points[index] = pointHelper;
                index++;
            }
        }
    }
    
    // sort the points
    for (int i = 1; i < index; i++) {
        int j = i - 1;
        PGPointHelper temp = points[i];
        while (j >= 0 && temp.score > points[j].score) {
            points[j + 1] = points[j];
            j--;
        }
        points[j + 1] = temp;
    }
    
    // only return the first 10 points
    for (int i = 0; i < 10; i++) {
        PGMove *move = [[PGMove alloc] initWithPlayer:_playerType point:points[i].point];
        [moves addObject:move];
    }
    
    return moves;
}

- (BOOL)isNeighbour:(PGPoint)point {
    int i = point.i;
    int j = point.j;
    
    if (_grid[i][j] == PGPieceTypeBlank) {
        for (int m = i - 2; m <= i + 2; m++) {
            for (int n = j - 2; n <= j + 2; n++) {
                if (m >= 0 && m < GRID_SIZE && n >= 0 && n < GRID_SIZE) {
                    if (_grid[m][n] != PGPieceTypeBlank) {
                        return YES;
                    }
                }
            }
        }
    }
    
    return NO;
}

- (BOOL)finished {
    int blackScore = [self evaluateWithPieceType:PGPieceTypeBlack];
    int whiteScore = [self evaluateWithPieceType:PGPieceTypeWhite];
    
    if (blackScore >= PGTupleTypeFive || whiteScore >= PGTupleTypeFive) {
        return YES;
    }
    
    return NO;
}

- (int)evaluate {
    int blackScore = [self evaluateWithPieceType:PGPieceTypeBlack];
    int whiteScore = [self evaluateWithPieceType:PGPieceTypeWhite];
    
    if (_playerType == PGPlayerTypeBlack) {
        return blackScore - whiteScore;
    } else {
        return whiteScore - blackScore;
    }
}

- (int)evaluateWithPieceType:(PGPieceType)pieceType {
    int score = 0;
    
    // Horizontal
    for (int line = 0; line < GRID_SIZE; line++) {
        for (int index = 0; index < GRID_SIZE; index++) {
            if (_grid[line][index] == pieceType) {
                int block = 0;
                int piece = 1;
                
                // left
                if (index == 0 || _grid[line][index - 1] != PGPieceTypeBlank) {
                    block++;
                }
                
                // pieceNum
                for (index++; index < GRID_SIZE && _grid[line][index] == pieceType; index++) {
                    piece++;
                }
                
                // right
                if (index == GRID_SIZE || _grid[line][index] != PGPieceTypeBlank) {
                    block++;
                }
                
                score += [self evaluateWithBlock:block pieceNum:piece];
            }
        }
    }
    
    // Vertical
    for (int line = 0; line < GRID_SIZE; line++) {
        for (int index = 0; index < GRID_SIZE; index++) {
            if (_grid[index][line] == pieceType) {
                int block = 0;
                int piece = 1;
                
                // left
                if (index == 0 || _grid[index - 1][line] != PGPieceTypeBlank) {
                    block++;
                }
                
                // pieceNum
                for (index++; index < GRID_SIZE && _grid[index][line] == pieceType; index++) {
                    piece++;
                }
                
                // right
                if (index == GRID_SIZE || _grid[index][line] != PGPieceTypeBlank) {
                    block++;
                }
                
                score += [self evaluateWithBlock:block pieceNum:piece];
            }
        }
    }
    
    // Oblique up
    for (int line = 0; line < 21; line++) {
        int lineLength = GRID_SIZE - abs(line - 10);
        
        if (line <= 10) {
            for (int index = 0; index < lineLength; index++) {
                if (_grid[index][GRID_SIZE - lineLength + index] == pieceType) {
                    int block = 0;
                    int piece = 1;
                    
                    // left
                    if (index == 0 || _grid[index - 1][GRID_SIZE - lineLength + index - 1] != PGPieceTypeBlank) {
                        block++;
                    }
                    
                    // pieceNum
                    for (index++; index < lineLength && _grid[index][GRID_SIZE - lineLength + index] == pieceType; index++) {
                        piece++;
                    }
                    
                    // right
                    if (index == lineLength || _grid[index][GRID_SIZE - lineLength + index] != PGPieceTypeBlank) {
                        block++;
                    }
                    
                    score += [self evaluateWithBlock:block pieceNum:piece];
                }
            }
        } else {
            for (int index = 0; index < lineLength; index++) {
                if (_grid[GRID_SIZE - lineLength + index][index] == pieceType) {
                    int block = 0;
                    int piece = 1;
                    
                    // left
                    if (index == 0 || _grid[GRID_SIZE - lineLength + index - 1][index - 1] != PGPieceTypeBlank) {
                        block++;
                    }
                    
                    // pieceNum
                    for (index++; index < lineLength && _grid[GRID_SIZE - lineLength + index][index] == pieceType; index++) {
                        piece++;
                    }
                    
                    // right
                    if (index == lineLength || _grid[GRID_SIZE - lineLength + index][index] != PGPieceTypeBlank) {
                        block++;
                    }
                    
                    score += [self evaluateWithBlock:block pieceNum:piece];
                }
            }
        }
    }
    
    // Oblique down
    for (int line = 0; line < 21; line++) {
        int lineLength = GRID_SIZE - abs(line - 10);
        
        if (line <= 10) {
            for (int index = 0; index < lineLength; index++) {
                if (_grid[index][lineLength - 1 - index] == pieceType) {
                    int block = 0;
                    int piece = 1;
                    
                    // left
                    if (index == 0 || _grid[index - 1][lineLength - 1 - (index - 1)] != PGPieceTypeBlank) {
                        block++;
                    }
                    
                    // pieceNum
                    for (index++; index < lineLength && _grid[index][lineLength - 1 - index] == pieceType; index++) {
                        piece++;
                    }
                    
                    // right
                    if (index == lineLength || _grid[index][lineLength - 1 - index] != PGPieceTypeBlank) {
                        block++;
                    }
                    
                    score += [self evaluateWithBlock:block pieceNum:piece];
                }
            }
        } else {
            for (int index = 0; index < lineLength; index++) {
                if (_grid[GRID_SIZE - lineLength + index][GRID_SIZE - 1 - index] == pieceType) {
                    int block = 0;
                    int piece = 1;
                    
                    // left
                    if (index == 0 || _grid[GRID_SIZE - lineLength + index - 1][GRID_SIZE - 1 - (index - 1)] != PGPieceTypeBlank) {
                        block++;
                    }
                    
                    // pieceNum
                    for (index++; index < lineLength && _grid[GRID_SIZE - lineLength + index][GRID_SIZE - 1 - index] == pieceType; index++) {
                        piece++;
                    }
                    
                    // right
                    if (index == lineLength || _grid[GRID_SIZE - lineLength + index][GRID_SIZE - 1 - index] != PGPieceTypeBlank) {
                        block++;
                    }
                    
                    score += [self evaluateWithBlock:block pieceNum:piece];
                }
            }
        }
    }
    
    return score;
}

- (int)evaluateWithBlock:(int)block pieceNum:(int)piece {
    if (block == 0) {
        switch (piece) {
            case 1:
                return PGTupleTypeLiveOne;
            case 2:
                return PGTupleTypeLiveTwo;
            case 3:
                return PGTupleTypeLiveThree;
            case 4:
                return PGTupleTypeLiveFour;
            default:
                return PGTupleTypeFive;
        }
    } else if (block == 1) {
        switch (piece) {
            case 1:
                return PGTupleTypeDeadOne;
            case 2:
                return PGTupleTypeDeadTwo;
            case 3:
                return PGTupleTypeDeadThree;
            case 4:
                return PGTupleTypeDeadFour;
            default:
                return PGTupleTypeFive;
        }
    } else {
        if (piece >= 5) {
            return PGTupleTypeFive;
        } else {
            return 0;
        }
    }
}

- (int)maxEvaluateValue {
    return INT_MAX;
}

- (void)switchPlayer {
    if (_playerType == PGPlayerTypeBlack) {
        _playerType = PGPlayerTypeWhite;
    } else {
        _playerType = PGPlayerTypeBlack;
    }
}

@end
