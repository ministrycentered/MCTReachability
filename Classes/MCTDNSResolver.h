/*!
 * MCTDNSResolver.h
 * MCTReachApp
 *
 * Copyright (c) 2016 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 2/25/16
 */

#ifndef MCTReachApp_MCTDNSResolver_h
#define MCTReachApp_MCTDNSResolver_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface MCTDNSResolver : NSObject

- (instancetype)initWithURL:(NSURL *)URL;

- (instancetype)initWithHostName:(NSString *)hostName NS_DESIGNATED_INITIALIZER;

// Default 1 second
@property (nonatomic, assign) CFTimeInterval timeout;

/**
 *  The host name to resolve
 */
@property (nonatomic, copy, readonly) NSString *hostName;

/**
 *  Resolve the Host name.
 *
 *  @param error Error if the host failed to resolve
 *
 *  @return The status of the resolution
 */
- (BOOL)resolveAndReturnError:(NSError **)error;

/**
 *  Addresses the host resolved to.  Will be nil until resolution completes.
 */
@property (nonatomic, copy, readonly, nullable) NSArray<NSData *> *addresses;

+ (nullable NSString *)createIPv4StringForData:(NSData *)data;

/**
 *  Resolve the host name on a background thread
 */
+ (void)resolveHostName:(NSString *)hostName completion:(void(^)(NSArray<NSData *> *_Nullable, NSError *_Nullable))completion;

@end

CF_EXPORT CFStringRef _Nullable MCTDNSCreateIPv4StringForData(CFDataRef);

FOUNDATION_EXTERN NSString *const MCTDNSResolverErrorDomain;

NS_ASSUME_NONNULL_END

#endif
