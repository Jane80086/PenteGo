//
//  PGPlayer.h
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGGreedyAI.h"
#import "PGMinimaxAI.h"

typedef NS_ENUM(NSInteger, PGDifficulty) {
    PGDifficultyEasy,
    PGDifficultyMedium,
    PGDifficultyHard
};

@interface PGPlayer : NSObject

- (instancetype)initWithPlayer:(PGPlayerType)playerType difficulty:(PGDifficulty)difficulty;
- (void)update:(PGMove *)move;
- (PGMove *)getMove;
- (void)regret:(PGMove *)move;

@end
