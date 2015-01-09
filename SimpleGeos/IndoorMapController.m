//
//  IndoorMapController.m
//  GeosDemo
//
//  Created by GetIfinity.com on 24.10.2014.
//  Copyright (c) 2014 GetIfinity.com. All rights reserved.
//

#import "IndoorMapController.h"
#import "UserAnnotation.h"
#import "TargetAnnotation.h"
#import <ifinitySDK/IFMArea+helper.h>

#define distanceFake .5
#define kHeadingFilteringFactor 0.1

@interface IndoorTargetNavigationContext ()
- (void)setEndPoint:(CLLocationCoordinate2D)endPoint;
- (void)setRoute:(IFPolyline *)route;
@end


@interface IndoorMapController () {
	BOOL _heading;
	NSTimer *_headingTimer;
}
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, strong) IFMArea *area;
@property (nonatomic, strong) UserAnnotation *userAnnotation;
@property (nonatomic, strong) TargetAnnotation *targetAnnotation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) IFIndoorLocationManager *indoorLocationManager;
@property (strong, nonatomic) IndoorTargetNavigationContext *targetNavigationContext;
@end

@implementation IndoorMapController

- (void)setupWithMapView:(MKMapView *)mapView viewController:(UIViewController *)viewController
{
	self.mapView = mapView;
	self.mapView.userTrackingMode = MKUserTrackingModeNone;
    
	self.viewController = viewController;
	_userAnnotation = [[UserAnnotation alloc] init];
	[[self.mapView annotations] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
	    if ([obj isKindOfClass:[TargetAnnotation class]]) {
	        [self.mapView removeAnnotation:obj];
		}
	}];
	[self.mapView addAnnotation:_userAnnotation];

	//Hide all other overlays
	[[self.mapView overlays] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
	    if ([obj isKindOfClass:[MKPolygon class]]) {
	        MKOverlayRenderer *renderer = [self.mapView rendererForOverlay:obj];
	        renderer.alpha = 0;
		}
	}];

	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.indoorLocationManager = [[IFIndoorLocationManager alloc] init];
	self.indoorLocationManager.delegate = self;
}

- (void)start
{
	if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted
	    || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
		[self locationManager:self.locationManager didChangeAuthorizationStatus:[CLLocationManager authorizationStatus]];
	} else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
		[self.locationManager startUpdatingLocation];
		[self.locationManager requestWhenInUseAuthorization];
	} else {
		[self.locationManager startUpdatingLocation];
	}

	[IFDataManager sharedManager].delegate = self;
	[[IFBluetoothManager sharedManager] setDelegate:self];
	[[IFBluetoothManager sharedManager] startManager];
	[self.indoorLocationManager startUpdatingIndoorLocation];
	[self.indoorLocationManager startCheckingAreas];
    [self.locationManager startUpdatingHeading];
}

- (void)stop
{
    [self.locationManager stopUpdatingHeading];
	[self.locationManager stopMonitoringSignificantLocationChanges];
	[[IFBluetoothManager sharedManager] stopManager];
	[[IFBluetoothManager sharedManager] setDelegate:nil];
	[IFDataManager sharedManager].delegate = nil;
	[self.indoorLocationManager stopUpdatingIndoorLocation];
	[self.indoorLocationManager stopCheckingAreas];
}

- (void)setCurrentFloorplan:(IFMFloorplan *)currentFloorplan
{
	BOOL enterPlace = !_currentFloorplan && currentFloorplan;
	_currentFloorplan = currentFloorplan;
	[[self.mapView overlays] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
	    if ([obj isKindOfClass:[IFTileOverlay class]]) {
	        [self.mapView removeOverlay:obj];
		}
	}];
	if (currentFloorplan) {
        [self.mapView setAccessibilityElementsHidden:YES];
		NSLog(@"floorplan center: (%f, %f)", [currentFloorplan center].latitude, [currentFloorplan center].longitude);
		[[IFLocationManager sharedManager] setTranslationCoordinate:[currentFloorplan center]];

		IFTileOverlay *overlay = [[IFTileOverlay alloc] init];
		overlay.mapURL = currentFloorplan.map_id;
		[self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
		CLLocationDistance distance = 500.0;
		CLLocationCoordinate2D center = [[IFLocationManager sharedManager] translateCoordinate:[currentFloorplan center]];
		MKMapCamera *camera = [MKMapCamera
		                       cameraLookingAtCenterCoordinate:center
		                                     fromEyeCoordinate:center
		                                           eyeAltitude:distance];
		[self.mapView setCamera:camera animated:NO];
		self.userAnnotation.coordinate = center;

        //show beacons locations as icons on a mapview
		NSArray *beacons = [IFMBeacon fetchAll];
		for (IFMBeacon *beacon in beacons) {
			CLLocationCoordinate2D c = [[IFLocationManager sharedManager] translateCoordinate:beacon.location.coordinate];
            IFBeaconAnnotation *ann = [[IFBeaconAnnotation alloc] initWithCoordinate:c];
            ann.title = beacon.name;
			[self.mapView addAnnotation:ann];
		}
	} else {
        [self.mapView setAccessibilityElementsHidden:NO];
	}


	if (enterPlace) {
		if ([self.delegate respondsToSelector:@selector(didEnterPlace)]) {
			[self.delegate didEnterPlace];
		}
	}
}

