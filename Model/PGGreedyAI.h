//
//  PGGreedyAI.h
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGBoard.h"

@interface PGGreedyAI : PGBoard

- (instancetype)initWithPlayer:(PGPlayerType)playerType;
- (int)getScoreWithPoint:(PGPoint)point;

@end


