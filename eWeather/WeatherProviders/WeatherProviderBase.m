//
//  ReqBase.m
//  eWeather
//
//  Created by e on 09.07.2025.
//

#import "WeatherProviderBase.h"

@implementation WeatherProviderBase

@dynamic name;
@dynamic currentWeatherUrl;

- (instancetype)init:(const CLLocationCoordinate2D)coordinate {
	if ([self class] == [WeatherProviderBase class]) {
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot instantiate abstract class WeatherProviderBase directly" userInfo:nil];
	}
	
	if (self = [super init]) {
		latitude = coordinate.latitude;
		longitude = coordinate.longitude;
	}
	
	return self;
}

- (Weather*)currentWeather {
	return currentWeather;
}

- (Weather* _Nullable)processResponse:(NSDictionary*)json error:(NSError**)error {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ must be implemented by subclass", NSStringFromSelector(_cmd)] userInfo:nil];
}

@end
