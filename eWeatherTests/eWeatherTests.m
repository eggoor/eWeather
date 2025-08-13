//
//  eWeatherTests.m
//  eWeatherTests
//
//  Created by e on 07.07.2025.
//

#import <XCTest/XCTest.h>
#import "WmoCode.h"
#import "Weather.h"
#import "AggregatedWeather.h"
#import "OpenWeatherMap.h"

@interface eWeatherTests : XCTestCase

@end

@implementation eWeatherTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - WmoCode Tests

- (void)testWmoCodeCreationWithKnownCode {
    WmoCode *code = [WmoCode codeFromInt:0];
    XCTAssertNotNil(code);
    XCTAssertEqual([code.code intValue], 0);
}

- (void)testWmoCodeCreationWithUnknownCodeClosest {
    WmoCode *code = [WmoCode codeFromInt:4];
    XCTAssertNotNil(code);
    // Closest to 3 or 1, but based on min diff; assuming keys, closest to 3 (diff 1) vs 2 (2), etc.
    XCTAssertEqual([code.code intValue], 3); // Adjust based on actual closest
}

- (void)testWmoCodeCreationWithNegativeCode {
    WmoCode *code = [WmoCode codeFromInt:-1];
    XCTAssertNotNil(code);
    // Closest should be 0
    XCTAssertEqual([code.code intValue], 0);
}

- (void)testWmoCodeCreationWithLargeCode {
    WmoCode *code = [WmoCode codeFromInt:100];
    XCTAssertNotNil(code);
    // Closest to 99
    XCTAssertEqual([code.code intValue], 99);
}

- (void)testWmoCodeDescriptionKnown {
    WmoCode *code = [WmoCode codeFromInt:0];
    XCTAssertEqualObjects([code description], @"Clear sky");
}

- (void)testWmoCodeDescriptionAnotherKnown {
    WmoCode *code = [WmoCode codeFromInt:45];
    XCTAssertEqualObjects([code description], @"Fog");
}

- (void)testWmoCodeDescriptionClosest {
    WmoCode *code = [WmoCode codeFromInt:100];
    XCTAssertEqualObjects([code description], @"Heavy thunderstorm with hail");
}

- (void)testWmoCodeEqualitySame {
    WmoCode *code1 = [WmoCode codeFromInt:0];
    WmoCode *code2 = [WmoCode codeFromInt:0];
    XCTAssertEqualObjects(code1, code2);
}

- (void)testWmoCodeEqualityDifferent {
    WmoCode *code1 = [WmoCode codeFromInt:0];
    WmoCode *code2 = [WmoCode codeFromInt:1];
    XCTAssertNotEqualObjects(code1, code2);
}

- (void)testWmoCodeEqualityWithSelf {
    WmoCode *code = [WmoCode codeFromInt:0];
    XCTAssertEqualObjects(code, code);
}

- (void)testWmoCodeEqualityWithNonWmoCode {
    WmoCode *code = [WmoCode codeFromInt:0];
    XCTAssertNotEqualObjects(code, @"Not a code");
}

- (void)testWmoCodeHashSameObjects {
    WmoCode *code1 = [WmoCode codeFromInt:45];
    WmoCode *code2 = [WmoCode codeFromInt:45];
    XCTAssertEqual([code1 hash], [code2 hash]);
}

- (void)testWmoCodeHashDifferentObjects {
    WmoCode *code1 = [WmoCode codeFromInt:0];
    WmoCode *code2 = [WmoCode codeFromInt:1];
    XCTAssertNotEqual([code1 hash], [code2 hash]);
}

#pragma mark - Weather Tests

- (void)testWeatherCreationBasic {
    WmoCode *code = [WmoCode codeFromInt:0];
    Weather *weather = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:YES];
    XCTAssertNotNil(weather);
    XCTAssertEqualObjects(weather.weatherCode, code);
    XCTAssertEqual(weather.temperature, 25.0);
    XCTAssertEqualObjects(weather.temperatureUnit, @"°C");
    XCTAssertTrue(weather.isDay);
    XCTAssertNil(weather.timeStamp);
    XCTAssertEqual(weather.windDirection, 0);
    XCTAssertEqual(weather.windSpeed, 0.0);
}

- (void)testWeatherCreationWithUnit {
    WmoCode *code = [WmoCode codeFromInt:1];
    Weather *weather = [Weather weatherFromCode:code temperature:77.0 temperatureUnit:@"°F" isDay:NO];
    XCTAssertEqual(weather.temperature, 77.0);
    XCTAssertEqualObjects(weather.temperatureUnit, @"°F");
    XCTAssertFalse(weather.isDay);
}

