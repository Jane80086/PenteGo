//
//  PGMove.h
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PGPlayerType) {
    PGPlayerTypeBlack,
    PGPlayerTypeWhite
};

typedef struct {
    int i;
    int j;
} PGPoint;

@interface PGMove : NSObject

@property (nonatomic, readonly) PGPlayerType playerType;
@property (nonatomic, readonly) PGPoint point;

- (instancetype)initWithPlayer:(PGPlayerType)playerType point:(PGPoint)point;

@end
