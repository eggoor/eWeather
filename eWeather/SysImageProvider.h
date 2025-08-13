//
//  SysImageProvider.h
//  eWeather
//
//  Created by e on 06.07.2025.
//

#import <Foundation/Foundation.h>
#import "IconProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface SysImageProvider : NSObject<IconProvider>

- (NSImage*)iconForWeather:(Weather*)weather;

@end

NS_ASSUME_NONNULL_END
