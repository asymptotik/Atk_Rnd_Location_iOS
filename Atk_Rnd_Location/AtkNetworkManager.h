//
//  AtkNetworkManager.h
//  Atk_Rnd_Location
//
//  Created by Rick Boykin on 8/17/14.
//  Copyright (c) 2014 Asymptotik Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kBaseServiceURL     @"http://192.168.4.102:3000/"

@interface AtkNetworkManager : NSObject

+ (instancetype)sharedManager;

- (NSURLSessionDataTask *)testHttpWithCompletionHandler:(void(^)(BOOL status))block;

@end
