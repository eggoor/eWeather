//
//  WmoCode.m
//  eWeather
//
//  Created by e on 06.07.2025.
//

#import "WmoCode.h"

static NSDictionary* makeKnownCodes(void);
static NSDictionary* knownCodes;

@implementation WmoCode

+ (instancetype)codeFromInt:(int)val {
	return [[WmoCode alloc] initFromInt:val];
}

- (instancetype)initFromInt:(int)val {
	self = super.init;
	if (self) {
		if (!knownCodes) {
			knownCodes = makeKnownCodes();
		}
		_code = [self closestCode:val];
	}
	return self;
}

- (BOOL)isEqual:(id)object {
	if (self == object) {
		return YES;
	}

	if (![object isKindOfClass:[WmoCode class]]) {
		return NO;
	}

	WmoCode* other = (WmoCode*)object;
	return [self.code isEqual:other.code];
}

- (NSUInteger)hash {
	return [self.code hash];
}

- (NSString*)description {
	return knownCodes[self.code] ?: [NSString stringWithFormat:@"Undefined WMO code %@", self.code];
}

- (NSNumber*) closestCode:(int) val {
	NSArray* keys = [knownCodes allKeys];
	if (keys.count == 0) {
		return nil;
	}
	
	NSNumber* closestKey = keys[0];
	int minDifference = ABS([keys[0] intValue] - val);
	
	for (NSNumber* key in keys) {
		int difference = ABS([key intValue] - val);
		if (difference < minDifference) {
			minDifference = difference;
			closestKey = key;
		}
	}
	
	return closestKey;
}

@end

static NSDictionary* makeKnownCodes(void) {
	NSDictionary* knownCodes = @{
		@0: @"Clear sky",
		@1: @"Mainly clear",
		@2: @"Partly cloudy",
		@3: @"Overcast",
		@45: @"Fog",
		@48: @"Depositing rime fog",
		@51: @"Light drizzle",
		@53: @"Drizzle",
		@55: @"Dense drizzle",
		@56: @"Light freezing drizzle",
		@57: @"Dense freezing drizzle",
		@61: @"Light rain",
		@63: @"Rain",
		@65: @"Heavy rain",
		@66: @"Light freezing rain",
		@67: @"Heavy freezing rain",
		@71: @"Light show",
		@73: @"Snow",
		@75: @"Heavy snow",
		@77: @"Snow grains",
		@80: @"Light rainshower",
		@81: @"Rainshower",
		@82: @"Violent rainshower",
		@85: @"Snowshower",
		@86: @"Heavy snowshower",
		@95: @"Thunderstorm",
		@96: @"Thunderstorm with hail",
		@99: @"Heavy thunderstorm with hail"
	};
	return knownCodes;
}
