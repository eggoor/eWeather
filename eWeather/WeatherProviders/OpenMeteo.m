//
//  OpeMeteoRequest.m
//  eWeather
//
//  Created by e on 06.07.2025.
//

#import "OpenMeteo.h"

static NSString* urlEndPoint = @"https://api.open-meteo.com/v1/forecast";
static NSString* queryStringFormat = @"%@?latitude=%f&longitude=%f&timezone=%@&current_weather=true";

@implementation OpenMeteo {
	NSString* timeZone;
}

+ (instancetype)make:(const CLLocation* restrict) location timeZone:(NSString*) timeZone {
	return [[OpenMeteo alloc] initWithLocation:location timeZone:timeZone];
}

- (instancetype)initWithLocation:(const CLLocation* restrict) location timeZone:(NSString*) timeZone {
	self = [super init:location.coordinate];
	if (self) {
		self->timeZone = timeZone;
	}
	return self;
}

- (NSString*)name {
	return @"Open-Meteo";
}

- (NSURL*)currentWeatherUrl {
	return [NSURL URLWithString:[NSString stringWithFormat:queryStringFormat, urlEndPoint, latitude, longitude, timeZone]];
}

- (Weather* _Nullable)processResponse:(NSDictionary*)json error:(NSError**)error {
	if (json[@"error"] != nil) {
		NSString* reason = json[@"reason"] ?: @"Unknown error";
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenMeteoErrorCodeServerError userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"'%@' returned error: %@", self.name, reason]}];
		}
		return nil;
	}
	
	NSDictionary* current = json[@"current_weather"];
	if (!current) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenMeteoErrorCodeNoCurrentWeather userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'current_weather' dictionary found in %@", json]}];
		}
		return nil;
	}
	
	NSDictionary* units = json[@"current_weather_units"];
	
	if (units == nil) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenMeteoErrorCodeNoUnits userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'units' found in %@", json]}];
		}
		return nil;
	}

	NSString* temperatureUnit = units[@"temperature"];
	NSString* timeStampFormat = units[@"time"];
	
	NSString* timeStampStr = current[@"time"];
	if (timeStampStr == nil) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenMeteoErrorCodeNoTimestamp userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'time' found in %@", current]}];
		}
		return nil;
	}
	
	NSDate* timeStamp = nil;
	if ([timeStampFormat isEqualToString:@"iso8601"]) {
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm"];
		timeStamp = [formatter dateFromString:timeStampStr];
		if (!timeStamp) {
			if (error) {
				*error = [NSError errorWithDomain:self.name code:OpenMeteoErrorCodeInvalidTimestamp userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Failed to parse timestamp '%@'", timeStampStr]}];
			}
			return nil;
		}
	}
	
	if (![current objectForKey:@"weathercode"]) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenMeteoErrorCodeWmoCodeFailure userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'weathercode' found in %@", current]}];
		}
		return nil;
	}
	
	NSNumber* wmoCodeNumber = current[@"weathercode"];
	if (wmoCodeNumber == nil || ![wmoCodeNumber isKindOfClass:[NSNumber class]]) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenMeteoErrorCodeWmoCodeFailure userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid 'weathercode' value: '%@' is not a valid number", current[@"weathercode"]]}];
		}
		return nil;
	}

	WmoCode* weatherCode = [WmoCode codeFromInt:[wmoCodeNumber intValue]];
	
	NSNumber* temperatureNumber = current[@"temperature"];
	if (temperatureNumber == nil || ![temperatureNumber isKindOfClass:[NSNumber class]]) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenMeteoErrorCodeTemperatureFailure userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid 'temperature' value: '%@' is not a valid number", current[@"temperature"]]}];
		}
		return nil;
	}

	return [Weather weatherFromCode:weatherCode temperature:[temperatureNumber doubleValue] temperatureUnit:temperatureUnit isDay:[current[@"is_day"] boolValue] timeStamp:timeStamp windDirection:[current[@"winddirection"] intValue] windSpeed:[current[@"windspeed"] doubleValue]];
}

@end
