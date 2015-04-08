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
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.indoorMapController setupWithMapView:self.mapView viewController:self floorplan:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.indoorMapController start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.indoorMapController stop];
}

@end
