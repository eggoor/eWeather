//
//  WeatherFetcher.m
//  eWeather
//
//  Created by e on 05.07.2025.
//

#import "WeatherFetcher.h"

@implementation WeatherFetcher

- (void)fetchFrom:(NSURL*)requestUrl completion:(void (NS_SWIFT_SENDABLE ^)(NSDictionary* response, NSError* _Nullable error))completion {
	NSURLSessionDataTask* task = [[NSURLSession sharedSession] dataTaskWithURL:requestUrl completionHandler:^(NSData* _Nullable data, NSURLResponse* _Nullable response, NSError* _Nullable error) {
		[WeatherFetcher onFetched:data WithResponse:response AndError:error Completion:completion];
	}];
	[task resume];
}

+ (void)onFetched:(NSData*)data WithResponse:(NSURLResponse*)response AndError:(NSError*)error Completion:(void (NS_SWIFT_SENDABLE ^)(NSDictionary* response, NSError* _Nullable error))completion {
	if (error) {
		completion(nil, error);
		return;
	}

	NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if (error) {
		completion(nil, error);
		return;
	}
	
	if (!json) {
		error = [NSError errorWithDomain:@"WeatherFetcher" code:1002 userInfo:@{NSLocalizedDescriptionKey: @"JSONObjectWithData returned nil"}];
		completion(nil, error);
		return;
	}

	completion(json, error);
}

@end
