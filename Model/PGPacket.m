//
//  PGPacket.m
//  Pente Go
//
//  Created by GQQ on 2025/4/26.
//

#import "PGPacket.h"

NSString * const PGPacketKeyData = @"data";
NSString * const PGPacketKeyType = @"type";
NSString * const PGPacketKeyAction = @"piece";

@implementation PGPacket

#pragma mark - Initializer

- (id)initWithData:(id)data type:(PGPacketType)type action:(PGPacketAction)action {
    self = [super init];
    
    if (self) {
        self.data = data;
        self.type = type;
        self.action = action;
    }
    return self;
}


#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:PGPacketKeyData];
    [coder encodeInteger:self.type forKey:PGPacketKeyType];
    [coder encodeInteger:self.action forKey:PGPacketKeyAction];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        [self setData:[decoder decodeObjectForKey:PGPacketKeyData]];
        [self setType:[decoder decodeIntegerForKey:PGPacketKeyType]];
        [self setAction:[decoder decodeIntegerForKey:PGPacketKeyAction]];
    }
    
    return self;
}

@end
