//
//  LocationManagerDelegate.m
//  eWeather
//
//  Created by e on 07.08.2025.
//

#import "LocationManager.h"

@interface LocationManager ()

@property (nonatomic, readonly) CLLocationManager* locationManager;
@property (copy, nullable) void (^completeon)(CLLocation* location, NSString* locality, NSError* _Nullable error);

@end

@implementation LocationManager

+ (instancetype)locationManagerWithCompletion:(void (^)(CLLocation* location, NSString* locality, NSError* _Nullable error))completion {
	return [[LocationManager alloc] initWithCompletion:completion];
}

- (instancetype)initWithCompletion:(void (^)(CLLocation* location, NSString* locality, NSError* _Nullable error))completion {
	if (!completion) {
		[NSException raise:@"LocationManager" format:@"Completion handler must be specified"];
	}
	if ((self = super.init)) {
		_completeon = completion;
		_locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		[self startDetermineLocationAndLocality];
	}
	return self;
}

- (void)startDetermineLocationAndLocality {
	if (self.locationManager.authorizationStatus != kCLAuthorizationStatusAuthorized) {
		[self.locationManager requestWhenInUseAuthorization];
		return;
	}
	[self.locationManager startUpdatingLocation];
}

- (void)reverseGeocodeLocation {
	CLGeocoder* geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray<CLPlacemark*>* _Nullable placemarks, NSError* _Nullable error) {
		if (error) {
			self.completeon(self.location, nil, error);
			return;
		}
		
		if (placemarks.count == 0) {
			error = [NSError errorWithDomain:@"LocationManager" code:LocationManagerErrorCodeNoPlacemarks userInfo:@{NSLocalizedDescriptionKey: @"No placemarks returned"}];
			self.completeon(self.location, nil, error);
			return;
		}
		
		CLPlacemark* placemark = placemarks.firstObject;
		self->_locality = placemark.locality ?: @"Unknown locality";
		self.completeon(self.location, self.locality, nil);
	}];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation*>*)locations {
	[manager stopUpdatingLocation];
	CLLocation* location = [locations lastObject];
	
	if (!location) {
		NSError* error = [NSError errorWithDomain:@"LocationManager" code:LocationManagerErrorCodeNoLocations userInfo:@{NSLocalizedDescriptionKey: @"No locations returned"}];
		self.completeon(self.location, nil, error);
		return;
	}
	
	if (!self.location || [self.location distanceFromLocation:location] > 100.0) {
		_location = location;
		self->_locality = nil;
	}
	
	if (!self.locality) {
		[self reverseGeocodeLocation];
	}
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error {
	self.completeon(nil, nil, error);
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager*)manager {
	NSString* errDescr = nil;
	if (@available(macOS 11.0, *)) {
		switch (manager.authorizationStatus) {
			case kCLAuthorizationStatusAuthorized:
				[self.locationManager startUpdatingLocation];
				break;
			case kCLAuthorizationStatusDenied:
				errDescr = @"Location access denied";
				break;
			case kCLAuthorizationStatusNotDetermined:
				errDescr = @"Location authorization not yet determined";
				break;
			case kCLAuthorizationStatusRestricted:
				errDescr = @"Location services restricted";
				break;
			default:
				errDescr = @"Unknown authorization status";
				break;
		}
	}
	else {
		// Fallback for macOS 10.15 and earlier
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		switch ([CLLocationManager authorizationStatus]) {
			case kCLAuthorizationStatusAuthorized:
				[self.locationManager startUpdatingLocation];
				break;
			case kCLAuthorizationStatusDenied:
				errDescr = @"Location access denied";
				break;
			case kCLAuthorizationStatusNotDetermined:
				errDescr = @"Location authorization not yet determined";
				break;
			case kCLAuthorizationStatusRestricted:
				errDescr = @"Location services restricted";
				break;
			default:
				errDescr = @"Unknown authorization status";
				break;
		}
#pragma clang diagnostic pop
		
	}
	
	if (errDescr) {
		NSError* error = [NSError errorWithDomain:@"LocationManager" code:LocationManagerErrorAuthorizationFailure userInfo:@{NSLocalizedDescriptionKey: errDescr}];
		self.completeon(nil, nil, error);
	}
}

@end
