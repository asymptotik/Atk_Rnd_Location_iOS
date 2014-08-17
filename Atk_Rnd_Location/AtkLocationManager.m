//
//  AtkLocationManager.m
//  Atk_Rnd_Location
//
//  Created by Rick Boykin on 8/17/14.
//  Copyright (c) 2014 Asymptotik Limited. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AtkLocationManager.h"

@interface AtkLocationManager()<CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation AtkLocationManager

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AtkLocationManager alloc] init];
    });
    
    return sharedManager;
}

/*
 * start the CLLocationManager witht the appropriate paramters.
 */
- (BOOL)start
{
    BOOL ret = NO;
    
    if(self.locationManager == nil) {
        // Starts location manager
        if([CLLocationManager locationServicesEnabled] == NO) {
            NSLog(@"WARNING: location services are not enabled.");
            return ret;
        }
        
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    }
    
    [self.locationManager startUpdatingLocation];
    
    ret = YES;
    return ret;
}

/*
 * Stops the CLLocationManager
 */
- (void)stop
{
    if(self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
}

- (void)restartLocationManagerWithAccuracy:(CLLocationAccuracy)accuracy distanceFilter:(CLLocationDistance)distance
{
    if(self.locationManager != nil) {
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
    
    if([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"WARNING: location services are not enabled.");
        return;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:accuracy];
    [self.locationManager setDistanceFilter:distance];
    
    [self.locationManager startUpdatingLocation];
}

/*
 *  locationManager:didUpdateLocations:
 *
 *  Discussion:
 *    Invoked when new locations are available.  Required for delivery of
 *    deferred locations.  If implemented, updates will
 *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
 *
 *    locations is an array of CLLocation objects in chronological order.
 */
- (void)locationManager:(AtkLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    NSLog(@"locationManager:didUpdateToLocations: %@", locations);
    
    NSMutableArray *filteredLocations = [NSMutableArray array];
    
    for (CLLocation *location in locations) {
        NSDate* eventDate = location.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (abs(howRecent) < 15.0) {
            // only keep locations that are less than 15 seconds old.
            [filteredLocations addObject:location];
        }
    }
    
    if(filteredLocations.count > 0 && self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
        [self.delegate locationManager:self didUpdateLocations:filteredLocations];
    }
}

- (void)scheduleNotification {

    NSDate *itemDate = [NSDate date];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = itemDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:@"Wake up!"];
    localNotif.alertAction = @"View Details";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

/*
 *  locationManager:didDetermineState:forRegion:
 *
 *  Discussion:
 *    Invoked when there's a state transition for a monitored region or in response to a request for state via a
 *    a call to requestStateForRegion:.
 */
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"locationManager: didDetermineState: %ld for region %@", (long)state, region);
}

/*
 *  locationManager:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"locationManager: didFailWithError: %@", error);
}

/*
 *  locationManager:monitoringDidFailForRegion:withError:
 *
 *  Discussion:
 *    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error
{
    NSLog(@"locationManager: monitoringDidFailForRegion: %@ withError: %@", region, error);
}

/*
 *  Discussion:
 *    Invoked when location updates are automatically paused.
 */
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidPauseLocationUpdates:");
}

/*
 *  Discussion:
 *    Invoked when location updates are automatically resumed.
 *
 *    In the event that your application is terminated while suspended, you will
 *	  not receive this notification.
 */
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidResumeLocationUpdates:");
}

/*
 *  locationManager:didFinishDeferredUpdatesWithError:
 *
 *  Discussion:
 *    Invoked when deferred updates will no longer be delivered. Stopping
 *    location, disallowing deferred updates, and meeting a specified criterion
 *    are all possible reasons for finishing deferred updates.
 *
 *    An error will be returned if deferred updates end before the specified
 *    criteria are met (see CLError).
 */
- (void)locationManager:(CLLocationManager *)manager
didFinishDeferredUpdatesWithError:(NSError *)error
{
    NSLog(@"locationManager: didFinishDeferredUpdatesWithError: %@", error);
}

@end
