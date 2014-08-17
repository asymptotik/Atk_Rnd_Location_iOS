//
//  AtkLocationViewController.m
//  Atk_Rnd_Location
//
//  Created by Rick Boykin on 8/15/14.
//  Copyright (c) 2014 Asymptotik Limited. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AtkLocationViewController.h"
#import "AtkLocationManager.h"

#import "NSString+Extensions.h"

@interface AtkLocationViewController () <AtkLocationManagerProtocol>
{
    NSTimer *_timer;
    NSTimeInterval _timeLastLocationUpdate;
    NSUInteger _count;
    CLLocationSpeed _maxSpeed;
    CLLocationSpeed _averageSpeed;
}

@end

@implementation AtkLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    }
    
    _timeLastLocationUpdate = 0;
    
    //
    // Setup the LocationManger
    //
    [AtkLocationManager sharedManager].delegate = self;
    [[AtkLocationManager sharedManager] start];
}

- (void)reset
{
    //
    // Reset the statistics
    //
    _timeLastLocationUpdate = 0;
    _count = 0;
    _maxSpeed = 0;
    _averageSpeed = 0;
}

- (IBAction)resetButtonFired:(UIButton *)sender {
    [self reset];
    [self reconcileControls:nil];
}

//
// Timer callback. Simply updates the lastUpdateLabel
//
- (void)tick:(NSTimer *)timer
{
    if(_timeLastLocationUpdate == 0) {
        _lastUpdateLabel.text = @"never updated";
    } else {
        NSTimeInterval noUpdatedSince = CACurrentMediaTime() - _timeLastLocationUpdate;
        _lastUpdateLabel.text = [NSString stringWithFormat:@"%@ ago", [NSString stringWithOffsetInSeconds:noUpdatedSince]];
    }
}

//
// Delegate method of the AtkLocationManager
//
- (void)locationManager:(AtkLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"locationManager:didUpdateToLocations: %@", locations);
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];

    // If the event is recent, do something with it.
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          location.coordinate.latitude,
          location.coordinate.longitude);
    
    CLLocationSpeed speed = location.speed;
    if(speed < 0) speed = 0;
    
    _count++;
    _maxSpeed = MAX(_maxSpeed, speed);
    _averageSpeed -= _averageSpeed / _count;
    _averageSpeed += speed / _count;
    _timeLastLocationUpdate = CACurrentMediaTime();
    
    [self reconcileControls:location];
}

/*
 * Updates the UI based on location.
 */
- (void)reconcileControls:(CLLocation *)location
{
    if(location) {
        double accuracy = sqrt((location.horizontalAccuracy * location.horizontalAccuracy) + (location.verticalAccuracy * location.verticalAccuracy));
        _latitudeLabel.text = [NSString stringWithFormat:@"%+.8f", location.coordinate.latitude];
        _longitudeLabel.text = [NSString stringWithFormat:@"%+.8f", location.coordinate.longitude];
        _horizontalAccuracyLabel.text = [NSString stringWithFormat:@"%lf", (double)location.horizontalAccuracy];
        _verticalAccuracyLabel.text = [NSString stringWithFormat:@"%lf", (double)location.verticalAccuracy];
        _accuracyLabel.text = [NSString stringWithFormat:@"%lf", accuracy];
    }
    
    _samplesLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)_count];;
    _maxSpeedLabel.text = [NSString stringWithFormat:@"%lf", (double)(_maxSpeed *  Atk_METERPS_TO_MPH)];
    _averageSpeedLabel.text = [NSString stringWithFormat:@"%lf", (double)(_averageSpeed*  Atk_METERPS_TO_MPH)];
}

@end
