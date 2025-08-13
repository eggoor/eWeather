//
//  OpeMeteoRequest.h
//  eWeather
//
//  Created by e on 06.07.2025.
//

#import <Foundation/Foundation.h>

#import "WeatherProviderBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenMeteo: WeatherProviderBase
+ (instancetype) make:(const CLLocation* restrict) location timeZone:(NSString*) timeZone;
@end

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSInteger, OpenMeteoErrorCode) {
	OpenMeteoErrorCodeGeneric = -1,
	OpenMeteoErrorCodeServerError = 1000,
	OpenMeteoErrorCodeNoCurrentWeather = 1001,
	OpenMeteoErrorCodeNoUnits = 1002,
	OpenMeteoErrorCodeNoTimestamp = 1003,
	OpenMeteoErrorCodeInvalidTimestamp = 1004,
	OpenMeteoErrorCodeWmoCodeFailure = 1005,
	OpenMeteoErrorCodeTemperatureFailure = 1006,
};
