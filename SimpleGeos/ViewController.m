//
//  ViewController.m
//  SimpleGeos
//
//  Created by Wojciech Chojnacki on 07.11.2014.
//  Copyright (c) 2014 GetIfinity. All rights reserved.
//

#import "ViewController.h"
#import "IndoorMapController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet IndoorMapController *indoorMapController;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.indoorMapController setupWithMapView:self.mapView viewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.indoorMapController start];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.indoorMapController stop];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [super viewWillDisappear:animated];
}

@end
