一、实验名称：Pente Go 五子棋游戏
实验项目：实现 Pente Go 应用程序中的游戏模式选择功能。
实验目的：确保点击不同的游戏模式按钮能够正确启动相应的游戏模式。
二、实验背景
（1）使用的工具与技术：
1、	Objective-C：主要编程语言。
2、	UIKit：用于构建用户界面。UIKit 是 Apple 提供的一个框架，用于构建 iOS 和 tvOS 应用程序的用户界面。它提供了一整套用于管理应用程序界面、处理用户交互、动画、绘图和事件响应的工具和类。UIKit 是开发 iOS 应用程序的核心框架之一。
3、	CocoaAsyncSocket：用于处理网络通信。在代码库中主要用于处理异步套接字通信。它提供了GCDAsyncSocket和GCDAsyncUdpSocket这样的类，分别用于TCP和UDP套接字操作。这些类设计为与Grand Central Dispatch (GCD)一起工作，以提供非阻塞的套接字操作，用于保持应用程序的响性。
4、	NSNotificationCenter：在代码库中主要用于在应用程序的不同部分之间传递消息和事件。它允许对象在不直接引用彼此的情况下进行通信。
5、	AVFoundation：AVFoundation在代码库中主要用于音频播放功能。它提供了强大的音频和视频处理能力，适用于多媒体应用程序。
6、	MVC架构：用于组织代码结构。MVC模式将应用程序分为三个主要部分：模型（Model）、视图（View）和控制器（Controller），每个部分负责不同的功能。Model（模型）：在Pente Go/Model目录下，包含了PGMove.m、PGBoard.m等文件，这些文件负责处理游戏的核心数据和逻辑。View（视图）：在Pente Go/View目录下，包含了如PGBoardView.m文件，负责呈现用户界面和用户交互。Controller（控制器）：在Pente Go/Controller目录下，包含了如PGMenuController.m、PGBoardController.m等文件，负责处理用户输入并更新模型和视图。
 
图1:代码MVC架构图
7、	NSUserDefaults：在代码库中主要用于存储和检索用户偏好设置。它提供了一种简单的方法来保存应用程序的设置和状态信息，以便在应用程序重新启动时可以恢复这些信息。
8、	UIAlertController：在代码库中主要用于显示各种警告和选择对话框，以便与用户进行交互。它提供了一种标准的方式来显示警告信息、请求用户输入或选择。在PGBoardController.m文件中，UIAlertController被用于多个场景，例如：在startGameInLANMode方法中，用于显示“请等待对方先下”的信息。在choosePlayerType方法中，用于让用户选择先手或后手。在handleWin方法中，用于显示获胜信息。在parseData方法中，用于处理对方请求重开或悔棋的情况。
（2）代码中使用的设计模式
1、	单例模式
在Alamofire库中，Session类的单例模式通过静态属性default ‘public static let `default` = Session()’实现。这个单例实例用于所AF.request API调用，确保网络请求的配置和管理在朕哥哥应用中是一致的。这能够为代码提供一个全局访问点，方便在应用的任何地方使用相同的Session实例，确保所有网络请求的行为一致，便于管理和调试。 
2、	委托模式
在CocoaAsyncSocket库中，GCDAsyncSocket类通过delegate属性使用委托模式，在GCDAsyncSocket.m中，GCDAsyncSocket类通过委托处理异步事件和回调：
‘@interface GCDAsyncSocket : NSObject
@property (nonatomic, weak) id<GCDAsyncSocketDelegate> delegate;
@end’
通过设置delegate属性，GCDAsyncSocket可以将网络时间的处理委托实现了GCDAsyncSocketDelegate协议的对象。这将网络事件的处理与GCDAsyncSocket类本身节藕，便于代码的维护和扩展。
3、	工厂方法
在Alamofire库中，工厂方法用于创建和配置网络请求对象。工厂方法用于创建和配置网络请求对象。工厂方法通过定义一个接口来创建对象，而不是直接实例化类。在RequestInterceptor.swift中，interceptor方法中，Interceptor实例：
‘public static func interceptor(adapter: @escaping AdaptHandler, retrier: @escaping RetryHandler) -> Interceptor {
    Interceptor(adaptHandler: adapter, retryHandler: retrier)
}’
这能够将对象的创建过程封装在工厂方法中，简化了客户端代码。
4、	观察者模式
在NSNotificationCenter中，使用了观察者模式来实现事件广播和监听。观察者模式允许对象在不直接饮用彼此的情况下进行通信。在GCDAsyncSocket.m中，NSNotificationCenter用于监听应用程序状态的变化：
‘#if TARGET_OS_IPHONE
[[NSNotificationCenter defaultCenter] addObserver:self                          selector:@selector(applicationWillEnterForeground:)                                 name:UIApplicationWillEnterForegroundNotification
                                          object:nil];
