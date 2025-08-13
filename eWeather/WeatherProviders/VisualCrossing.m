//
//  VisualCrossing.m
//  eWeather
//
//  Created by e on 12.08.2025.
//

#import "VisualCrossing.h"

@implementation VisualCrossing
static NSString* urlEndPoint = @"https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/";
static NSString* queryStringFormat = @"%@%f%%2C%f?unitGroup=metric&key=%s&contentType=json";
static const char* const key = "ES25QFD3CP93EZ9DMSJ72MAX7";

+ (instancetype)make:(const CLLocation* restrict)location {
	return [[VisualCrossing alloc] initWithLocation:location];
}

- (instancetype) initWithLocation:(const CLLocation* restrict)location {
	return [super init:location.coordinate];
}

- (NSString*)name {
	return @"Visual Crossing";
}

- (NSURL*) currentWeatherUrl {
	return [NSURL URLWithString:[NSString stringWithFormat:queryStringFormat, urlEndPoint, latitude, longitude, key]];
}

- (Weather* _Nullable)processResponse:(NSDictionary*)json error:(NSError**)error {
	if (error) {
		*error = [NSError errorWithDomain:self.name code:VisualCrossingErrorCodeGeneric userInfo:@{NSLocalizedDescriptionKey:@"Not implemented"}];
	}
	return nil;
}
@end
