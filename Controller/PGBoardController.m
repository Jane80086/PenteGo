//
//  PGBoardController.m
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGBoardController.h"
#import "PGPacket.h"
#import "PGHostListController.h"
#import "PGMenuController.h"

@import CocoaAsyncSocket;

NSString * const INFO_YOUR_TURN = @"您的回合";
NSString * const INFO_OPPONENT_TURN = @"对方回合";

@interface PGBoardController () <GCDAsyncSocketDelegate, PGHostListControllerDelegate> {
    PGBoard *board;
    PGPlayerType playerType;
    PGPlayer *AI;
    int timeSecBlack;
    int timeMinBlack;
    int timeSecWhite;
    int timeMinWhite;
    NSTimer *timer;
    BOOL isHost;
    BOOL oppositeReset;
    BOOL shouldDismiss;
    PGMove *whiteMove;
    PGMove *blackMove;
}

@property (weak, nonatomic) IBOutlet UILabel *lblInformation;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UILabel *timerWhiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerBlackLabel;
@property (strong, nonatomic) UIAlertController *resetWaitAlertController;
@property (strong, nonatomic) UIAlertController *resetChooseAlertController;
@property (strong, nonatomic) UIAlertController *resetRejectAlertController;
@property (strong, nonatomic) UIAlertController *waitAlertController;
@property (strong, nonatomic) UIAlertController *winAlertController;
@property (strong, nonatomic) UIAlertController *undoWaitAlertController;
@property (strong, nonatomic) UIAlertController *undoChooseAlertController;
@property (strong, nonatomic) UIAlertController *undoRejectAlertController;
@property (strong, nonatomic) GCDAsyncSocket *socket;


@end

@implementation PGBoardController

- (void)viewDidLoad {
    [super viewDidLoad];
    board = [[PGBoard alloc] init];
    
    // First piece will always be black
    playerType = PGPlayerTypeBlack;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _boardView.delegate = self;
    
    _btnUndo.enabled = NO;
    if (_gameMode == PGModeSingle) {
        [self choosePlayerType];
    } else if (_gameMode == PGModeDouble) {
        [self startTimer];
    } else if (_gameMode == PGModeLAN && shouldDismiss == YES) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (_gameMode == PGModeLAN && _socket == nil) {
        [self performSegueWithIdentifier:@"findGame" sender:nil];
    } else if (_gameMode == PGModeLAN && _socket != nil) {
        [self startGameInLANMode];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *destinationNavigationController = segue.destinationViewController;
    PGHostListController *targetController = (PGHostListController *)(destinationNavigationController.topViewController);
    targetController.delegate = self;
}


#pragma mark - Gomoku basic logic

- (void)startGameInLANMode {
    [self startTimer];
    if (!isHost) {
        _lblInformation.text = INFO_OPPONENT_TURN;
        self.waitAlertController = [UIAlertController alertControllerWithTitle:@"请等待对方先下" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:_waitAlertController animated:YES completion:nil];
    } else {
        _lblInformation.text = INFO_YOUR_TURN;
    }
    
}

- (void)choosePlayerType {

    PGDifficulty difficulty;
    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"difficulty"]) {
        case 0:
            difficulty = PGDifficultyEasy;
            break;
        case 1:
            difficulty = PGDifficultyMedium;
            break;
        case 2:
            difficulty = PGDifficultyHard;
            break;
        default:
            difficulty = PGDifficultyEasy;
            break;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择先后手" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionBlack = [UIAlertAction actionWithTitle:@"先手" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startTimer];
        self->AI = [[PGPlayer alloc] initWithPlayer:PGPlayerTypeWhite difficulty:difficulty];
        self->_lblInformation.text = INFO_YOUR_TURN;
    }];
    UIAlertAction *actionWhite = [UIAlertAction actionWithTitle:@"后手" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startTimer];
        self->AI = [[PGPlayer alloc] initWithPlayer:PGPlayerTypeBlack difficulty:difficulty];
        [self AIPlayWithMove:nil];
        self->_lblInformation.text = INFO_OPPONENT_TURN;
    }];
    [alert addAction:actionBlack];
    [alert addAction:actionWhite];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveMove:(PGMove *)move {
    if (playerType == PGPlayerTypeBlack) {
        blackMove = move;
    } else {
        whiteMove = move;
    }
}