#pragma mark - Heading

- (void)setFollowHeading:(BOOL)heading
{
	if (_heading == heading) return;
	_heading = heading;
	if (heading) {
		if (CLLocationManager.headingAvailable) {
            self.mapView.rotateEnabled = YES;
			[self.locationManager startUpdatingHeading];
			//_headingTimer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(updateHeading) userInfo:nil repeats:YES];
		} else {
			_heading = NO;
		}
	} else {
		[self.locationManager stopUpdatingHeading];
	}
}

- (void)updateHeading
{
    CLLocationDirection h = self.locationManager.heading.magneticHeading;
    [self.mapView.camera setHeading:h];
    if (_targetAnnotation) {
        self.mapView.camera.centerCoordinate = _targetAnnotation.coordinate;
    } else {
        self.mapView.camera.centerCoordinate = _userAnnotation.coordinate;
    }
}

#pragma mark - IFBluetoothManagerDelegate

- (void)manager:(IFBluetoothManager *)manager didDiscoverActiveBeaconsForFloorplan:(IFMFloorplan *)floorplan
{
	if (![floorplan isEqual:_currentFloorplan]) {
		NSLog(@"Setup new floorplan");
		NSLog(@"thereAreActiveBeaconsForFloorplanID: %@", floorplan.remote_id);
		self.currentFloorplan = floorplan;
		if ([self.delegate respondsToSelector:@selector(didEnterFloor:)]) {
			[self.delegate didEnterFloor:floorplan];
		}
	}
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
	CLLocation *location = [locations lastObject];

	if (location) {
		NSLog(@"location: %@", location);
		[[IFLocationManager sharedManager] updateCurrentLocation:location];
	}
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
	NSLog(@"locationManager didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusRestricted
	    || status == kCLAuthorizationStatusDenied) {
		//nie ma zgody
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
		                                                               message:NSLocalizedString(@"Location:Denied", nil)
		                                                        preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
		                                                      handler: ^(UIAlertAction *action) {}];
		[alert addAction:defaultAction];

		[self.viewController presentViewController:alert animated:YES completion:nil];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [self updateNavigationHeading:newHeading.magneticHeading];
    if(_heading) {
        [self updateHeading];
    }
}

#pragma mark - IFIndoorLocationManagerDelegate

- (void)manager:(IFIndoorLocationManager *)manager didUpdateIndoorLocation:(CLLocation *)location
{
	CLLocationCoordinate2D c = [[IFLocationManager sharedManager] translateCoordinate:location.coordinate];
	self.userAnnotation.coordinate = c;

    if (self.targetNavigationContext && self.targetNavigationContext.ready) {
        [self.targetNavigationContext setUserPosition:[[IFLocationManager sharedManager] translateCoordinate:location.coordinate]];
		[self recalculatePositionWithContext:self.targetNavigationContext];
	}
    
    if(_heading) {
        if (_targetAnnotation) {
            self.mapView.camera.centerCoordinate = _targetAnnotation.coordinate;
        } else {
            self.mapView.camera.centerCoordinate = _userAnnotation.coordinate;
        }
    }
}

