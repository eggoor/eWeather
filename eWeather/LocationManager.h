//
//  LocationManagerDelegate.h
//  eWeather
//
//  Created by e on 07.08.2025.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (readonly, nullable) CLLocation* location;
@property (readonly, nullable) NSString* locality;

+ (instancetype)locationManagerWithCompletion:(void (^)(CLLocation* location, NSString* locality, NSError* _Nullable error))completion;
- (instancetype)initWithCompletion:(void (^)(CLLocation* location, NSString* locality, NSError* _Nullable error))completion;

- (void)startDetermineLocationAndLocality;

@end

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSInteger, LocationManagerErrorCode) {
	LocationManagerErrorCodeGeneric = -1,
	LocationManagerErrorAuthorizationFailure = 1000,
	LocationManagerErrorCodeNoPlacemarks = 1001,
	LocationManagerErrorCodeNoLocations = 1002
};