- (void)moveAtPoint:(PGPoint)point sendPacketInLAN:(BOOL)sendPacket {
    if([board canMoveAtPoint:point]) {
        if (_gameMode == PGModeDouble) {
            _btnUndo.enabled = YES;
        }
        
        PGMove *move = [[PGMove alloc] initWithPlayer:playerType point:point];
        [board makeMove:move];
        [self saveMove:move];
        
        [_boardView insertPieceAtPoint:point playerType:playerType];
        
        // play move sound
        PGMenuController *menuController = (PGMenuController *)self.presentingViewController;
        [menuController.moveSoundPlayer play];
        
        if ([board checkWinAtPoint:point]) {
            if (_gameMode == PGModeLAN && sendPacket == YES) {
                NSDictionary *data = @{ @"i" : @(point.i), @"j" : @(point.j) };
                PGPacket *packet = [[PGPacket alloc] initWithData:data type:PGPacketTypeMove action:PGPacketActionUnknown];
                [self sendPacket:packet];
            }
            [self handleWin];
        } else {
            [self switchPlayer];
            
            if (_gameMode == PGModeSingle) {
                [self AIPlayWithMove:move];
            } else if (_gameMode == PGModeLAN && sendPacket == YES) {
                _btnUndo.enabled = NO;
                NSDictionary *data = @{ @"i" : @(point.i), @"j" : @(point.j) };
                PGPacket *packet = [[PGPacket alloc] initWithData:data type:PGPacketTypeMove action:PGPacketActionUnknown];
                [self sendPacket:packet];
                _boardView.userInteractionEnabled = NO;
            } else if (_gameMode == PGModeLAN && sendPacket == NO) {
                _boardView.userInteractionEnabled = YES;
            }
        }
    }
}

- (void)AIPlayWithMove:(PGMove *)move {
    _btnReset.enabled = NO;
    _btnUndo.enabled = NO;
    _boardView.userInteractionEnabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self->AI update:move];
        PGMove *AIMove = [self->AI getMove];
        [self->board makeMove:AIMove];
        [self saveMove:AIMove];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_btnReset.enabled = YES;
            if (self->blackMove != nil && self->whiteMove != nil) {
                self->_btnUndo.enabled = YES;
            }
            
            [self->_boardView insertPieceAtPoint:AIMove.point playerType:AIMove.playerType];
            
            // play move sound
            PGMenuController *menuController = (PGMenuController *)self.presentingViewController;
            [menuController.moveSoundPlayer play];
            
            if ([self->board checkWinAtPoint:AIMove.point]) {
                [self handleWin];
                NSLog(@"win %ld", (long)self->playerType);
            } else {
                [self switchPlayer];
                self->_boardView.userInteractionEnabled = YES;
            }
        });
        
    });
    
}

- (void)handleWin {
    NSString *alertTitle;
    if (playerType == PGPlayerTypeBlack) {
        alertTitle = @"黑方获胜!";
    } else {
        alertTitle = @"白方获胜!";
    }
    
    [self dismissAlertControllers];
    
    self.winAlertController = [UIAlertController alertControllerWithTitle:alertTitle message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [_winAlertController addAction:action];
    [self presentViewController:_winAlertController animated:YES completion:nil];
    
    _btnReset.enabled = YES;
    _btnUndo.enabled = NO;
    _boardView.userInteractionEnabled = NO;
    [self stopTimer];
}

- (void)handleReset {
    [self stopTimer];
    [board initBoard];
    _boardView.userInteractionEnabled = YES;
    playerType = PGPlayerTypeBlack;
    [_boardView reset];
    _btnUndo.enabled = NO;
    blackMove = nil;
    whiteMove = nil;
}

- (void)switchPlayer {
    if (playerType == PGPlayerTypeBlack) {
        playerType = PGPlayerTypeWhite;
    } else {
        playerType = PGPlayerTypeBlack;
    }
    if (_lblInformation.text == INFO_YOUR_TURN) {
        _lblInformation.text = INFO_OPPONENT_TURN;
    } else if (_lblInformation.text == INFO_OPPONENT_TURN) {
        _lblInformation.text = INFO_YOUR_TURN;
    }
}

- (void)startTimer {
    // initialize the timer label
    timeSecBlack = 0;
    timeMinBlack = 0;
    timeSecWhite = 0;
    timeMinWhite = 0;
    
    NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinBlack, timeSecBlack];
    
    _timerWhiteLabel.text = timeNow;
    _timerBlackLabel.text = timeNow;
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}

- (void)stopTimer
{
    [timer invalidate];
    timer = nil;
}

- (void)timerTick:(NSTimer *)timer {
    if (playerType == PGPlayerTypeBlack) {
        timeSecBlack++;
        if (timeSecBlack == 60)
        {
            timeSecBlack = 0;
            timeMinBlack++;
        }
        //Format the string 00:00
        NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinBlack, timeSecBlack];
        _timerBlackLabel.text= timeNow;
    } else {
        timeSecWhite++;
        if (timeSecWhite == 60)
        {
            timeSecWhite = 0;
            timeMinWhite++;
        }
        //Format the string 00:00
        NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinWhite, timeSecWhite];
        _timerWhiteLabel.text= timeNow;
    }
}

