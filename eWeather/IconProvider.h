//
//  IconProvider.h
//  eWeather
//
//  Created by e on 06.07.2025.
//
#import "Weather.h"

@protocol IconProvider
- (NSImage*)iconForWeather:(Weather*)weather;
@end
