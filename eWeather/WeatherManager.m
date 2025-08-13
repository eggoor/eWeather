//
//  WeatherManager.m
//  eWeather
//
//  Created by e on 08.08.2025.
//

#import "OpenMeteo.h"
#import "OpenWeatherMap.h"
#import "WeatherApi.h"
#import "VisualCrossing.h"

#import "AggregatedWeather.h"

#import "WeatherManager.h"

static const int weatherUpdateIntervalMin = 15;
static const double weatherUpdateIntervalSec = weatherUpdateIntervalMin * 60;

@interface WeatherManager ()

@property (copy) void (^weatherChangedHandler)(Weather* weather);

@end

@implementation WeatherManager {
	CLLocation* location;
	WeatherFetcher* fetcher;
	NSArray* weatherProviders;
	NSUInteger xCurrentProvider;
	AggregatedWeather* aggregatedWeather;
	NSTimer* timer;
}

@dynamic currentWeather;

- (Weather* _Nullable) currentWeather {
	return aggregatedWeather.currentWeather;
}

+ (instancetype)weatherManagerForLocation:(CLLocation*)location withFetcher:(WeatherFetcher*)fetcher andCompletion:(void (^)(Weather* weather))completion {
	return [[WeatherManager alloc] initForLocation:location withFetcher: fetcher andCompletion:completion];
}

- (instancetype)initForLocation:(CLLocation*)location withFetcher:(WeatherFetcher*)fetcher andCompletion:(void (^)(Weather* weather))completion {
	if (!location) {
		[NSException raise:@"WeatherManager" format:@"Location must be specified"];
	}
	
	if (!fetcher) {
		[NSException raise:@"WeatherManager" format:@"Fetcher must be specified"];
	}
	
	if (!completion) {
		[NSException raise:@"WeatherManager" format:@"Completion handler must be specified"];
	}
	
	if (self = [super init]) {
		self->location = location;
		self->fetcher = fetcher;
		self->_weatherChangedHandler = completion;
		self->weatherProviders = [self makeWeatherProviders];
		self->aggregatedWeather = [[AggregatedWeather alloc] init];
		
		[self determineWeather];
	}
	
	return self;
}

- (NSArray*)makeWeatherProviders {
	return @[
		[self makeOpenMeteoProvider],
		[self makeOpenWeatherMapProvider],
		[self makeWeatherApiProvider],
		//[self makeVisualCrossingProvider],
	];
}

- (id<WeatherProvider>)makeOpenMeteoProvider {
	return [OpenMeteo make:location timeZone:[[NSTimeZone systemTimeZone] name]];
}

- (id<WeatherProvider>)makeOpenWeatherMapProvider {
	return [OpenWeatherMap make:location];
}

- (id<WeatherProvider>)makeWeatherApiProvider {
	return [WeatherApi make:location];
}

- (id<WeatherProvider>)makeVisualCrossingProvider {
	return [VisualCrossing make:location];
}

- (void)determineWeather {
	[aggregatedWeather reset];
	
	for (id<WeatherProvider> weatherProvider in weatherProviders) {
		[self fetchAndReport:weatherProvider];
	}
	
	[self scheduleUpdate];
}

- (void)updateWeather {
	[self fetchAndReport:[self getNextProvider]];
}

- (id<WeatherProvider>)getNextProvider {
	id<WeatherProvider> weatherProvider = weatherProviders[xCurrentProvider++];
	
	if (xCurrentProvider == weatherProviders.count) {
		xCurrentProvider = 0;
	}
	
	return weatherProvider;
}

- (void)scheduleUpdate {
	if (timer) {
		[timer invalidate];
		timer = nil;
	}
	
	xCurrentProvider = 0;
	
	timer = [NSTimer scheduledTimerWithTimeInterval:weatherUpdateIntervalSec / weatherProviders.count target:self selector:@selector(updateWeather) userInfo:nil repeats:YES];
}

- (void)fetchAndReport:(id<WeatherProvider>)weatherProvider {
	__block BOOL weatherChanged = NO;
	[fetcher fetchFrom:weatherProvider.currentWeatherUrl completion:^(NSDictionary* response, NSError* _Nullable error) {
		if (error) {
			NSLog(@"Fetch from %@ (%@) failed: %@", weatherProvider.name, weatherProvider.currentWeatherUrl, error);
			weatherChanged = [self->aggregatedWeather discard:weatherProvider.name];
		}
		else {
			Weather* weather = [weatherProvider processResponse:response error:&error];

			if (error) {
				NSLog(@"%@ failed to process response <%@>: %@", weatherProvider.name, response, error);
				weatherChanged = [self->aggregatedWeather discard:weatherProvider.name];
			}
			else {
				weatherChanged = [self->aggregatedWeather update:weatherProvider.name withWeather:weather];
			}
		}

		if (weatherChanged) {
			self.weatherChangedHandler(self->aggregatedWeather.currentWeather);
		}
	}];
}

@end
