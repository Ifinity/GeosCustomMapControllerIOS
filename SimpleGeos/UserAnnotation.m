//
//  MyAnnotation.m
//  IfinitySDK
//
//  Created by GetIfinity.com on 24.08.2013.
//  Copyright (c) 2013 GetIfinity.com. All rights reserved.
//

#import "UserAnnotation.h"

@implementation UserAnnotation

@synthesize coordinate, sticky;

- (NSString *)subtitle
{
    return nil;
}

- (NSString *)title
{
    return nil;
}

-(CLLocationCoordinate2D)coord
{
    return coordinate;
}

- (void)clearCoordinates
{
    coordinate = CLLocationCoordinate2DMake(0, 0);
}

- (BOOL)hasPosition
{
    return coordinate.latitude && coordinate.longitude;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    coordinate = newCoordinate;
}

@end
