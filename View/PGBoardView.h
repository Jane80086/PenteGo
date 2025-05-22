//
//  PGBoardView.h
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import <UIKit/UIKit.h>
#import "PGPlayer.h"

@protocol PGBoardViewDelegate;

@interface PGBoardView : UIView

@property (nonatomic, weak) id <PGBoardViewDelegate> delegate;

- (PGPoint)findPointWithLocation:(CGPoint)location;
- (void)insertPieceAtPoint:(PGPoint)point playerType:(PGPlayerType)playerType;
- (void)reset;
- (void)removeImageWithCount:(int)count;

@end

@protocol PGBoardViewDelegate <NSObject>

- (void)boardView:(PGBoardView *)boardView didTapOnPoint:(PGPoint)point;

@end
