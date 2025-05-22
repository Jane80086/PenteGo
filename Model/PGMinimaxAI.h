//
//  PGMinimaxAI.h
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGGreedyAI.h"

@interface PGMinimaxAI : PGGreedyAI

- (instancetype)initWithPlayer:(PGPlayerType)playerType;
- (void)setDepth:(int)depth;

@end