#endif’
通过这种方式，GCDAsyncSocket可以在应用程序进入前台时执行特定的操作。这与讯对象在不直接引用彼此的情况下进行通信，减少了对象之间的耦合的同时能够实时响应应用程序状态的变化，执行相应的操作。
（3）	游戏具体实现方法
1、	单人游戏
在人机模式下，AI 共有三种听力选择。简单难度的 AI 通过贪心算法实现，难度和困难难度的 AI 基于极小化极大算法实现。算法通过多种方式优化，在困难难度下，博弈树深度达到 8 层。
1.1、	贪心算法
贪心算法的基本思路是评估当前棋局中所有可能的落子位置，通过一个评分表为每个位置打分，然后随机选择一个得分最高的位置进行落子。在五子棋中，五个连续的棋盘位置被称为五元组。对于每一个可以落子的棋位，我们会检查所有包含该位置的五元组，并根据五元组中黑棋和白棋的数量来计算得分。最终，该位置的得分是所有相关五元组得分的总和。以下是游戏中用于黑棋的评分表：
// tuple is empty  
PGTupleTypeBlank = 7,  
// tuple contains a black chess  
PGTupleTypeB = 35,  
// tuple contains two black chesses  
PGTupleTypeBB = 800,  
// tuple contains three black chesses  
PGTupleTypeBBB = 15000,  
// tuple contains four black chesses  
PGTupleTypeBBBB = 800000,  
// tuple contains a white chess  
PGTupleTypeW = 15,  
// tuple contains two white chesses  
PGTupleTypeWW = 400,  
// tuple contains three white chesses  
PGTupleTypeWWW = 1800,  
// tuple contains four white chesses  
PGTupleTypeWWWW = 100000,  
// tuple contains at least one black and at least one white  
PGTupleTypePolluted = 0
1.2、	极小化极大算法
最大最小值是指玩家在不知道其他玩家行动的情况下，能够确保获得的最高值；换句话说，它是其他玩家在知道该玩家行动的情况下，能够强迫该玩家获得的最低值。其正式定义如下： 
 
计算玩家的最大化最小值时，采用最坏情况法：对于玩家的每一个可能行动，我们都会检查其他玩家所有可能行动，并确定最坏的行动组合——即让玩家获得最小值的行动组合。然后，我们确定玩家i可以采取哪些行动，以确保这个最小值是可能的最大值。
以下为相关算法：
- (int)evaluateWithBlock:(int)block pieceNum:(int)piece {
    if (block == 0) {
        switch (piece) {
            case 1:
                return PGTupleTypeLiveOne;
            case 2:
                return PGTupleTypeLiveTwo;
            case 3:
                return PGTupleTypeLiveThree;
            case 4:
                return PGTupleTypeLiveFour;
            default:
                return PGTupleTypeFive;
        }
    } else if (block == 1) {
        switch (piece) {
            case 1:
                return PGTupleTypeDeadOne;
            case 2:
                return PGTupleTypeDeadTwo;
            case 3:
                return PGTupleTypeDeadThree;
            case 4:
                return PGTupleTypeDeadFour;
            default:
                return PGTupleTypeFive;
        }
    } else {
        if (piece >= 5) {
            return PGTupleTypeFive;
        } else {
            return 0;
        }
    }
}
2、	双人游戏
支持两位玩家在同一手机进行游戏操作。
3、联机游戏
在邻居连接模式下，使用同一个子网的手机可以通过网络进行连接并一起下棋。游戏使用Bonjour（维基页面）作为邻居内广播服务（棋局）并寻找棋局的解决方案。当棋局后，游戏找到GCDAsyncSocket来建立网络连接，首先进行网络通信。
悔棋、重开、下棋的通信方式
代码程序定义了网络间包的类型与内容，以确保通信的简介与准确。包的类型分为三中：下棋、悔棋和重赛。当游戏的任何一方希望进行悔棋或重赛时，需得到对方同意。因此网络包有以下定义来实现该通信方式：
typedef NS_ENUM(NSInteger, PGPacketType) {
    PGPacketTypeUnknown,
    PGPacketTypeMove,
    PGPacketTypeReset,
    PGPacketTypeUndo
};

typedef NS_ENUM(NSInteger, PGPacketAction) {
PGPacketActionUnknown,
//重赛请求/同意/拒绝
    PGPacketActionResetRequest,
    PGPacketActionRequetAgree,
PGPacketActionResetReject,
//悔赛请求/同意/拒绝
PGPacketActionUndoRequest,
PGPacketActionUndoAgree,
PGPacketActionUndoReject,
};


@interface PGPacket : NSObject

@property (strong, nonatomic) id data;
@property (assign, nonatomic) PGPacketType type;
@property (assign, nonatomic) PGPacketAction action;

代码的整体思维导图
 
图2：软件代码思维导图
![image](https://github.com/user-attachments/assets/11a623d2-7b08-4b31-96b2-b1cc84f52d1f)
