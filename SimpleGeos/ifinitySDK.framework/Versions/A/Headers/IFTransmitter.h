//
//  IFTransmiter.h
//  IfinitySDK
//
//  Created by GetIfinity.com on 24.07.2013.
//  Copyright (c) 2013 GetIfinity.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MapKit/MapKit.h>
#import "IFMBeacon+helper.h"

/**
 *  Every beacon object it's a type of IFTransmitter, we can get it's identifier, RSSI, distance, radius, coordinate, etc.
 */
@interface IFTransmitter : NSObject
@property (nonatomic, strong) NSNumber *RSSI;
@property (nonatomic, readonly) NSNumber *filteredRSSI;
@property (nonatomic, readonly) CBPeripheral *peripheral;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) BOOL active;
@property (nonatomic, retain) IFMBeacon *beacon;

/**
 *  @return Transmitter (beacon) name
 */
- (NSString *)name;
/**
 *  [[CBPeripheral identifier] UUIDString]
 *  @return peripheral identifier as string
 */
- (NSString *)UUID;
/**
 *  Transmitter distance in meters based on current RSSI
 *
 *  @return distance in meters
 */
- (float)distance;
/**
 * Transmitter distance in meters based on current RSSI with the use of filtering algorithms.
 *
 *  @return <#return value description#>
 */
- (float)filteredDistance;
/**
 *  Is device very near to reciver (ca. 0.3m)
 *
 *  @return YES when near
 */
- (BOOL)isNear;
/**
 *  Disappearing mean no transmitter signal for some time.
 *
 *  @return YES when disappeared
 */
- (BOOL)hasDisappeared;
@end