- (void)manager:(IFIndoorLocationManager *)manager didEnterArea:(IFMArea *)area;
{
	[[self.mapView overlays] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
	    if ([obj isKindOfClass:[MKPolygon class]]) {
	        [self.mapView removeOverlay:obj];
		}
	}];
	_area = area;
	if ([self.delegate respondsToSelector:@selector(didEnterArea:)]) {
		[self.delegate didEnterArea:area];
	}
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay> )overlay
{
	if ([overlay isKindOfClass:[IFTileOverlay class]]) {
		return [[IFTileOverlayRenderer alloc] initWithOverlay:overlay];
	}
	if ([overlay isKindOfClass:[MKPolygon class]]) {
		MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
		polygonView.strokeColor = [UIColor clearColor];
		polygonView.fillColor   = [[UIColor colorWithRed:226.0f / 255.0f green:226.0f / 255.0f blue:226.0f / 255.0f alpha:1.0f] colorWithAlphaComponent:1];
		return polygonView;
	}
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolyline *route = overlay;
		MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
		routeRenderer.strokeColor = [UIColor colorWithRed:233.f / 255 green:0.f blue:126.f / 255 alpha:1.f];
		routeRenderer.lineWidth = 4.0;
		routeRenderer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:8.0], nil];
		return routeRenderer;
	}
	return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation
{
	if ([annotation isKindOfClass:[IFBeaconAnnotation class]]) {
		static NSString *annotationViewReuseIdentifier = @"myPin";

		MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewReuseIdentifier];
		if (annotationView == nil) {
			annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewReuseIdentifier];
		}
		annotationView.image = [UIImage imageNamed:@"ico_beacon"];
		annotationView.centerOffset = CGPointMake(0, 0);
		annotationView.annotation = annotation;
		annotationView.alpha = 0.75;
        annotationView.canShowCallout = YES;

		return annotationView;
	} else if ([annotation isKindOfClass:[UserAnnotation class]]) {
		static NSString *annotationUserReuseIdentifier = @"myUser";
		MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationUserReuseIdentifier];
		if (annotationView == nil) {
			annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationUserReuseIdentifier];
		}
		annotationView.image = [UIImage imageNamed:@"ico_you"];
		annotationView.centerOffset = CGPointMake(0, 0);
		annotationView.annotation = annotation;

		return annotationView;
	} else if ([annotation isKindOfClass:[TargetAnnotation class]]) {
		static NSString *annotationUserReuseIdentifier = @"myTarget";
		MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationUserReuseIdentifier];
		if (annotationView == nil) {
			annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationUserReuseIdentifier];
		}
		annotationView.image = [UIImage imageNamed:@"ico_you"];
		annotationView.centerOffset = CGPointMake(0, 0);
		annotationView.annotation = annotation;

		return annotationView;
	}
	return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	for (NSObject *annotation in[mapView annotations]) {
		if ([annotation isKindOfClass:[UserAnnotation class]]) {
			MKAnnotationView *view = [mapView viewForAnnotation:(MKUserLocation *)annotation];
			[[view superview] bringSubviewToFront:view];
		}
	}
}

#pragma mark -
#pragma mark - Navigation

- (void)startNavigationToArea:(IFMArea *)targetArea
{
	[self stopNavigationToArea];
	self.targetNavigationContext = [self setDestinationArea:targetArea withType:IFRouteTypeDefault];
}

- (void)stopNavigationToArea
{
	[self setDestinationArea:nil withType:IFRouteTypeDefault];
    self.targetNavigationContext = nil;
}

- (IndoorTargetNavigationContext *)setDestinationArea:(IFMArea *)area withType:(IFRouteType)type
{
	[self.mapView removeAnnotation:_targetAnnotation], _targetAnnotation = nil;
	if (!area) {
		[[self.mapView viewForAnnotation:_userAnnotation] setAlpha:1.0f];
        if(self.targetNavigationContext.route) {
            [self.mapView removeOverlay:self.targetNavigationContext.route];
        }
		return nil;
	}



	CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[area lat] doubleValue], [[area lng] doubleValue]);
	CLLocationCoordinate2D userPosition = [[IFLocationManager sharedManager] translateBack:_userAnnotation.coordinate];
	IndoorTargetNavigationContext *context = [[IndoorTargetNavigationContext alloc] initWithArea:area routeType:type];

	_targetAnnotation = [[TargetAnnotation alloc] initWithCoordinate:_userAnnotation.coordinate];
	[self.mapView addAnnotation:_targetAnnotation];
	[[self.mapView viewForAnnotation:_userAnnotation] setAlpha:0.1f];

    [[IFDataManager sharedManager] routeFromFloorId:_currentFloorplan.remote_id
                                     fromCoordinate:userPosition
                                          toFloorId:area.floorplan.remote_id
                                       toCoordinate:coordinate
                                      transportType:type
                                            success:^(NSDictionary *routes, CLLocationCoordinate2D endPoint) {
        [context setEndPoint:[[IFLocationManager sharedManager] translateCoordinate:endPoint]];
        [routes enumerateKeysAndObjectsUsingBlock: ^(NSNumber *key, IFPolyline *obj, BOOL *stop) {
            if ([key integerValue] == [self.currentFloorplan.remote_id integerValue]) {
                [self.mapView addOverlay:obj level:MKOverlayLevelAboveLabels];
                [context setRoute:obj];
            }
        }];
        [self recalculatePositionWithContext:context];
    } failure:nil];
    
	return context;
}

