//
//  IndoorMapController.h
//  GeosDemo
//
//  Created by GetIfinity.com on 24.10.2014.
//  Copyright (c) 2014 GetIfinity.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <ifinitySDK/IfinitySDK.h>


@interface IndoorTargetNavigationContext : NSObject
@property (nonatomic, readonly) IFRouteType routeType;
@property (nonatomic, strong, readonly) IFMArea *targetArea;
@property (nonatomic, strong, readonly) IFPolyline *route;
@property (nonatomic, readonly) BOOL ready;
@property (nonatomic, readonly) CLLocationCoordinate2D endPoint;
@property (nonatomic, strong) IFRouteDetails *nextNodeDetails;
@property (nonatomic, readonly) CLLocationCoordinate2D userSnapToPathPosition;
- (instancetype)initWithArea:(IFMArea *)area routeType:(IFRouteType)type;
- (void)setUserPosition:(CLLocationCoordinate2D)coordinate;
- (void)setUserHeading:(CLLocationDirection)heading;
- (CLLocationCoordinate2D) nextNodeLocation;
- (NSString *) nextNodeDescription;
+ (CLLocationDirection)angleFromCoordinate:(CLLocationCoordinate2D)first
                toCoordinate:(CLLocationCoordinate2D)second;
@end

@protocol IndoorMapControllerDelegate <NSObject>
@optional
- (void)didEnterFloor:(IFMFloorplan *)floor;
- (void)didEnterArea:(IFMArea *)area;
- (void)didEnterPlace;
- (void)didLeavePlace;
- (void)didChangeTargetHeading:(double)heading;
- (void)didChangeTargetNodeDistance:(double)distance;
- (void)didChangeTargetTotalDistance:(double)distance;
@end


/**
 * Helper controller that facilitate  MKMapView integration with our indoor navigation api.
 */
@interface IndoorMapController : NSObject <IFBluetoothManagerDelegate, CLLocationManagerDelegate, IFIndoorLocationManagerDelegate, IFDataManagerDelegate, MKMapViewDelegate>
@property (nonatomic, weak) IBOutlet id<IndoorMapControllerDelegate> delegate;
@property (nonatomic, strong, readonly) IFMFloorplan *currentFloorplan;
@property (strong, nonatomic, readonly) IndoorTargetNavigationContext *targetNavigationContext;
-(void)setupWithMapView:(MKMapView *)mapView viewController:(UIViewController *)viewController;
-(void)start;
-(void)stop;
-(void)setFollowHeading:(BOOL)heading;
- (void)startNavigationToArea:(IFMArea *)targetArea;
- (void)stopNavigationToArea;
@end



