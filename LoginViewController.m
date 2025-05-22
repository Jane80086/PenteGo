#import "LoginViewController.h"
#import "PGMenuController.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    self.usernameTextField.text = @"admin";
    self.passwordTextField.text = @"password";
}

- (void)setupUI {
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 150, self.view.frame.size.width - 100, 40)];
    self.usernameTextField.placeholder = @"Username";
    self.usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.usernameTextField];

    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 210, self.view.frame.size.width - 100, 40)];
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordTextField.secureTextEntry = YES;
    [self.view addSubview:self.passwordTextField];

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(50, 270, self.view.frame.size.width - 100, 50);
    [loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

- (void)loginAction {
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    // Implement login logic here
    if ([username isEqualToString:@"admin"] && [password isEqualToString:@"password"]) {
        NSLog(@"Login successful");
        // Transition to the next screen
       
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        [UIApplication sharedApplication].keyWindow.rootViewController = [sb instantiateInitialViewController];
    } else {
        NSLog(@"Login failed");
        // Show an error message
    }
}

@end 
