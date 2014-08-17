//
//  AtkLocationManager.h
//  Atk_Rnd_Location
//
//  Created by Rick Boykin on 8/17/14.
//  Copyright (c) 2014 Asymptotik Limited. All rights reserved.
//

@class AtkLocationManager;

@protocol AtkLocationManagerProtocol <NSObject>

- (void)locationManager:(AtkLocationManager *)manager didUpdateLocations:(NSArray *)locations;

@end

@interface AtkLocationManager : NSObject

@property (nonatomic, weak) id<AtkLocationManagerProtocol> delegate;

/*
 * Gets the shared AtkLocationManager
 */
+ (instancetype)sharedManager;

/*
 * start LocationManager and return YES if successful. If NO is returned, the locationservices is 
 * not enabled on the device.
 */
- (BOOL)start;

/*
 * stop the LocationManager.
 */
- (void)stop;

@end
