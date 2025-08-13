//
//  ReqBase.h
//  eWeather
//
//  Created by e on 09.07.2025.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "WeatherProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeatherProviderBase: NSObject<WeatherProvider> {
	@protected
	double latitude;
	double longitude;
	Weather* currentWeather;
}

- (instancetype)init:(const CLLocationCoordinate2D) coordinate;
@end

NS_ASSUME_NONNULL_END
