//
//  MyAnnotation.m
//  IfinitySDK
//
//  Created by GetIfinity.com on 24.08.2013.
//  Copyright (c) 2013 GetIfinity.com. All rights reserved.
//

#import "TargetAnnotation.h"

#define kFilteringFactor 0.1

@implementation TargetAnnotation

@synthesize coordinate, title;

- (NSString *)subtitle
{
    return nil;
}

- (void) setTitle: (NSString *)newTitle
{
    title = newTitle;
}

- (NSString *)title
{
    return title;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord
{
    coordinate=coord;
    return self;
}

-(CLLocationCoordinate2D)coord
{
    return coordinate;
}

- (BOOL)hasPosition
{
    return coordinate.latitude && coordinate.longitude;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    // No filtering, when assinging for the first time
    coordinate = newCoordinate;
}



@end
