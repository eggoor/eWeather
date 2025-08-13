//
//  Weather.m
//  eWeather
//
//  Created by e on 06.07.2025.
//

#import "Weather.h"

@implementation Weather

+ (instancetype)weatherFromCode:(WmoCode*) weatherCode celsiusTemperature:(double)celsiusTemperature isDay:(BOOL)isDay {
	return [Weather weatherFromCode:weatherCode temperature:celsiusTemperature temperatureUnit:@"°C" isDay:isDay];
}

+ (instancetype)weatherFromCode:(WmoCode*) weatherCode temperature:(double)temperature temperatureUnit:(NSString*)temperatureUnit isDay:(BOOL)isDay {
	return [Weather weatherFromCode:weatherCode temperature:temperature temperatureUnit:temperatureUnit isDay:isDay timeStamp:nil windDirection:0 windSpeed:0.0];
}

+ (instancetype)weatherFromCode:(WmoCode*) weatherCode celsiusTemperature:(double)celsiusTemperature isDay:(BOOL)isDay timeStamp:(nullable NSDate*)timeStamp windDirection:(int)windDirection windSpeed:(double)windSpeed {
	return [Weather weatherFromCode:weatherCode temperature:celsiusTemperature temperatureUnit:@"°C" isDay:isDay timeStamp:timeStamp windDirection:windDirection windSpeed:windSpeed];
}

+ (instancetype)weatherFromCode:(WmoCode*) weatherCode temperature:(double)temperature temperatureUnit:(NSString*)temperatureUnit isDay:(BOOL)isDay timeStamp:(nullable NSDate*)timeStamp windDirection:(int)windDirection windSpeed:(double)windSpeed {
	return [[Weather alloc] initFromCode:weatherCode temperature:temperature temperatureUnit:temperatureUnit isDay:isDay timeStamp:timeStamp windDirection:windDirection windSpeed:windSpeed];
}

- (instancetype)initFromCode:(WmoCode*) weatherCode temperature:(double)temperature temperatureUnit:(NSString*)temperatureUnit isDay:(BOOL)isDay timeStamp:(NSDate* _Nullable)timeStamp windDirection:(int)windDirection windSpeed:(double)windSpeed {
	self = super.init;
	if (self) {
		_weatherCode = weatherCode;
		_temperature = temperature;
		_temperatureUnit = temperatureUnit;
		_isDay = isDay;
		_timeStamp = timeStamp;
		_windDirection = windDirection;
		_windSpeed = windSpeed;
	}
	return self;
}

- (long)roundedTemperature {
	return lround(self.temperature);
}

- (NSString*)displayTemperature {
	return [NSString stringWithFormat:@"%ld%@", self.roundedTemperature, self.temperatureUnit];
}

- (BOOL)isEqual:(id)object {
	if (self == object) {
		return YES;
	}

	if (![object isKindOfClass:[Weather class]]) {
		return NO;
	}
	
	Weather* other = (Weather*)object;
	
	// Only temperature, WMO code and day/night so far..
	return [self.temperatureUnit isEqual:other.temperatureUnit] && ((self.temperature >= 0) == (other.temperature >= 0)) && fabs(self.temperature - other.temperature) <= 0.09 && [self.weatherCode isEqual:other.weatherCode] && self.isDay == other.isDay;
}

- (NSUInteger)hash {
	// Only temperature, WMO code and day/night so far..
	return self.temperatureUnit.hash ^ @(round(self.temperature * 10.0) / 10.0).hash ^ self.weatherCode.hash ^ (self.isDay ? 1231 : 1237);
}

- (NSString*)description {
	return [NSString stringWithFormat:@"%.1f%@ %@", self.temperature, self.temperatureUnit, [self.weatherCode description]];
}

@end
