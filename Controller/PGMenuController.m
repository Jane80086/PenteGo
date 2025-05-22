//
//  PGMenuController.m
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGMenuController.h"
#import "PGBoardController.h"
#import "PGPlayer.h"

NSString * const MUSIC_NAME = @"music.mp3";
NSString * const MOVE_SOUND_NAME = @"move.wav";

@interface PGMenuController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
- (IBAction)btnSinglePlayer_TouchUp:(UIButton *)sender;
- (IBAction)btnDoublePlayer_TouchUp:(UIButton *)sender;
- (IBAction)btnSetting_TouchUp:(UIButton *)sender;

@end

@implementation PGMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.presentingViewController);
    NSLog(@"%@", self.presentedViewController);
    [self setupBackgroundImage];
    [self initPlayers];
}

- (void)initPlayers {
    _musicPlayer = [self playerWithFile:MUSIC_NAME];
    _musicPlayer.numberOfLoops = -1;
    
    _moveSoundPlayer = [self playerWithFile:MOVE_SOUND_NAME];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"music"] == 1) {
        [_musicPlayer play];
    }
}

- (AVAudioPlayer *)playerWithFile:(NSString *)file {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    
    return player;
}

- (void)setupBackgroundImage {
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundImage.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.backgroundImage.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.backgroundImage.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.backgroundImage.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
}


- (IBAction)btnSinglePlayer_TouchUp:(UIButton *)sender {
    [self performSegueWithIdentifier:@"startGame" sender:sender];
}

- (IBAction)btnDoublePlayer_TouchUp:(UIButton *)sender {
    [self performSegueWithIdentifier:@"startGame" sender:sender];
}
- (IBAction)btnLANGame_TouchUp:(UIButton *)sender {
    [self performSegueWithIdentifier:@"startGame" sender:sender];
}

- (IBAction)btnSetting_TouchUp:(UIButton *)sender {
    [self performSegueWithIdentifier:@"settings" sender:sender];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"startGame"]) {
        UIButton *button = (UIButton *)sender;
        PGBoardController *boardController = segue.destinationViewController;
        if ([button.titleLabel.text isEqualToString:@"单人游戏"]) {
            boardController.gameMode = PGModeSingle;
        } else if ([button.titleLabel.text isEqualToString:@"双人游戏"]) {
            boardController.gameMode = PGModeDouble;
        } else if ([button.titleLabel.text isEqualToString:@"联机游戏"]) {
            boardController.gameMode = PGModeLAN;
        }
    }
}
@end