- (void)testWeatherCreationFull {
    WmoCode *code = [WmoCode codeFromInt:2];
    NSDate *timestamp = [NSDate date];
    Weather *weather = [Weather weatherFromCode:code celsiusTemperature:20.5 isDay:YES timeStamp:timestamp windDirection:90 windSpeed:5.5];
    XCTAssertEqual(weather.temperature, 20.5);
    XCTAssertEqualObjects(weather.timeStamp, timestamp);
    XCTAssertEqual(weather.windDirection, 90);
    XCTAssertEqual(weather.windSpeed, 5.5);
}

- (void)testWeatherCreationFullWithUnit {
    WmoCode *code = [WmoCode codeFromInt:3];
    NSDate *timestamp = [NSDate date];
    Weather *weather = [Weather weatherFromCode:code temperature:68.0 temperatureUnit:@"°F" isDay:NO timeStamp:timestamp windDirection:180 windSpeed:10.0];
    XCTAssertEqual(weather.temperature, 68.0);
    XCTAssertEqualObjects(weather.temperatureUnit, @"°F");
    XCTAssertEqualObjects(weather.timeStamp, timestamp);
    XCTAssertEqual(weather.windDirection, 180);
    XCTAssertEqual(weather.windSpeed, 10.0);
}

- (void)testWeatherRoundedTemperaturePositive {
	Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.4 isDay:YES];
	XCTAssertEqual(weather.roundedTemperature, 25);
}

- (void)testWeatherRoundedTemperaturePositive2 {
	Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:24.95 isDay:YES];
	XCTAssertEqual(weather.roundedTemperature, 25);
}

- (void)testWeatherRoundedTemperatureNegative {
    Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:-3.6 isDay:YES];
    XCTAssertEqual(weather.roundedTemperature, -4);
}

- (void)testWeatherRoundedTemperatureZero {
    Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:0.0 isDay:YES];
    XCTAssertEqual(weather.roundedTemperature, 0);
}

- (void)testWeatherRoundedTemperatureHalf {
    Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:1.5 isDay:YES];
    XCTAssertEqual(weather.roundedTemperature, 2);
}

- (void)testWeatherDisplayTemperature {
    Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    XCTAssertEqualObjects(weather.displayTemperature, @"25°C");
}

- (void)testWeatherDisplayTemperatureNegative {
    Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:-5.0 isDay:YES];
    XCTAssertEqualObjects(weather.displayTemperature, @"-5°C");
}

- (void)testWeatherDisplayTemperatureCustomUnit {
    Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] temperature:77.0 temperatureUnit:@"°F" isDay:YES];
    XCTAssertEqualObjects(weather.displayTemperature, @"77°F");
}

- (void)testWeatherEqualitySame {
    WmoCode *code = [WmoCode codeFromInt:0];
    Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:YES];
    Weather *w2 = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:YES];
    XCTAssertEqualObjects(w1, w2);
}

- (void)testWeatherEqualityDifferentTempWithinTolerance {
    WmoCode *code = [WmoCode codeFromInt:0];
    Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:24.95 isDay:YES];
    Weather *w2 = [Weather weatherFromCode:code celsiusTemperature:25.04 isDay:YES];
    XCTAssertEqualObjects(w1, w2);
}

- (void)testWeatherEqualityDifferentTempOutsideTolerance {
	WmoCode *code = [WmoCode codeFromInt:0];
	Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:24.95 isDay:YES];
	Weather *w2 = [Weather weatherFromCode:code celsiusTemperature:25.05 isDay:YES];
	XCTAssertNotEqualObjects(w1, w2);
}

- (void)testWeatherEqualityDifferentSign {
	WmoCode *code = [WmoCode codeFromInt:0];
	Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:+1.0 isDay:YES];
	Weather *w2 = [Weather weatherFromCode:code celsiusTemperature:-1.0 isDay:YES];
	XCTAssertNotEqualObjects(w1, w2);
}

- (void)testWeatherEqualityDifferentCode {
    Weather *w1 = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    Weather *w2 = [Weather weatherFromCode:[WmoCode codeFromInt:1] celsiusTemperature:25.0 isDay:YES];
    XCTAssertNotEqualObjects(w1, w2);
}

- (void)testWeatherEqualityDifferentIsDay {
    WmoCode *code = [WmoCode codeFromInt:0];
    Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:YES];
    Weather *w2 = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:NO];
    XCTAssertNotEqualObjects(w1, w2);
}

