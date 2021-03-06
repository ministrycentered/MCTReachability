/*!
 * MCTReachability.h
 *
 * Copyright (c) 2014 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 5/21/14
 */

#ifndef MCTReachability_h
#define MCTReachability_h

@import Foundation;
@import UIKit;
@import CoreFoundation;
@import SystemConfiguration;
@import Darwin.POSIX.netinet.in;

// Turn on debug logging
#ifndef MCTReachabilityDebugLog
#   define MCTReachabilityDebugLog 0
#endif

NS_ASSUME_NONNULL_BEGIN

@class MCTReachability;

typedef NS_ENUM(NSInteger, MCTReachabilityNetworkStatus) {
    MCTReachabilityNetworkNotReachable     = 0,
    MCTReachabilityNetworkReachableViaWiFi = 1,
#if	TARGET_OS_IPHONE
    MCTReachabilityNetworkReachableViaWWAN = 2
#endif
};
typedef void (^MCTReachabilityStatusChange)(MCTReachability *, MCTReachabilityNetworkStatus);

/**
 *  MCTReachability is a replacement for Reachability
 */
@interface MCTReachability : NSObject

/**
 *  Create a new reachability with a 0 address
 *
 *  @return A new reachability instance
 */
+ (nullable instancetype)newReachability DEPRECATED_ATTRIBUTE;
/**
 *  A new reachability with the URL as the target
 *
 *  @param URL The URL to use as the target
 *
 *  @return A new reachability instance
 */
+ (nullable instancetype)newReachabilityWithURL:(NSURL *)URL;
/**
 *  A new reachability with the host name as the target
 *
 *  @param hostName The host name to use as the target
 *
 *  @return A new reachability instance
 */
+ (nullable instancetype)newReachabilityWithHostName:(NSString *)hostName;
/**
 *  Create a new reachability with the passed address
 *
 *  @param address The address to use as the target
 *
 *  @return A new reachability instance
 */
+ (nullable instancetype)newReachabilityWithAddress:(const struct sockaddr_in *)address  DEPRECATED_ATTRIBUTE;

/**
 *  Is the notifier running
 */
@property (nonatomic, readonly, getter = isRunning) BOOL running;

/**
 *  Start the notifier
 *
 *  @return Success of notifier startup
 */
- (BOOL)startNotifier;
/**
 *  Stop the notifier
 *
 *  @return Success of stopping the notifier
 */
- (BOOL)stopNotifier;

#pragma mark -
#pragma mark - State
/**
 *  The current network status
 */
@property (nonatomic, readonly) MCTReachabilityNetworkStatus status;

/**
 *  An optional change handler when the network changes
 */
@property (nonatomic, copy) MCTReachabilityStatusChange changeHandler DEPRECATED_ATTRIBUTE;

/**
 *  The network is currently reachable via WiFi
 */
- (BOOL)isReachableWiFi;
/**
 *  The network is currently reachable via WWAN
 */
- (BOOL)isReachableWWAN;

/**
 *  The network is currently reachable.
 */
- (BOOL)isReachable;

/**
 *  The network is currently unreachable
 */
- (BOOL)isUnReachable;

#pragma mark -
#pragma mark - Metadata
@property (nonatomic, strong, readonly, nullable) NSString *host;

@end

OBJC_EXTERN NSString *const MCTReachabilityStatusChangedNotification;

OBJC_EXTERN NSString *const kMCTReachabilityStatus;

NS_ASSUME_NONNULL_END

#endif
