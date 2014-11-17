//
//  IFTargetAnnotation.h
//  IfinitySDK
//
//  Created by GetIfinity.com on 20.01.2014.
//  Copyright (c) 2014 GetIfinity.com. All rights reserved.
//

#import <MapKit/MapKit.h>

/**
 *  Used to display the target annotation on the map
 */
@interface TargetAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (void) setTitle: (NSString *)newTitle;

@end