- (void)testWeatherEqualityDifferentUnit {
    WmoCode *code = [WmoCode codeFromInt:0];
    Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:YES];
    Weather *w2 = [Weather weatherFromCode:code temperature:25.0 temperatureUnit:@"°F" isDay:YES];
    XCTAssertNotEqualObjects(w1, w2);
}

- (void)testWeatherEqualityWithSelf {
    Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    XCTAssertEqualObjects(weather, weather);
}

- (void)testWeatherEqualityWithNonWeather {
    Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    XCTAssertNotEqualObjects(weather, @"Not weather");
}

- (void)testWeatherHashSameObjects {
	WmoCode *code = [WmoCode codeFromInt:0];
	Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:YES];
	Weather *w2 = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:YES];
	XCTAssertEqual([w1 hash], [w2 hash]);
}

- (void)testWeatherHashSameObjectsWithinTolerance {
	WmoCode *code = [WmoCode codeFromInt:0];
	Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:24.95 isDay:YES];
	Weather *w2 = [Weather weatherFromCode:code celsiusTemperature:25.04 isDay:YES];
	XCTAssertEqual([w1 hash], [w2 hash]);
}

- (void)testWeatherHashDifferent {
	WmoCode *code = [WmoCode codeFromInt:0];
	Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:YES];
	Weather *w2 = [Weather weatherFromCode:code celsiusTemperature:26.0 isDay:YES];
	XCTAssertNotEqual([w1 hash], [w2 hash]);
}

- (void)testWeatherHashDifferentWithinTolerance {
	WmoCode *code = [WmoCode codeFromInt:0];
	Weather *w1 = [Weather weatherFromCode:code celsiusTemperature:24.94 isDay:YES];
	Weather *w2 = [Weather weatherFromCode:code celsiusTemperature:25.04 isDay:YES];
	XCTAssertNotEqual([w1 hash], [w2 hash]);
}

- (void)testWeatherDescription {
    Weather *weather = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.5 isDay:YES];
    XCTAssertEqualObjects([weather description], @"25.5°C Clear sky");
}

#pragma mark - AggregatedWeather Tests

- (void)testAggregatedWeatherInit {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    XCTAssertNotNil(agg);
    XCTAssertNil(agg.currentWeather);
}

- (void)testAggregatedWeatherUpdateSingle {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    WmoCode *code = [WmoCode codeFromInt:0];
    Weather *w = [Weather weatherFromCode:code celsiusTemperature:25.0 isDay:YES];
    BOOL changed = [agg update:@"Provider1" withWeather:w];
    XCTAssertTrue(changed);
    XCTAssertEqualObjects(agg.currentWeather, w);
}

- (void)testAggregatedWeatherUpdateTwoAverage {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    Weather *w1 = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:20.0 isDay:YES];
    Weather *w2 = [Weather weatherFromCode:[WmoCode codeFromInt:2] celsiusTemperature:30.0 isDay:YES];
    [agg update:@"Provider1" withWeather:w1];
    BOOL changed = [agg update:@"Provider2" withWeather:w2];
    XCTAssertTrue(changed);
    XCTAssertEqual(agg.currentWeather.temperature, 25.0);
    XCTAssertEqual([agg.currentWeather.weatherCode.code intValue], 1); // avg (0+2)/2 = 1
    XCTAssertEqualObjects(agg.currentWeather.temperatureUnit, @"°C");
    XCTAssertTrue(agg.currentWeather.isDay);
}

- (void)testAggregatedWeatherUpdateNoChangeIfSame {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    Weather *w = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    [agg update:@"Provider1" withWeather:w];
    BOOL changed = [agg update:@"Provider1" withWeather:w]; // Same
    XCTAssertFalse(changed);
}

- (void)testAggregatedWeatherDiscard {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    Weather *w1 = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:20.0 isDay:YES];
    Weather *w2 = [Weather weatherFromCode:[WmoCode codeFromInt:2] celsiusTemperature:30.0 isDay:YES];
    [agg update:@"Provider1" withWeather:w1];
    [agg update:@"Provider2" withWeather:w2];
    BOOL changed = [agg discard:@"Provider2"];
    XCTAssertTrue(changed);
    XCTAssertEqualObjects(agg.currentWeather, w1);
}

- (void)testAggregatedWeatherDiscardAll {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    Weather *w = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    [agg update:@"Provider1" withWeather:w];
    BOOL changed = [agg discard:@"Provider1"];
    XCTAssertTrue(changed);
    XCTAssertNil(agg.currentWeather);
}

