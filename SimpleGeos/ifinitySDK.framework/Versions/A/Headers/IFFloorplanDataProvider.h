//
//  IFFloorplanDataProvider.h
//  IfinitySDK
//
//  Created by GetIfinity.com on 06.01.2014.
//  Copyright (c) 2014 GetIfinity.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFDataProvider.h"

@class IFFloorplanDataProvider;

/**
 *  Delegate for `IFFloorplanDataProvider`
 */
@protocol IFFloorplanDataProviderDelegate <NSObject, IFDataProviderDelegate>
@optional

/**
 *  Invoked once the information about the floorplans will be updated
 *
 *  @param provider Data provider
 *  @param areas   New Floorplans
 */
- (void) dataProvider:(IFFloorplanDataProvider *)provider didUpdateFloorplans:(NSArray *)floorplans;

@end


/**
 *  Data provider to fetch floorplans for specific coordinates and distance.
 */
@interface IFFloorplanDataProvider : IFDataProvider

@property(nonatomic, weak) id<IFFloorplanDataProviderDelegate>delegate;

/**
 *  Internal method, called always once the user position from the GPS changes radically.
 *
 *  @param lat      GPS Latitude
 *  @param lng      GPS Longitude
 *  @param distance Range
 */
- (void)queryFloorplansForLat: (NSNumber *)lat lng:(NSNumber *)lng distance:(NSNumber *)distance;;

@end