- (void) dismissAlertControllers {
    [_winAlertController dismissViewControllerAnimated:YES completion:nil];
    [_waitAlertController dismissViewControllerAnimated:YES completion:nil];
    [_resetWaitAlertController dismissViewControllerAnimated:YES completion:nil];
    [_resetChooseAlertController dismissViewControllerAnimated:YES completion:nil];
    [_resetRejectAlertController dismissViewControllerAnimated:YES completion:nil];
    [_undoWaitAlertController dismissViewControllerAnimated:YES completion:nil];
    [_undoChooseAlertController dismissViewControllerAnimated:YES completion:nil];
    [_undoRejectAlertController dismissViewControllerAnimated:YES completion:nil];
    
    self.winAlertController = nil;
    self.waitAlertController = nil;
    self.resetWaitAlertController = nil;
    self.resetChooseAlertController = nil;
    self.resetRejectAlertController = nil;
    self.undoWaitAlertController = nil;
    self.undoChooseAlertController = nil;
    self.undoRejectAlertController = nil;
}


#pragma mark - Socket related functions

- (void)sendPacket:(PGPacket *)packet {
    
    // Encode Packet Data
    NSMutableData *packetData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:packetData];
    [archiver encodeObject:packet forKey:@"packet"];
    [archiver finishEncoding];
    
    // Initialize Buffer
    NSMutableData *buffer = [[NSMutableData alloc] init];
    
    // Fill Buffer
    [buffer appendBytes:packetData.bytes length:packetData.length];
    
    [_socket writeData:buffer withTimeout:-1.0 tag:0];
    
}


- (void)parseData:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    PGPacket *packet = [unarchiver decodeObjectForKey:@"packet"];
    [unarchiver finishDecoding];


    if ([packet type] == PGPacketTypeMove) {
        NSNumber *i = [(NSDictionary *)[packet data] objectForKey:@"i"];
        
        NSNumber *j = [(NSDictionary *)[packet data] objectForKey:@"j"];
        
        PGPoint point;
        point.i = i.intValue;
        point.j = j.intValue;
        
        if (_waitAlertController != nil) {
            [_waitAlertController dismissViewControllerAnimated:YES completion:nil];
            self.waitAlertController = nil;
        }
        
        [self moveAtPoint:point sendPacketInLAN:NO];
        if (blackMove != nil && whiteMove != nil && ![board checkWinAtPoint:point]) {
            _btnUndo.enabled = YES;
        }
        
        
    } else if ([packet type] == PGPacketTypeReset) {
        if ([packet action] == PGPacketActionResetRequest) {
            
            [self dismissAlertControllers];
            
            self.resetChooseAlertController = [UIAlertController alertControllerWithTitle:@"对方请求重开" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionAgree = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                PGPacket *packet = [[PGPacket alloc] initWithData:nil type:PGPacketTypeReset action:PGPacketActionResetAgree];
                [self sendPacket:packet];
                [self handleReset];
                [self startGameInLANMode];
            }];

            UIAlertAction *actionReject = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                PGPacket *packet = [[PGPacket alloc] initWithData:nil type:PGPacketTypeReset action:PGPacketActionResetReject];
                [self sendPacket:packet];
            }];
            
            [_resetChooseAlertController addAction:actionAgree];
            [_resetChooseAlertController addAction:actionReject];
            [self presentViewController:_resetChooseAlertController animated:YES completion:nil];
            
        } else if ([packet action] == PGPacketActionResetAgree) {
            [self dismissAlertControllers];
            
            [self handleReset];
            [self startGameInLANMode];
            
        } else if ([packet action] == PGPacketActionResetReject) {
            [self dismissAlertControllers];
            
            self.resetRejectAlertController = [UIAlertController alertControllerWithTitle:@"对方拒绝了你的请求" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [_resetRejectAlertController addAction:action];
            [self presentViewController:_resetRejectAlertController animated:YES completion:nil];
        }
        
    } else if (packet.type == PGPacketTypeUndo) {
        if (packet.action == PGPacketActionUndoRequest) {
            [self dismissAlertControllers];
            
            self.undoChooseAlertController = [UIAlertController alertControllerWithTitle:@"对方请求悔棋" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionAgree = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                PGPacket *packet = [[PGPacket alloc] initWithData:nil type:PGPacketTypeUndo action:PGPacketActionUndoAgree];
                [self sendPacket:packet];
                [self->board undoMove:self->blackMove];
                [self->board undoMove:self->whiteMove];
                [self->_boardView removeImageWithCount:2];
                self->blackMove = nil;
                self->whiteMove = nil;
                self->_btnUndo.enabled = NO;
            }];
            
            UIAlertAction *actionReject = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                PGPacket *packet = [[PGPacket alloc] initWithData:nil type:PGPacketTypeUndo action:PGPacketActionUndoReject];
                [self sendPacket:packet];
            }];
            
            [_undoChooseAlertController addAction:actionAgree];
            [_undoChooseAlertController addAction:actionReject];
            [self presentViewController:_undoChooseAlertController animated:YES completion:nil];
        } else if (packet.action == PGPacketActionUndoAgree) {
            [self dismissAlertControllers];
            
            [board undoMove:blackMove];
            [board undoMove:whiteMove];
            [_boardView removeImageWithCount:2];
            blackMove = nil;
            whiteMove = nil;
            _btnUndo.enabled = NO;
        } else if (packet.action == PGPacketActionUndoReject) {
            [self dismissAlertControllers];
            
            self.undoRejectAlertController = [UIAlertController alertControllerWithTitle:@"对方拒绝了你的请求" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [_undoRejectAlertController addAction:action];
            [self presentViewController:_undoRejectAlertController animated:YES completion:nil];
        }
    }
}