- (void)testAggregatedWeatherDiscardNonExistent {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    Weather *w = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    [agg update:@"Provider1" withWeather:w];
    BOOL changed = [agg discard:@"Provider2"];
    XCTAssertFalse(changed);
    XCTAssertNotNil(agg.currentWeather);
}

- (void)testAggregatedWeatherReset {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    Weather *w = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    [agg update:@"Provider1" withWeather:w];
    [agg reset];
    XCTAssertNil(agg.currentWeather);
}

- (void)testAggregatedWeatherUpdateWithDifferentIsDay {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    Weather *w1 = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:20.0 isDay:YES];
    Weather *w2 = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:30.0 isDay:NO];
    [agg update:@"Provider1" withWeather:w1];
    [agg update:@"Provider2" withWeather:w2]; // Last isDay wins
    XCTAssertFalse(agg.currentWeather.isDay);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

- (void)testAggregatedWeatherUpdateNilProviderThrows {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    Weather *w = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    XCTAssertThrows([agg update:nil withWeather:w]);
}

- (void)testAggregatedWeatherUpdateNilWeatherThrows {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    XCTAssertThrows([agg update:@"Provider1" withWeather:nil]);
}

- (void)testAggregatedWeatherDiscardNilThrows {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    XCTAssertThrows([agg discard:nil]);
}

#pragma clang diagnostic pop

- (void)testAggregatedWeatherMultipleProvidersAverageCode {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    [agg update:@"P1" withWeather:[Weather weatherFromCode:[WmoCode codeFromInt:1] celsiusTemperature:0 isDay:YES]];
    [agg update:@"P2" withWeather:[Weather weatherFromCode:[WmoCode codeFromInt:2] celsiusTemperature:0 isDay:YES]];
    [agg update:@"P3" withWeather:[Weather weatherFromCode:[WmoCode codeFromInt:3] celsiusTemperature:0 isDay:YES]];
    XCTAssertEqual([agg.currentWeather.weatherCode.code intValue], 2); // (1+2+3)/3 = 2
}

- (void)testAggregatedWeatherUpdateChangesOnlyIfDifferent {
    AggregatedWeather *agg = [[AggregatedWeather alloc] init];
    Weather *w1 = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.0 isDay:YES];
    Weather *w2 = [Weather weatherFromCode:[WmoCode codeFromInt:0] celsiusTemperature:25.2 isDay:YES];
    [agg update:@"Provider1" withWeather:w1];
    BOOL changed = [agg update:@"Provider2" withWeather:w2];
    XCTAssertTrue(changed);
}

#pragma mark - OpenWeatherMap Tests

- (void)testOpenWeatherMapName {
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    XCTAssertEqualObjects(provider.name, @"OpenWeather");
}

- (void)testOpenWeatherMapProcessResponseValid {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDictionary *json = @{
        @"cod": @200,
        @"weather": @[@{@"id": @800}],
        @"main": @{@"temp": @25.0},
        @"dt": @(now),
        @"sys": @{@"sunrise": @(now - 3600), @"sunset": @(now + 3600)},
        @"wind": @{@"deg": @90, @"speed": @5.0}
    };
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    NSError *error = nil;
    Weather *weather = [provider processResponse:json error:&error];
    XCTAssertNotNil(weather);
    XCTAssertNil(error);
    XCTAssertEqual([weather.weatherCode.code intValue], 0);
    XCTAssertEqual(weather.temperature, 25.0);
    XCTAssertTrue(weather.isDay);
    XCTAssertEqual(weather.windDirection, 90);
    XCTAssertEqual(weather.windSpeed, 5.0);
    XCTAssertEqual(weather.timeStamp.timeIntervalSince1970, now);
}

- (void)testOpenWeatherMapProcessResponseMissingCod {
    NSDictionary *json = @{};
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    NSError *error = nil;
    Weather *weather = [provider processResponse:json error:&error];
    XCTAssertNil(weather);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OpenWeatherMapErrorCodeNoResponseCode);
}

- (void)testOpenWeatherMapProcessResponseErrorCod {
    NSDictionary *json = @{@"cod": @401, @"message": @"Invalid API key"};
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    NSError *error = nil;
    Weather *weather = [provider processResponse:json error:&error];
    XCTAssertNil(weather);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OpenWeatherMapErrorCodeServerError);
}

- (void)testOpenWeatherMapProcessResponseNoWeatherArray {
    NSDictionary *json = @{@"cod": @200};
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    NSError *error = nil;
    Weather *weather = [provider processResponse:json error:&error];
    XCTAssertNil(weather);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OpenWeatherMapErrorCodeNoWeatherArray);
}

