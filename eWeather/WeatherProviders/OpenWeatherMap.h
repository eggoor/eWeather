//
//  ReqOpenWeatherMap.h
//  eWeather
//
//  Created by e on 09.07.2025.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "WeatherProviderBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenWeatherMap : WeatherProviderBase

+ (instancetype)make:(const CLLocation* restrict)location;

@end

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSInteger, OpenWeatherMapErrorCode) {
	OpenWeatherMapErrorCodeGeneric = -1,
	OpenWeatherMapErrorCodeNoResponseCode = 1000,
	OpenWeatherMapErrorCodeServerError = 1001,
	OpenWeatherMapErrorCodeNoWeatherArray = 1002,
	OpenWeatherMapErrorCodeNoWeather = 1003,
	OpenWeatherMapErrorCodeNoWeatherId = 1004,
	OpenWeatherMapErrorCodeTemperatureFailure = 1005,
	OpenWeatherMapErrorCodeNoMain = 1006,
	OpenWeatherMapErrorCodeNoWind = 1007,
	OpenWeatherMapErrorCodeWmoCodeFailure = 1008,
};
