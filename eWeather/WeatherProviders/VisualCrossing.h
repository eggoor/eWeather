//
//  VisualCrossing.h
//  eWeather
//
//  Created by e on 12.08.2025.
//

#import "WeatherProviderBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface VisualCrossing : WeatherProviderBase

+ (instancetype)make:(const CLLocation* restrict)location;

@end

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSInteger, VisualCrossingErrorCode) {
	VisualCrossingErrorCodeGeneric = -1,
	VisualCrossingErrorCodeNoCurrent = 1001,
	VisualCrossingErrorCodeNoCondition = 1002,
	VisualCrossingErrorCodeConditionCodeFailure = 1003,
	VisualCrossingErrorCodeConditionTempFailure = 1004,
};
