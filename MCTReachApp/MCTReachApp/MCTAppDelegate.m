//
//  MCTAppDelegate.m
//  MCTReachApp
//
//  Created by Skylar Schipper on 5/21/14.
//  Copyright (c) 2014 Ministry Centered Technology. All rights reserved.
//

#import "MCTAppDelegate.h"

#import "MCTReachability.h"

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
    
    return YES;
}

@end
