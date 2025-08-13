//
//  WeatherProvider.h
//  eWeather
//
//  Created by e on 06.07.2025.
//

#import "Weather.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WeatherProvider

@property (readonly) NSString* name;
@property (readonly) NSURL* currentWeatherUrl;

- (Weather* _Nullable)processResponse:(NSDictionary*)json error:(NSError**)error;

@end

NS_ASSUME_NONNULL_END
