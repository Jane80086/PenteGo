//
//  PGBoardController.h
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import <UIKit/UIKit.h>
#import "PGBoardView.h"
#import "PGPlayer.h"

@class GCDAsyncSocket;

typedef NS_ENUM(NSInteger, PGMode)
{
    PGModeSingle,
    PGModeDouble,
    PGModeLAN
};

@interface PGBoardController : UIViewController <PGBoardViewDelegate>

@property (weak, nonatomic) IBOutlet PGBoardView *boardView;
@property (assign, nonatomic) enum PGMode gameMode;

@end