- (void)recalculatePositionWithContext:(IndoorTargetNavigationContext *)context
{
    [_targetAnnotation setCoordinate:self.targetNavigationContext.nextNodeDetails.currentLocation];
    CLLocationCoordinate2D userRealCoordinate = [[IFLocationManager sharedManager] translateBack:_targetAnnotation.coordinate];
    CLLocationCoordinate2D targetCoordinate = [[IFLocationManager sharedManager] translateBack:context.nextNodeLocation];
    CLLocationCoordinate2D endCoordinate = [[IFLocationManager sharedManager] translateBack:context.endPoint];
    
	CLLocation *userPos = [[CLLocation alloc] initWithLatitude:userRealCoordinate.latitude longitude:userRealCoordinate.longitude];
	CLLocation *targetPos = [[CLLocation alloc] initWithLatitude:targetCoordinate.latitude longitude:targetCoordinate.longitude];

    
    
    CLLocationDistance targetDistance = [userPos distanceFromLocation:targetPos]; // / pow(2, [[IFLocationManager sharedManager] zoomFactor]) * distanceFake;

	if ([self.delegate respondsToSelector:@selector(didChangeTargetNodeDistance:)]) {
		[self.delegate didChangeTargetNodeDistance:targetDistance];
	}

    CLLocation *endPos = [[CLLocation alloc] initWithLatitude:endCoordinate.latitude longitude:endCoordinate.longitude];
    CLLocationDistance endDistance = [userPos distanceFromLocation:endPos];// / pow(2, [[IFLocationManager sharedManager] zoomFactor]) * distanceFake;
	if ([self.delegate respondsToSelector:@selector(didChangeTargetTotalDistance:)]) {
		[self.delegate didChangeTargetTotalDistance:endDistance];
	}
    
    [self updateNavigationHeading:self.locationManager.heading.magneticHeading];
}


- (void)updateNavigationHeading:(CLLocationDirection)magneticHeading
{
    if(!self.targetNavigationContext) return;
    CLLocationDirection angle = [IndoorTargetNavigationContext angleFromCoordinate:_targetAnnotation.coordinate
                                                                      toCoordinate:self.targetNavigationContext.nextNodeLocation] * 180.f / (float)M_PI;
    
    CLLocationDirection nextNodeAngle = angle-magneticHeading;
    if (nextNodeAngle < 0){
        nextNodeAngle += 360;
    }
    
    if ([self.delegate respondsToSelector:@selector(didChangeTargetHeading:)]) {
        [self.delegate didChangeTargetHeading:nextNodeAngle];
    }
}

@end




@implementation IndoorTargetNavigationContext
- (instancetype)initWithArea:(IFMArea *)area routeType:(IFRouteType)type
{
	self = [super init];
	if (self) {
		_targetArea = area;
		_routeType = type;
	}
	return self;
}

- (void)setEndPoint:(CLLocationCoordinate2D)endPoint
{
	_endPoint = endPoint;
}

- (void)setRoute:(IFPolyline *)route
{
	_route = route;
}

- (void)setUserPosition:(CLLocationCoordinate2D)coordinate
{
	IFRouteDetails *details = [[IFLocationManager sharedManager] coordinateClosestTo:coordinate onPolyline:_route];
	_nextNodeDetails = details;
}

- (void)setUserHeading:(CLLocationDirection)heading
{
}

- (CLLocationCoordinate2D)nextNodeLocation
{
	return _nextNodeDetails.nextNodeLocation;
}

- (NSString *)nextNodeDescription
{
	return _nextNodeDetails.nextNodeDescription;
}

- (BOOL)ready
{
    return _route != nil;
}

+ (CLLocationDirection)angleFromCoordinate:(CLLocationCoordinate2D)first
                toCoordinate:(CLLocationCoordinate2D)second
{
	CLLocationDegrees deltaLongitude = second.longitude - first.longitude;
	CLLocationDegrees deltaLatitude = second.latitude - first.latitude;
	CLLocationDirection angle = (M_PI * .5f) - atan(deltaLatitude / deltaLongitude);

	if (deltaLongitude > 0) return angle;
	else if (deltaLongitude < 0) return angle + M_PI;
	else if (deltaLatitude < 0) return M_PI;

	return 0.0f;
}

@end