- (void)testOpenWeatherMapProcessResponseNoWeather {
    NSDictionary *json = @{@"cod": @200, @"weather": @[]};
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    NSError *error = nil;
    Weather *weather = [provider processResponse:json error:&error];
    XCTAssertNil(weather);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OpenWeatherMapErrorCodeNoWeather);
}

- (void)testOpenWeatherMapProcessResponseNoWeatherId {
    NSDictionary *json = @{@"cod": @200, @"weather": @[@{}]};
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    NSError *error = nil;
    Weather *weather = [provider processResponse:json error:&error];
    XCTAssertNil(weather);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OpenWeatherMapErrorCodeNoWeatherId);
}

- (void)testOpenWeatherMapProcessResponseNoMain {
    NSDictionary *json = @{@"cod": @200, @"weather": @[@{@"id": @800}]};
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    NSError *error = nil;
    Weather *weather = [provider processResponse:json error:&error];
    XCTAssertNil(weather);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OpenWeatherMapErrorCodeNoMain);
}

- (void)testOpenWeatherMapProcessResponseInvalidTemp {
    NSDictionary *json = @{@"cod": @200, @"weather": @[@{@"id": @800}], @"main": @{@"temp": @"invalid"}};
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    NSError *error = nil;
    Weather *weather = [provider processResponse:json error:&error];
    XCTAssertNil(weather);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OpenWeatherMapErrorCodeTemperatureFailure);
}

- (void)testOpenWeatherMapProcessResponseNoWind {
    NSDictionary *json = @{@"cod": @200, @"weather": @[@{@"id": @800}], @"main": @{@"temp": @25.0}, @"dt": @0, @"sys": @{@"sunrise": @0, @"sunset": @0}};
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    NSError *error = nil;
    Weather *weather = [provider processResponse:json error:&error];
    XCTAssertNil(weather);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, OpenWeatherMapErrorCodeNoWind);
}

- (void)testOpenWeatherMapProcessResponseIsDay {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDictionary *json = @{
        @"cod": @200,
        @"weather": @[@{@"id": @800}],
        @"main": @{@"temp": @25.0},
        @"dt": @(now),
        @"sys": @{@"sunrise": @(now - 3600), @"sunset": @(now + 3600)},
        @"wind": @{@"deg": @0, @"speed": @0.0}
    };
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    Weather *weather = [provider processResponse:json error:nil];
    XCTAssertTrue(weather.isDay);
}

- (void)testOpenWeatherMapProcessResponseIsNight {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDictionary *json = @{
        @"cod": @200,
        @"weather": @[@{@"id": @800}],
        @"main": @{@"temp": @25.0},
        @"dt": @(now),
        @"sys": @{@"sunrise": @(now + 3600), @"sunset": @(now - 3600)},
        @"wind": @{@"deg": @0, @"speed": @0.0}
    };
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    Weather *weather = [provider processResponse:json error:nil];
    XCTAssertFalse(weather.isDay);
}

- (void)testOpenWeatherMapProcessResponseUnknownWeatherId {
    NSDictionary *json = @{
        @"cod": @200,
        @"weather": @[@{@"id": @999}],
        @"main": @{@"temp": @25.0},
        @"dt": @0,
        @"sys": @{@"sunrise": @0, @"sunset": @0},
        @"wind": @{@"deg": @0, @"speed": @0.0}
    };
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    XCTAssertThrows([provider processResponse:json error:nil]);
}

- (void)testOpenWeatherMapWeatherIdMappingClear {
    NSDictionary *json = @{
        @"cod": @200,
        @"weather": @[@{@"id": @800}],
        @"main": @{@"temp": @0},
        @"dt": @0,
        @"sys": @{@"sunrise": @0, @"sunset": @0},
        @"wind": @{@"deg": @0, @"speed": @0.0}
    };
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    Weather *weather = [provider processResponse:json error:nil];
    XCTAssertEqual([weather.weatherCode.code intValue], 0);
}

- (void)testOpenWeatherMapWeatherIdMappingThunderstorm {
    NSDictionary *json = @{
        @"cod": @200,
        @"weather": @[@{@"id": @200}],
        @"main": @{@"temp": @0},
        @"dt": @0,
        @"sys": @{@"sunrise": @0, @"sunset": @0},
        @"wind": @{@"deg": @0, @"speed": @0.0}
    };
    OpenWeatherMap *provider = [OpenWeatherMap make:[[CLLocation alloc] initWithLatitude:0 longitude:0]];
    Weather *weather = [provider processResponse:json error:nil];
    XCTAssertEqual([weather.weatherCode.code intValue], 95);
}

@end
