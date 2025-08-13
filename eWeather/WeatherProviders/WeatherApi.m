//
//  Weather API.m
//  eWeather
//
//  Created by e on 11.08.2025.
//

#import "WeatherApi.h"

@implementation WeatherApi

static NSString* urlEndPoint = @"https://api.weatherapi.com/v1/current.json";
static NSString* queryStringFormat = @"%@?q=%f,%f&key=%s";
static const char* const key = "7a4baea97ef946c7864221259240804";

+ (instancetype)make:(const CLLocation* restrict)location {
	return [[WeatherApi alloc] initWithLocation:location];
}

- (instancetype) initWithLocation:(const CLLocation* restrict)location {
	return [super init:location.coordinate];
}

- (NSString*)name {
	return @"Weather API";
}

- (NSURL*) currentWeatherUrl {
	return [NSURL URLWithString:[NSString stringWithFormat:queryStringFormat, urlEndPoint, latitude, longitude, key]];
}

- (Weather* _Nullable)processResponse:(NSDictionary*)json error:(NSError**)error {
	NSDictionary* current = json[@"current"];
	if (!current) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:WeatherApiErrorCodeNoCurrent userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'current' dictionary found in %@", json]}];
		}
		return nil;
	}
	
	NSDictionary* condition = current[@"condition"];

	if (!condition) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:WeatherApiErrorCodeNoCondition userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'condition' dictionary found in %@", current]}];
		}
		return nil;
	}
	
	NSNumber* codeNumber = condition[@"code"];
	if (codeNumber == nil || ![codeNumber isKindOfClass:[NSNumber class]]) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:WeatherApiErrorCodeConditionCodeFailure userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid 'code' value: '%@' is not a valid number", condition[@"code"]]}];
		}
		return nil;
	}

	NSNumber* temperatureNumber = current[@"temp_c"];
	if (temperatureNumber == nil || ![temperatureNumber isKindOfClass:[NSNumber class]]) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:WeatherApiErrorCodeConditionTempFailure userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid 'temp_c' value: '%@' is not a valid number", current[@"temp_c"]]}];
		}
		return nil;
	}

	WmoCode* wmoCode = [WmoCode codeFromInt:[self weatherApiToWmo:[codeNumber intValue]]];

	return [Weather weatherFromCode:wmoCode celsiusTemperature:[temperatureNumber doubleValue] isDay:[current[@"is_day"] boolValue]];
}

- (int)weatherApiToWmo:(int)weatherApiCode {
	switch (weatherApiCode) {
		// Clear/Sunny
		case 1000:
			return 0; // WMO: Sunny/Clear
		// Partly Cloudy
		case 1003:
			return 2; // WMO: Partly Cloudy
		// Cloudy
		case 1006:
			return 3; // WMO: Cloudy
		// Overcast
		case 1009:
			return 3; // WMO: Cloudy (overcast maps to cloudy)
		// Mist
		case 1030:
			return 45; // WMO: Foggy (mist simplified to fog)
		// Fog
		case 1135:
		case 1147:
			return 45; // WMO: Foggy
		// Drizzle
		case 1150:
		case 1153:
			return 51; // WMO: Light Drizzle
		case 1168:
			return 56; // WMO: Light Freezing Drizzle
		// Rain
		case 1183:
			return 61; // WMO: Light Rain
		case 1189:
			return 63; // WMO: Rain
		case 1195:
			return 65; // WMO: Heavy Rain
		case 1192:
			return 80; // WMO: Light Showers
		case 1198:
			return 66; // WMO: Light Freezing Rain
		case 1201:
			return 67; // WMO: Freezing Rain
		// Snow
		case 1210:
		case 1213:
			return 71; // WMO: Light Snow
		case 1219:
			return 73; // WMO: Snow
		case 1225:
			return 75; // WMO: Heavy Snow
		case 1237:
			return 77; // WMO: Snow Grains
		case 1255:
			return 85; // WMO: Light Snow Showers
		case 1258:
			return 86; // WMO: Snow Showers
		// Thunderstorm
		case 1273:
		case 1276:
			return 95; // WMO: Thunderstorm
		case 1282:
			return 99; // WMO: Thunderstorm With Hail
		// Other conditions (e.g., patchy rain, sleet)
		case 1063:
		case 1180:
			return 80; // WMO: Light Showers (patchy rain)
		case 1066:
		case 1216:
			return 85; // WMO: Light Snow Showers (patchy snow)
		case 1240:
			return 80; // WMO: Light Showers (light rain showers)
		case 1243:
			return 81; // WMO: Showers (moderate rain showers)
		case 1246:
			return 82; // WMO: Heavy Showers (torrential rain showers)
		case 1279:
			return 85; // WMO: Light Snow Showers (patchy snow showers)
		default:
			@throw [NSException exceptionWithName:@"WeatherMappingException"
										  reason:[NSString stringWithFormat:@"Unknown WeatherAPI.com code: %d", weatherApiCode]
										userInfo:@{@"weatherApiCode": @(weatherApiCode)}];
	}
}

@end
