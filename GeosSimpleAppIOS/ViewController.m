//
//  ViewController.m
//  SimpleGeos
//
//  Created by Wojciech Chojnacki on 07.11.2014.
//  Copyright (c) 2014 GetIfinity. All rights reserved.
//

#import "ViewController.h"
#import <ifinitySDK/IFIndoorMapController.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet IFIndoorMapController *indoorMapController;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self.indoorMapController;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.indoorMapController.shouldAddBeaconsToMap = YES;
    [self.indoorMapController setupWithMapView:self.mapView viewController:self floorplan:nil locationManager:self.locationManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self.indoorMapController locationManager:self.locationManager didChangeAuthorizationStatus:[CLLocationManager authorizationStatus]];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager startUpdatingLocation];
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self.locationManager startUpdatingLocation];
    }
    [self.indoorMapController start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.locationManager stopUpdatingHeading];
    [self.locationManager stopUpdatingLocation];
    [self.indoorMapController stop];
}

@end
