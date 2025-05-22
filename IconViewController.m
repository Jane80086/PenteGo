#import "IconViewController.h"

@interface IconViewController ()

@end

@implementation IconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)setupUI {
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_icon"]];
    iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    iconImageView.frame = CGRectMake(50, 100, self.view.frame.size.width - 100, self.view.frame.size.width - 100);
    [self.view addSubview:iconImageView];

    UILabel *appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(iconImageView.frame) + 20, self.view.frame.size.width - 100, 50)];
    appNameLabel.text = @"Pente Go";
    appNameLabel.textAlignment = NSTextAlignmentCenter;
    appNameLabel.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:appNameLabel];
}

@end 