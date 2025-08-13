//
//  WmoCode.h
//  eWeather
//
//  Created by e on 06.07.2025.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WmoCode : NSObject

@property (readonly) NSNumber* code;

+ (instancetype)codeFromInt:(int)val;
- (instancetype)initFromInt:(int)val;

- (NSString*)description;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

@end

NS_ASSUME_NONNULL_END
