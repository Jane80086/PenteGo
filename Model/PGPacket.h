//
//  PGPacket.h
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import <Foundation/Foundation.h>

extern NSString * const PGPacketKeyData;
extern NSString * const PGPacketKeyType;
extern NSString * const PGPacketKeyAction;

typedef NS_ENUM(NSInteger, PGPacketType) {
    PGPacketTypeUnknown,
    PGPacketTypeMove,
    PGPacketTypeReset,
    PGPacketTypeUndo
};

typedef NS_ENUM(NSInteger, PGPacketAction) {
    PGPacketActionUnknown,
    PGPacketActionResetRequest,
    PGPacketActionResetAgree,
    PGPacketActionResetReject,
    PGPacketActionUndoRequest,
    PGPacketActionUndoAgree,
    PGPacketActionUndoReject
};

@interface PGPacket : NSObject

@property (strong, nonatomic) id data;
@property (assign, nonatomic) PGPacketType type;
@property (assign, nonatomic) PGPacketAction action;

- (id)initWithData:(id)data type:(PGPacketType)type action:(PGPacketAction)piece;

@end
