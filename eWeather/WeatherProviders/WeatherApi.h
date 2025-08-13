//
//  Weather API.h
//  eWeather
//
//  Created by e on 11.08.2025.
//

#import "WeatherProviderBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeatherApi : WeatherProviderBase

+ (instancetype)make:(const CLLocation* restrict)location;

@end

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSInteger, WeatherApiErrorCode) {
	WeatherApiErrorCodeGeneric = -1,
	WeatherApiErrorCodeNoCurrent = 1001,
	WeatherApiErrorCodeNoCondition = 1002,
	WeatherApiErrorCodeConditionCodeFailure = 1003,
	WeatherApiErrorCodeConditionTempFailure = 1004,
};
