//
//  PGPlayer.m
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGPlayer.h"

@interface PGPlayer ()
{
    PGPlayerType _playerType;
    PGBoard *_board;
}

@end

@implementation PGPlayer

- (instancetype)initWithPlayer:(PGPlayerType)playerType difficulty:(PGDifficulty)difficulty {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
        
        switch (difficulty) {
            case PGDifficultyEasy:
                _board = [[PGGreedyAI alloc] initWithPlayer:playerType];
                break;
            case PGDifficultyMedium:
                _board = [[PGMinimaxAI alloc] initWithPlayer:playerType];
                [(PGMinimaxAI *)_board setDepth:6];
                break;
            case PGDifficultyHard:
                _board = [[PGMinimaxAI alloc] initWithPlayer:playerType];
                [(PGMinimaxAI *)_board setDepth:8];
                break;
        }
    }
    
    return self;
}

- (void)update:(PGMove *)move {
    if (move != nil) {
        [_board makeMove:move];
    }
}

- (void)regret:(PGMove *)move {
    if (move != nil) {
        [_board undoMove:move];
    }
}

- (PGMove *)getMove {
    if ([_board isEmpty]) {
        PGPoint point;
        point.i = 7;
        point.j = 7;
        PGMove *move = [[PGMove alloc] initWithPlayer:_playerType point:point];
        [self update:move];
        return move;
    } else {
        PGMove *move = [_board getBestMove];
        return move;
    }
}

@end
