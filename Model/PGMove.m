//
//  PGMove.m
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGMove.h"

@implementation PGMove

- (instancetype)initWithPlayer:(PGPlayerType)playerType point:(PGPoint)point {
    self = [super init];
    
    if (self) {
        _playerType = playerType;
        _point = point;
    }
    
    return self;
}

@end
