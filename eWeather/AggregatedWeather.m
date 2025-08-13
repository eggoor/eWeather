//
//  AggregatedWeather.m
//  eWeather
//
//  Created by e on 08.08.2025.
//

#import "AggregatedWeather.h"

@implementation AggregatedWeather {
   NSMutableDictionary<NSString*, Weather*>* weatherMap;
   BOOL isDay;
   dispatch_queue_t dq;
}

@synthesize currentWeather = _currentWeather;

- (instancetype)init {
	self = [super init];
	if (self) {
		weatherMap = [[NSMutableDictionary alloc] init];
		dq = dispatch_queue_create("com.asuscomm.smartnclever.eWeather.AggregatedWeather", DISPATCH_QUEUE_SERIAL);
	}
	return self;
}

- (Weather* _Nullable)currentWeather {
	__block Weather* weather;
	dispatch_sync(dq, ^{
		weather = _currentWeather;
	});
	return weather;
}

- (BOOL)update:(NSString*)providerName withWeather:(Weather*)weather {
	if (!providerName) {
		[NSException raise:@"AggregatedWeather" format:@"Provider name cannot be nil"];
	}
	
	if (!weather) {
		[NSException raise:@"AggregatedWeather" format:@"Weather cannot be nil"];
	}
	
	__block BOOL weatherChanged;
	dispatch_sync(dq, ^{
		[weatherMap setObject:weather forKey:providerName];
		isDay = weather.isDay;
		weatherChanged = [self aggregate];
	});
	
	return weatherChanged;
}

- (BOOL)discard:(NSString*)providerName {
	if (!providerName) {
		[NSException raise:@"AggregatedWeather" format:@"providerName cannot be nil"];
	}
	
	__block BOOL weatherChanged;
	dispatch_sync(dq, ^{
		if (!_currentWeather) {
			weatherChanged = NO;
		}
		else {
			[weatherMap removeObjectForKey:providerName];
			
			if (weatherMap.count == 0) {
				_currentWeather = nil;
				weatherChanged = YES;
			}
			else {
				weatherChanged = [self aggregate];
			}
		}
	});
	
	return weatherChanged;
}

- (BOOL) aggregate {
	double temperature = 0.0;
	NSString* temperatureUnit = weatherMap[[weatherMap.allKeys firstObject]].temperatureUnit;
	int weatherCode = 0;

	for (NSString* key in weatherMap) {
		Weather* w  = weatherMap[key];
		temperature += w.temperature;
		weatherCode += w.weatherCode.code.intValue;
	}

	weatherCode = (int)lround((double)weatherCode / weatherMap.count);
	temperature /= weatherMap.count;

	Weather* newWeather = [Weather weatherFromCode:[WmoCode codeFromInt:weatherCode] temperature:temperature temperatureUnit:temperatureUnit isDay:isDay];
	
	if (!_currentWeather || ![_currentWeather isEqual:newWeather]) {
		_currentWeather = newWeather;
		return YES;
	}
	
	return NO;
}

- (void) reset {
	dispatch_sync(dq, ^{
		[weatherMap removeAllObjects];
		_currentWeather = nil;
	});
}

@end
