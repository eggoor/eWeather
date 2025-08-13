//
//  ReqOpenWeatherMap.m
//  eWeather
//
//  Created by e on 09.07.2025.
//

#import "WmoCode.h"
#import "OpenWeatherMap.h"

static NSString* urlEndPoint = @"https://api.openweathermap.org/data/2.5/weather";
static NSString* queryStringFormat = @"%@?lat=%f&lon=%f&exclude=minutely,hourly,daily,alerts&appid=%s&units=metric";
static const char* const appId = "b4d6a638dd4af5e668ccd8574fd90cec";

@implementation OpenWeatherMap

+ (instancetype)make:(const CLLocation* restrict)location {
	return [[OpenWeatherMap alloc] initWithLocation:location];
}

- (instancetype)initWithLocation:(const CLLocation* restrict)location {
	return [super init:location.coordinate];
}

- (NSString*) name {
	return @"OpenWeather";
}

- (NSURL*) currentWeatherUrl {
	return [NSURL URLWithString:[NSString stringWithFormat:queryStringFormat, urlEndPoint, latitude, longitude, appId]];
}

- (Weather* _Nullable)processResponse:(NSDictionary*)json error:(NSError**)error {
	if (![json objectForKey:@"cod"]) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenWeatherMapErrorCodeNoResponseCode userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'cod' found in %@", json]}];
		}
		return nil;
	}

	int cod = [json[@"cod"] intValue];
	
	if (cod > 299) {
		NSString* message = json[@"message"] ?: @"Unknown error";
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenWeatherMapErrorCodeServerError userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Got error code %d: %@", cod, message]}];
		}
		return nil;
	}
	
	NSArray* weatherArray = json[@"weather"];
	if (!weatherArray) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenWeatherMapErrorCodeNoWeatherArray userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'weather' array found in %@", json]}];
		}
		return nil;
	}
	
	NSDictionary* weather = weatherArray.firstObject;
	if (!weather) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenWeatherMapErrorCodeNoWeather userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'weather' found in %@", weatherArray]}];
		}
		return nil;
	}
	
	if (![weather objectForKey:@"id"]) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenWeatherMapErrorCodeNoWeatherId userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'id' found in %@", weather]}];
		}
		return nil;
	}
	
	WmoCode* wmoCode = [WmoCode codeFromInt:[self weatherId2Wmo:[weather[@"id"] intValue]]];
	
	NSDictionary* main = json[@"main"];
	if (!main) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenWeatherMapErrorCodeNoMain userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'main' dictionary found in %@", json]}];
		}
		return nil;
	}
	
	NSNumber* temperatureNumber = main[@"temp"];
	if (temperatureNumber == nil || ![temperatureNumber isKindOfClass:[NSNumber class]]) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenWeatherMapErrorCodeTemperatureFailure userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid 'temp' value: '%@' is not a valid number", main[@"temp"]]}];
		}
		return nil;
	}
	
	NSDate* dt = [NSDate dateWithTimeIntervalSince1970:[json[@"dt"] doubleValue]];
	NSDictionary* sys = json[@"sys"];
	NSDate* sunrise = [NSDate dateWithTimeIntervalSince1970:[sys[@"sunrise"] doubleValue]];
	NSDate* sunset = [NSDate dateWithTimeIntervalSince1970:[sys[@"sunset"] doubleValue]];
	
	BOOL isDay = [dt compare:sunrise] == NSOrderedDescending && [dt compare:sunset] == NSOrderedAscending;
	
	NSDictionary* wind = json[@"wind"];
	if (!wind) {
		if (error) {
			*error = [NSError errorWithDomain:self.name code:OpenWeatherMapErrorCodeNoWind userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"No 'wind' dictionary found in %@", json]}];
		}
		return nil;
	}

	return currentWeather = [Weather weatherFromCode:wmoCode celsiusTemperature:[temperatureNumber doubleValue] isDay:isDay timeStamp:dt windDirection:[wind[@"deg"] intValue] windSpeed:[wind[@"speed"] doubleValue]];
}

- (int)weatherId2Wmo:(int)weatherId {
	switch (weatherId) {
		case 800: return 0; // Clear sky
		case 801: return 1; // Mainly clear
		case 802: return 2; // Partly cloudy
		case 803:
		case 804: return 3; // Cloudy
		case 701 ... 781: return 45; // Fog, mist, etc. (simplified to fog)
		case 500 ... 504: return 61; // Rain (simplified to moderate rain)
		case 511:
		case 611 ... 613: return 67; // Freezing rain
		case 520 ... 531: return 80; // Rain showers
		case 600 ... 602: return 71; // Snow
		case 620 ... 622: return 85; // Snow showers
		case 200 ... 232: return 95; // Thunderstorm
		default:
			@throw [NSException exceptionWithName:@"WeatherMappingException" reason:[NSString stringWithFormat:@"Unknown OpenWeatherMap weather ID: %d", weatherId] userInfo:@{@"weatherId": @(weatherId)}];
	}
}

@end
