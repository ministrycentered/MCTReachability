/*!
 * MCTDNSResolver.m
 * MCTReachApp
 *
 * Copyright (c) 2016 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 2/25/16
 */

@import CoreFoundation;
@import Darwin.POSIX.arpa;

#import "MCTDNSResolver.h"

static void MCTDNSResolverHostCallback(CFHostRef, CFHostInfoType, const CFStreamError *, void *);

@interface MCTDNSResolver ()

@property (nonatomic, assign, getter=isDone) BOOL done;
@property (nonatomic, assign, getter=isCanceled) BOOL canceled;

@property (nonatomic, strong) NSError *streamError;

@end

@implementation MCTDNSResolver

- (instancetype)init {
    NSAssert(NO, @"%@ isn't implemented",NSStringFromSelector(_cmd));
    return [self initWithHostName:@""];
}

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithHostName:URL.host];
}

- (instancetype)initWithHostName:(NSString *)hostName {
    self = [super init];
    if (self) {
        _timeout = 1.0;
        _hostName = [hostName copy];
    }
    return self;
}

- (BOOL)resolveAndReturnError:(NSError **)error {
    if (self.hostName.length == 0) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTDNSResolverErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey: @"Invalid host name."}];
        }
        return NO;
    }

    _addresses = nil;

    CFStringRef cHostName = (__bridge CFStringRef)_hostName;

    CFHostClientContext ctx = {.info = (__bridge void *)self};

    CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, cHostName);
    if (host == NULL) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTDNSResolverErrorDomain code:200 userInfo:@{NSLocalizedDescriptionKey: @"Failed to create host"}];
        }
        return NO;
    }
    
    Boolean setClient = CFHostSetClient(host, MCTDNSResolverHostCallback, &ctx);
    if (setClient == false) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTDNSResolverErrorDomain code:300 userInfo:@{NSLocalizedDescriptionKey: @"Failed to set host client"}];
        }
        return NO;
    }

    CFRunLoopRef runLoop = CFRunLoopGetCurrent();

    const CFStringRef runLoopMode = CFSTR("mMCTDNSResolverMode");
    CFHostScheduleWithRunLoop(host, runLoop, runLoopMode);

    CFStreamError sErr;

    Boolean started = CFHostStartInfoResolution(host, kCFHostAddresses, &sErr);
    if (started == false) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTDNSResolverErrorDomain code:400 userInfo:@{NSLocalizedDescriptionKey: @"Failed to start resolution"}];
        }
    }

    BOOL timeout = NO;
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent() + _timeout;
    while (![self isCanceled] && ![self isDone] && !timeout) {
        CFRunLoopRunInMode(runLoopMode, 0.025, true);
        CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
        if (time > endTime) {
            timeout = YES;
        }
    }

#define CLEANUP_HOST() \
{ \
    CFHostSetClient(host, NULL, NULL); \
    CFHostUnscheduleFromRunLoop(host, runLoop, runLoopMode); \
    CFRelease(host); \
}

    if (timeout) {
        CFHostCancelInfoResolution(host, kCFHostAddresses);
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTDNSResolverErrorDomain code:500 userInfo:@{NSLocalizedDescriptionKey: @"Timeout", @"kMCTDNSResolverTimeoutDuration": @(_timeout)}];
        }
        CLEANUP_HOST();
        return NO;
    }

    if ([self isCanceled]) {
        CFHostCancelInfoResolution(host, kCFHostAddresses);
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTDNSResolverErrorDomain code:501 userInfo:@{NSLocalizedDescriptionKey: @"Canceled"}];
        }
        CLEANUP_HOST();
        return NO;
    }

    if (_streamError) {
        if (error != NULL) {
            *error = [_streamError copy];
        }
        CLEANUP_HOST();
        return NO;
    }

    Boolean resolved = false;
    CFArrayRef addresses = CFHostGetAddressing(host, &resolved);

    if (!resolved) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTDNSResolverErrorDomain code:600 userInfo:@{NSLocalizedDescriptionKey: @"Name lookup failed"}];
        }
        CLEANUP_HOST();
        return NO;
    }

    CFArrayRef addressesCpy = CFArrayCreateCopy(kCFAllocatorDefault, addresses);

    _addresses = (__bridge_transfer NSArray *)addressesCpy;

    CLEANUP_HOST();
    return YES;
}

+ (nullable NSString *)createIPv4StringForData:(NSData *)data {
    return (__bridge_transfer NSString *)MCTDNSCreateIPv4StringForData((__bridge CFDataRef)data);
}

+ (void)resolveHostName:(NSString *)hostName completion:(void(^)(NSArray<NSData *> *_Nullable, NSError *_Nullable))completion {
    dispatch_queue_t queue = dispatch_queue_create("com.ministrycentered.MCTDNSResolver", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{ @autoreleasepool {
        MCTDNSResolver *resolver = [[MCTDNSResolver alloc] initWithHostName:hostName];
        resolver.timeout = 5.0;
        NSError *error = nil;
        [resolver resolveAndReturnError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(resolver.addresses, error);
            }
        });
    }});
}

@end

NSString *const MCTDNSResolverErrorDomain = @"MCTDNSResolverErrorDomain";

static void MCTDNSResolverHostCallback(CFHostRef host, CFHostInfoType hostInfo, const CFStreamError *error, void *info) {
    MCTDNSResolver *resolver = (__bridge MCTDNSResolver *)info;
    if (![resolver isKindOfClass:[MCTDNSResolver class]]) {
        return;
    }

    resolver.done = YES;

    if (error->domain || error->error) {
        NSDictionary *errInfo = @{
                                  NSLocalizedDescriptionKey: @"Failed to resolve host.",
                                  @"kCFStreamErrorDomain": @(error->domain),
                                  @"kCFStreamErrorError": @(error->error)
                                  };
        resolver.streamError = [NSError errorWithDomain:MCTDNSResolverErrorDomain code:-1 userInfo:errInfo];
        return;
    }
}

CFStringRef _Nullable MCTDNSCreateIPv4StringForData(CFDataRef data) {
    struct sockaddr_in *address;
    address = (struct sockaddr_in *)CFDataGetBytePtr(data);

    if (address == NULL) {
        return nil;
    }

    struct in_addr addr = address->sin_addr;

    char *strIPv4 = inet_ntoa(addr);

    return CFStringCreateWithCString(kCFAllocatorDefault, strIPv4, kCFStringEncodingASCII);
}
