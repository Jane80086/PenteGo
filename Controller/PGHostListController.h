//
//  PGHostListController.h
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;

@protocol PGHostListControllerDelegate;

@interface PGHostListController : UITableViewController

@property (weak, nonatomic) id<PGHostListControllerDelegate> delegate;

@end

@protocol PGHostListControllerDelegate

- (void)controller:(PGHostListController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controller:(PGHostListController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket;
- (void)shouldDismiss;

@end
