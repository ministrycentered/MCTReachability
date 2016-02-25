//
//  MCTAppDelegate.m
//  MCTReachApp
//
//  Created by Skylar Schipper on 5/21/14.
//  Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
//

#import "MCTAppDelegate.h"

#import "MCTReachability.h"
#import "MCTDNSResolver.h"

@interface MCTAppDelegate ()

@property (nonatomic, strong) MCTReachability *reach;

@end

@implementation MCTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.reach = [MCTReachability newReachabilityWithURL:[NSURL URLWithString:@"http://resources.planningcenteronline.com"]];
    
    self.reach.changeHandler = ^(MCTReachability *reach, MCTReachabilityNetworkStatus status) {
        if ([reach isReachable]) {
            NSLog(@"Currently Reachable");
        } else {
            NSLog(@"Currently UnReachable");
        }
    };
    
    [self.reach startNotifier];

    MCTDNSResolver *resolver = [[MCTDNSResolver alloc] initWithURL:[NSURL URLWithString:@"https://planningcenteronline.com"]];
    NSError *error = nil;
    if (![resolver resolveAndReturnError:&error]) {
        NSLog(@"Failed to resolve %@\n%@",resolver.hostName,error);
    }
    [resolver.addresses enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@ %@",resolver.hostName,[MCTDNSResolver createIPv4StringForData:obj]);
    }];

    [MCTDNSResolver resolveHostName:@"services-staging.planningcenteronline.com" completion:^(NSArray<NSData *> * _Nullable addresses, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to resolve\n%@",error);
        }
        [addresses enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"async - %@ %@",resolver.hostName,[MCTDNSResolver createIPv4StringForData:obj]);
        }];
    }];

    return YES;
}

@end
