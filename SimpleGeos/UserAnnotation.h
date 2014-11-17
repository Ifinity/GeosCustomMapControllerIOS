//
//  UserAnnotation.h
//  IfinitySDK
//
//  Created by GetIfinity.com on 25.08.2013.
//  Copyright (c) 2013 GetIfinity.com. All rights reserved.
//

#import <MapKit/MapKit.h>

/**
 *  Used to render user position on the map. There could be only one user on the map, the main object is stored within IFLocationManager class instance. Should not be instantiated directly.
 */
@interface UserAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic) BOOL sticky;

- (BOOL)hasPosition;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (void)clearCoordinates;

@end
