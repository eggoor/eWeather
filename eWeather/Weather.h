//
//  Weather.h
//  eWeather
//
//  Created by e on 06.07.2025.
//

#import <Foundation/Foundation.h>
#import "WmoCode.h"

NS_ASSUME_NONNULL_BEGIN

@interface Weather : NSObject

@property (readonly) BOOL isDay;
@property (readonly) double temperature;
@property (readonly) NSString* temperatureUnit;
@property (readonly, nullable) NSDate* timeStamp;
@property (readonly) WmoCode* weatherCode;
@property (readonly) int windDirection;
@property (readonly) double windSpeed;
@property (readonly) long roundedTemperature;
@property (readonly) NSString* displayTemperature;

+ (instancetype)weatherFromCode:(WmoCode*) weatherCode celsiusTemperature:(double)temperature isDay:(BOOL)isDay;

+ (instancetype)weatherFromCode:(WmoCode*) weatherCode temperature:(double)temperature temperatureUnit:(NSString*)temperatureUnit isDay:(BOOL)isDay;

+ (instancetype)weatherFromCode:(WmoCode*) weatherCode celsiusTemperature:(double)temperature isDay:(BOOL)isDay timeStamp:(nullable NSDate*)timeStamp windDirection:(int)windDirection windSpeed:(double)windSpeed;

+ (instancetype)weatherFromCode:(WmoCode*) weatherCode temperature:(double)temperature temperatureUnit:(NSString*)temperatureUnit isDay:(BOOL)isDay timeStamp:(nullable NSDate*)timeStamp windDirection:(int)windDirection windSpeed:(double)windSpeed;

- (instancetype)initFromCode:(WmoCode*) weatherCode temperature:(double)temperature temperatureUnit:(NSString*)temperatureUnit isDay:(BOOL)isDay timeStamp:(nullable NSDate*)timeStamp windDirection:(int)windDirection windSpeed:(double)windSpeed;

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

@end

NS_ASSUME_NONNULL_END
