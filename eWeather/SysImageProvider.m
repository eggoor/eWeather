//
//  SysImageProvider.m
//  eWeather
//
//  Created by e on 06.07.2025.
//

#import <AppKit/AppKit.h>

#import "SysImageProvider.h"

@implementation SysImageProvider {
	NSDictionary* weatherIcons;
}

- (instancetype)init {
	if (self = [super init]) {
		weatherIcons = [self makeWeatherIcons];
	}
	return self;
}

- (NSImage*) iconForWeather:(Weather*) weather {
	NSDictionary* theme = weatherIcons[[self isDarkModeEnabled] ? @"dark" : @"light"];
	NSDictionary* icons = theme[weather.isDay ? @"day" : @"night"];
	NSString* symbolName = icons[weather.weatherCode.code];
	return [NSImage imageWithSystemSymbolName: symbolName ?: @"questionmark" accessibilityDescription:weather.weatherCode.description];
}

- (BOOL)isDarkModeEnabled {
	if (@available(macOS 10.14, *)) {
		NSAppearance* appearance = NSApplication.sharedApplication.effectiveAppearance;
		NSAppearanceName appearanceName = [appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
		return [appearanceName isEqualToString:NSAppearanceNameDarkAqua];
	}
	else {
		return NO; // Dark mode is not supported in macOS versions earlier than 10.14
	}
}

- (id) makeWeatherIcons {
	return @{@"light": [self makeLightIcons], @"dark": [self makeDarkIcons]};
}

- (id) makeLightIcons {
	return @{@"day": [self makeLightDay], @"night": [self makeLightNight]};
}

- (id) makeDarkIcons {
	return @{@"day": [self makeDarkDay], @"night": [self makeDarkNight]};
}

- (id) makeLightDay {
	NSDictionary* dict = @{
		@0: @"sun.max.fill"				/* Clear sky */,
		@1: @"sun.min.fill"				/* Mainly clear */,
		@2: @"cloud.sun.fill"			/* Partly cloudy */,
		@3: @"cloud.fill"				/* Overcast */,
		@45: @"cloud.fog.fill"			/* Fog */,
		@48: @"cloud.fog.fill"			/* Depositing rime fog */,
		@51: @"cloud.drizzle.fill"		/* Light drizzle */,
		@53: @"cloud.drizzle.fill"		/* Drizzle */,
		@55: @"cloud.drizzle.fill"		/* Dense drizzle */,
		@56: @"cloud.drizzle.fill"		/* Light freezing drizzle */,
		@57: @"cloud.drizzle.fill"		/* Dense freezing drizzle */,
		@61: @"cloud.sun.rain.fill"		/* Light rain */,
		@63: @"cloud.rain.fill"			/* Rain */,
		@65: @"cloud.rain.fill"			/* Heavy rain */,
		@66: @"cloud.sun.rain.fill"		/* Light freezing rain */,
		@67: @"cloud.heavyrain.fill"	/* Heavy freezing rain */,
		@71: @"sun.snow.fill"			/* Light show */,
		@73: @"cloud.snow.fill"			/* Snow */,
		@75: @"cloud.snow.fill"			/* Heavy snow */,
		@77: @"snowflake.fill"			/* Snow grains */,
		@80: @"cloud.heavyrain.fill"	/* Light rainshower */,
		@81: @"cloud.heavyrain.fill"	/* Rainshower */,
		@82: @"cloud.heavyrain.fill"	/* Violent rainshower */,
		@85: @"cloud.snow.fill"			/* Snowshower */,
		@86: @"cloud.snow.fill"			/* Heavy snowshower */,
		@95: @"cloud.sun.bolt.fill"		/* Thunderstorm */,
		@96: @"cloud.sun.bolt.fill"		/* Thunderstorm with hail */,
		@99: @"cloud.sun.bolt.fill"		/* Heavy thunderstorm with hail */
	};
	return dict;
}

- (id) makeDarkDay {
	NSDictionary* dict = @{
		@0: @"sun.max"			/* Clear sky */,
		@1: @"sun.min"			/* Mainly clear */,
		@2: @"cloud.sun"		/* Partly cloudy */,
		@3: @"cloud"			/* Overcast */,
		@45: @"cloud.fog"		/* Fog */,
		@48: @"cloud.fog"		/* Depositing rime fog */,
		@51: @"cloud.drizzle"	/* Light drizzle */,
		@53: @"cloud.drizzle"	/* Drizzle */,
		@55: @"cloud.drizzle"	/* Dense drizzle */,
		@56: @"cloud.drizzle"	/* Light freezing drizzle */,
		@57: @"cloud.drizzle"	/* Dense freezing drizzle */,
		@61: @"cloud.sun.rain"	/* Light rain */,
		@63: @"cloud.rain"		/* Rain */,
		@65: @"cloud.rain"		/* Heavy rain */,
		@66: @"cloud.sun.rain"	/* Light freezing rain */,
		@67: @"cloud.heavyrain"	/* Heavy freezing rain */,
		@71: @"sun.snow"		/* Light show */,
		@73: @"cloud.snow"		/* Snow */,
		@75: @"cloud.snow"		/* Heavy snow */,
		@77: @"snowflake"		/* Snow grains */,
		@80: @"cloud.heavyrain"	/* Light rainshower */,
		@81: @"cloud.heavyrain"	/* Rainshower */,
		@82: @"cloud.heavyrain"	/* Violent rainshower */,
		@85: @"cloud.snow"		/* Snowshower */,
		@86: @"cloud.snow"		/* Heavy snowshower */,
		@95: @"cloud.sun.bolt"	/* Thunderstorm */,
		@96: @"cloud.sun.bolt"	/* Thunderstorm with hail */,
		@99: @"cloud.sun.bolt"	/* Heavy thunderstorm with hail */
	};
	return dict;
}

- (id) makeLightNight {
	NSDictionary* dict = @{
		@0: @"moon.stars"		/* Clear sky */,
		@1: @"moon"				/* Mainly clear */,
		@2: @"cloud.moon"		/* Partly cloudy */,
		@3: @"cloud"			/* Overcast */,
		@45: @"cloud.fog"		/* Fog */,
		@48: @"cloud.fog"		/* Depositing rime fog */,
		@51: @"cloud.drizzle"	/* Light drizzle */,
		@53: @"cloud.drizzle"	/* Drizzle */,
		@55: @"cloud.drizzle"	/* Dense drizzle */,
		@56: @"cloud.drizzle"	/* Light freezing drizzle */,
		@57: @"cloud.drizzle"	/* Dense freezing drizzle */,
		@61: @"cloud.moon.rain"	/* Light rain */,
		@63: @"cloud.rain"		/* Rain */,
		@65: @"cloud.rain"		/* Heavy rain */,
		@66: @"cloud.moon.rain"	/* Light freezing rain */,
		@67: @"cloud.heavyrain"	/* Heavy freezing rain */,
		@71: @"cloud.snow"		/* Light show */,
		@73: @"cloud.snow"		/* Snow */,
		@75: @"cloud.snow"		/* Heavy snow */,
		@77: @"snowflake"		/* Snow grains */,
		@80: @"cloud.heavyrain"	/* Light rainshower */,
		@81: @"cloud.heavyrain"	/* Rainshower */,
		@82: @"cloud.heavyrain"	/* Violent rainshower */,
		@85: @"cloud.snow"		/* Snowshower */,
		@86: @"cloud.snow"		/* Heavy snowshower */,
		@95: @"cloud.moon.bolt"	/* Thunderstorm */,
		@96: @"cloud.moon.bolt"	/* Thunderstorm with hail */,
		@99: @"cloud.moon.bolt"	/* Heavy thunderstorm with hail */
	};
	return dict;
}

- (id) makeDarkNight {
	NSDictionary* dict = @{
		@0: @"moon.stars.fill"			/* Clear sky */,
		@1: @"moon.stars.fill"			/* Mainly clear */,
		@2: @"cloud.moon.fill"			/* Partly cloudy */,
		@3: @"cloud.fill"				/* Overcast */,
		@45: @"cloud.fog.fill"			/* Fog */,
		@48: @"cloud.fog.fill"			/* Depositing rime fog */,
		@51: @"cloud.drizzle.fill"		/* Light drizzle */,
		@53: @"cloud.drizzle.fill"		/* Drizzle */,
		@55: @"cloud.drizzle.fill"		/* Dense drizzle */,
		@56: @"cloud.drizzle.fill"		/* Light freezing drizzle */,
		@57: @"cloud.drizzle.fill"		/* Dense freezing drizzle */,
		@61: @"cloud.moon.rain.fill"	/* Light rain */,
		@63: @"cloud.rain.fill"			/* Rain */,
		@65: @"cloud.rain.fill"			/* Heavy rain */,
		@66: @"cloud.moon.rain.fill"	/* Light freezing rain */,
		@67: @"cloud.heavyrain.fill"	/* Heavy freezing rain */,
		@71: @"cloud.snow.fill"			/* Light show */,
		@73: @"cloud.snow.fill"			/* Snow */,
		@75: @"cloud.snow.fill"			/* Heavy snow */,
		@77: @"snowflake.fill"			/* Snow grains */,
		@80: @"cloud.heavyrain.fill"	/* Light rainshower */,
		@81: @"cloud.heavyrain.fill"	/* Rainshower */,
		@82: @"cloud.heavyrain.fill"	/* Violent rainshower */,
		@85: @"cloud.snow.fill"			/* Snowshower */,
		@86: @"cloud.snow.fill"			/* Heavy snowshower */,
		@95: @"cloud.moon.bolt.fill"	/* Thunderstorm */,
		@96: @"cloud.moon.bolt.fill"	/* Thunderstorm with hail */,
		@99: @"cloud.moon.bolt.fill"	/* Heavy thunderstorm with hail */
	};
	return dict;
}

@end

//@0: @""		/* Clear sky */,
//@1: @""		/* Mainly clear */,
//@2: @""		/* Partly cloudy */,
//@3: @""		/* Overcast */,
//@45: @""		/* Fog */,
//@48: @""		/* Depositing rime fog */,
//@51: @""		/* Light drizzle */,
//@53: @""		/* Drizzle */,
//@55: @""		/* Dense drizzle */,
//@56: @""		/* Light freezing drizzle */,
//@57: @""		/* Dense freezing drizzle */,
//@61: @""		/* Light rain */,
//@63: @""		/* Rain */,
//@65: @""		/* Heavy rain */,
//@66: @""		/* Light freezing rain */,
//@67: @""		/* Heavy freezing rain */,
//@71: @""		/* Light show */,
//@73: @""		/* Snow */,
//@75: @""		/* Heavy snow */,
//@77: @""		/* Snow grains */,
//@80: @""		/* Light rainshower */,
//@81: @""		/* Rainshower */,
//@82: @""		/* Violent rainshower */,
//@85: @""		/* Snowshower */,
//@86: @""		/* Heavy snowshower */,
//@95: @""		/* Thunderstorm */,
//@96: @""		/* Thunderstorm with hail */,
//@99: @""		/* Heavy thunderstorm with hail */
