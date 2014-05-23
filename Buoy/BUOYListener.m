//  The MIT License (MIT)
//
//  Copyright (c) 2014 Intermark Interactive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "BUOYListener.h"

// Constant Strings
NSString * const kBUOYBeaconRangeIdentifier = @"com.BUOYBeacon.Region";
NSString * const kBUOYDidFindBeaconNotification = @"kBUOYDidFindBeaconNotification";
NSString * const kBUOYBeacon = @"kBUOYBeacon";


// Interface
@interface BUOYListener() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *beaconRegions;
@end


// Implementation
@implementation BUOYListener

#pragma mark - Singleton
+ (instancetype)defaultListener {
	static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}


#pragma mark - Init
- (instancetype)init {
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    
    return self;
}


#pragma mark - Start Listening
- (void)listenForBeaconsWithProximityUUIDs:(NSArray *)proximityIds {
    // Register for region monitoring
    NSMutableArray *beaconRegions = [NSMutableArray array];
    for (NSUUID *proximityId in proximityIds) {
        // Create the beacon region to be monitored.
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityId identifier:kBUOYBeaconRangeIdentifier];
        
        // Register the beacon region with the location manager.
        [self.locationManager startMonitoringForRegion:beaconRegion];
        [beaconRegions addObject:beaconRegion];
    }
    
    self.beaconRegions = beaconRegions;
}


#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    // Notify for each Beacon found
    for (NSInteger b = 0; b < beacons.count; b++) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kBUOYDidFindBeaconNotification object:nil userInfo:@{kBUOYBeacon:beacons[b]}];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

@end
