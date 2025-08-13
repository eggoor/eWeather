//
//  AggregatedWeather.h
//  eWeather
//
//  Created by e on 08.08.2025.
//

#import <Foundation/Foundation.h>

#import "WeatherProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface AggregatedWeather : NSObject

@property (readonly, nullable) Weather* currentWeather;

- (BOOL)update:(NSString*)providerName withWeather:(Weather*)weather;
- (BOOL)discard:(NSString*)providerName;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
