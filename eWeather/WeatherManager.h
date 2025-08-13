//
//  WeatherManager.h
//  eWeather
//
//  Created by e on 08.08.2025.
//

#import <Foundation/Foundation.h>

#import "Weather.h"
#import "WeatherFetcher.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeatherManager : NSObject

@property (readonly, nullable) Weather* currentWeather;

+ (instancetype)weatherManagerForLocation:(CLLocation*)location withFetcher:(WeatherFetcher*)fetcher andCompletion:(void (^)(Weather* weather))completion;
- (instancetype)initForLocation:(CLLocation*)location withFetcher:(WeatherFetcher*)fetcher andCompletion:(void (^)(Weather* weather))completion;

- (void)determineWeather;

@end

NS_ASSUME_NONNULL_END
