//
//  WeatherFetcher.h
//  eWeather
//
//  Created by e on 05.07.2025.
//

#import <Foundation/Foundation.h>

#import "Weather.h"
#import "WeatherProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeatherFetcher: NSObject

- (void)fetchFrom:(NSURL*)requestUrl completion:(void (NS_SWIFT_SENDABLE ^)(NSDictionary* response, NSError* _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