#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)tag {
    [self parseData:data];
    [socket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    if (error) {
        NSLog(@"Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
    } else {
        NSLog(@"Socket Disconnect.");
    }
    
    if (_socket == socket) {
        _socket.delegate = nil;
        _socket = nil;
    }
    [self stopTimer];
    
    [self dismissAlertControllers];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"对方已经断开连接" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - PGBoardViewDelegate

- (void)boardView:(PGBoardView *)boardView didTapOnPoint:(PGPoint)point {
    [self moveAtPoint:point sendPacketInLAN:YES];
}


#pragma mark - GGHostListControllerDelegate

- (void)controller:(PGHostListController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket {
    self.socket = socket;
    [_socket setDelegate:self];
    _boardView.userInteractionEnabled = NO;
    isHost = NO;
    
    [_socket readDataWithTimeout:-1 tag:1];
    
}

- (void)controller:(PGHostListController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket {
    self.socket = socket;
    [_socket setDelegate:self];
    isHost = YES;
    [_socket readDataWithTimeout:-1 tag:1];
}

- (void)shouldDismiss {
    shouldDismiss = YES;
}


#pragma mark - IBAction

- (IBAction)btnReset_TouchUp:(UIButton *)sender {

    if (_gameMode == PGModeSingle) {
        [self handleReset];
        [self choosePlayerType];
    } else if (_gameMode == PGModeDouble){
        [self handleReset];
        [self startTimer];
    } else if (_gameMode == PGModeLAN) {
        if (oppositeReset == YES) {
            [self handleReset];
            [self startGameInLANMode];
            
            oppositeReset = NO;
            NSString *data = @"reset";
            PGPacket *packet = [[PGPacket alloc] initWithData:data type:PGPacketTypeReset action:PGPacketActionUnknown];
            [self sendPacket:packet];
        } else {
            self.resetWaitAlertController = [UIAlertController alertControllerWithTitle:@"等待对方回应" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:_resetWaitAlertController animated:YES completion:nil];
            
            PGPacket *packet = [[PGPacket alloc] initWithData:nil type:PGPacketTypeReset action:PGPacketActionResetRequest];
            [self sendPacket:packet];
        }
    }
    
}

- (IBAction)btnUndo_TouchUp:(UIButton *)sender {
    if (_gameMode == PGModeSingle) {
        if (blackMove != nil && whiteMove != nil) {
            [board undoMove:blackMove];
            [board undoMove:whiteMove];
            [AI regret:blackMove];
            [AI regret:whiteMove];
            [_boardView removeImageWithCount:2];
            blackMove = nil;
            whiteMove = nil;
            _btnUndo.enabled = NO;
        }
    } else if (_gameMode == PGModeDouble) {
        if (playerType == PGPlayerTypeBlack) {
            [board undoMove:whiteMove];
            [_boardView removeImageWithCount:1];
            [self switchPlayer];
            _btnUndo.enabled = NO;
            whiteMove = nil;
        } else {
            [board undoMove:blackMove];
            [_boardView removeImageWithCount:1];
            [self switchPlayer];
            _btnUndo.enabled = NO;
            blackMove = nil;
        }
    } else if (_gameMode == PGModeLAN) {
        self.undoWaitAlertController = [UIAlertController alertControllerWithTitle:@"等待对方回应" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:_undoWaitAlertController animated:YES completion:nil];
        
        PGPacket *packet = [[PGPacket alloc] initWithData:nil type:PGPacketTypeUndo action:PGPacketActionUndoRequest];
        [self sendPacket:packet];

    }
    
}

- (IBAction)btnBack_TouchUp:(UIButton *)sender {
    [timer invalidate];
    timer = nil;
    [_socket disconnect];
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end



