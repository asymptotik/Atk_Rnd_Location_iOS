//
//  AtkNetworkManager.m
//  Atk_Rnd_Location
//
//  Created by Rick Boykin on 8/17/14.
//  Copyright (c) 2014 Asymptotik Limited. All rights reserved.
//

#import "AtkNetworkManager.h"

@interface AtkNetworkManager ()
@property (nonatomic) NSURLSession *session;
@property (nonatomic) BOOL networkActivity;
@end

@implementation AtkNetworkManager
{
    NSUInteger _networkActivityCounter;
    NSObject *_lock;
}

+ (instancetype)sharedManager
{
    static id networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[AtkNetworkManager alloc] init];
    });
    
    return networkManager;
}

- (id)init
{
    if((self = [super init])) {
        _lock = [[NSObject alloc] init];
    }
    return self;
}

- (void)setNetworkActivity:(BOOL)networkActivity
{
    @synchronized (_lock) {
        if(networkActivity) {
            _networkActivityCounter++;
        } else if(_networkActivityCounter > 0) {
            _networkActivityCounter--;
        }
        
        if(_networkActivityCounter > 0) {
            _networkActivity = YES;
            if([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible] == NO) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            }
            
        } else {
            _networkActivity = NO;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
}

- (NSMutableURLRequest *)prepareRequestWithPath:(NSString *)path body:(NSString *)bodyString
{
    if (nil == self.session) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    
    NSURL *url = [NSURL URLWithString:kBaseServiceURL];
    if(path) {
        url = [NSURL URLWithString:path relativeToURL:url];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSString *userAgent = [NSString stringWithFormat:@"[%@]-[%@]-[%@]", [[UIDevice currentDevice] localizedModel], [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"en-us" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"utf-8" forHTTPHeaderField:@"Accept-Charset"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (NSURLSessionDataTask *)testHttpWithCompletionHandler:(void(^)(BOOL status))block
{
    NSString *bodyString = @"";
    NSString *path = @"/ABCWebServices/tws/v1/users/7208977212/bwanywhere/locations";
    
    NSMutableURLRequest *request = [self prepareRequestWithPath:path body:bodyString];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error) {
            NSError *parseError = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"results: %@", result);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(block) block(YES);
                self.networkActivity = NO;
            });
        }
    }];
    
    self.networkActivity = YES;
    [dataTask resume];
    return dataTask;
}

@end
