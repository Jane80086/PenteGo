//
//  SceneDelegate.m
//  Pente Go
//
//  Created by GQQ on 2025/4/18.
//

#import "SceneDelegate.h"
#import "LoginViewController.h"
@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    // 1. 检查传入的 scene 是否是 UIWindowScene 类型
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
    
    // 2. 转换 scene 为 UIWindowScene
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    
    // 3. 创建 UIWindow 并关联 windowScene
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
//    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    // 4. 设置根视图控制器（示例：使用 LoginViewController）
    LoginViewController *rootViewController = [[LoginViewController alloc] init];
    rootViewController.view.backgroundColor = [UIColor whiteColor]; // 设置背景颜色
    
    // 也可以使用 UINavigationController 或 UITabBarController
    // UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    self.window.rootViewController = rootViewController;
    
    // 5. 显示 window
    [self.window makeKeyAndVisible];
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
