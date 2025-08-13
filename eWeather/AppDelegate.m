//
//  AppDelegate.m
//  eWeather
//
//  Created by e on 07.07.2025.
//

#import "LocationManager.h"
#import "WeatherManager.h"
#import "SysImageProvider.h"

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow* aboutView;
@property (weak) IBOutlet NSMenu* menu;

@end

@implementation AppDelegate {
	id<IconProvider> iconProvider;
	NSStatusItem* statusItem;
	LocationManager* locationManager;
	WeatherManager* weatherManager;
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
	iconProvider = [[SysImageProvider alloc] init];
	statusItem = [AppDelegate makeStatusItem:self.menu];
	locationManager = [AppDelegate makeLocationManager:self];
	[self addObserver];
}

+ (NSStatusItem*)makeStatusItem:(NSMenu*)menu {
	NSStatusItem* statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	statusItem.button.toolTip = @"Initializing…";
	statusItem.button.image = [NSImage imageWithSystemSymbolName: @"hourglass" accessibilityDescription:statusItem.button.toolTip];
	statusItem.menu = menu;
	
	return statusItem;
}

+ (LocationManager*)makeLocationManager:(AppDelegate* __weak)weak {
	LocationManager* locationManager = [LocationManager locationManagerWithCompletion:^(CLLocation* location, NSString* locality, NSError* _Nullable error) {
		AppDelegate* strong = weak;
		if (strong) {
			[strong onDeterminedLocation:location andLocality:locality withError:error];
		}
	}];
	
	return locationManager;
}

- (void)onDeterminedLocation:(CLLocation*)location andLocality:(NSString*)locality withError:(NSError*)error {
	if (error) {
		NSLog(@"LocationManager failed: %@", error.localizedDescription);
		[self dispatchUpdateStatusItemWithSymbolName:@"exclamationmark.triangle" AndToolTip:error.localizedDescription];
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		self->statusItem.button.toolTip = [NSString stringWithFormat:@"%@: %@", locality, @"determining…"];
	});
	
	if (!weatherManager) {
		AppDelegate* __weak weak = self;
		weatherManager = [AppDelegate makeWeatherManager:weak forLocation:location withFetcher:[[WeatherFetcher alloc] init]];
	}
}

+ (WeatherManager*)makeWeatherManager:(AppDelegate* __weak)weak forLocation:(CLLocation*)location withFetcher:(WeatherFetcher*) fetcher {
	return [WeatherManager weatherManagerForLocation:location withFetcher:fetcher andCompletion:^(Weather* weather) {
		AppDelegate* strong = weak;
		if (strong) {
			[strong dispatchOnWeatherChanged:weather];
		}
	}];
}

- (void)dispatchOnWeatherChanged:(Weather*)weather {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self onWeatherChanged:weather];
	});
}

- (void)onWeatherChanged:(Weather*)weather {
	self->statusItem.button.image = [self->iconProvider iconForWeather:weather];
	self->statusItem.button.title = weather.displayTemperature;
	self->statusItem.button.toolTip = [NSString stringWithFormat:@"%@: %@", self->locationManager.locality, weather.description];
}

- (IBAction)onUpdateWeather:(id)sender {
	[self doUpdateWeather];
}

- (IBAction)onAbout:(id)sender {
	if (!self.aboutView) {
		[[NSBundle mainBundle] loadNibNamed:@"AboutView" owner:self topLevelObjects:nil];
	}
	
	NSRect buttonRectInWindow = [self->statusItem.button convertRect:self->statusItem.button.bounds toView:nil];
	NSRect buttonRectOnScreen = [self->statusItem.button.window convertRectToScreen:buttonRectInWindow];
	
	NSPoint origin;
	origin.x = buttonRectOnScreen.origin.x;
	origin.y = buttonRectOnScreen.origin.y - self.aboutView.frame.size.height;
	
	[self.aboutView setFrameOrigin:origin];
	
	[self.aboutView makeKeyAndOrderFront:nil];
}

- (IBAction)onAboutViewClose:(id)sender {
	[self.aboutView close];
}

- (IBAction)onQuit:(id)sender {
	[NSApp terminate:nil];
}

- (void) doUpdateWeather {
	if (!locationManager.location) {
		return;
	}
	
	[self updateStatusItemWithSymbolName:@"hourglass" AndToolTip:@"Determining…"];
	
	if (!weatherManager) {
		weatherManager = [AppDelegate makeWeatherManager:self forLocation:locationManager.location withFetcher:[[WeatherFetcher alloc] init]];
		return;
	}
	
	[weatherManager determineWeather];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[self removeObserver];
}

- (void) dispatchUpdateStatusItemWithSymbolName:(NSString*)systemSymbolName AndToolTip:(NSString*)toolTip {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSImage* image = [NSImage imageWithSystemSymbolName: systemSymbolName accessibilityDescription:toolTip];
		[self updateStatusItemWithImage:image AndToolTip:toolTip];
	});
}

- (void) updateStatusItemWithSymbolName:(NSString*)systemSymbolName AndToolTip:(NSString*)toolTip {
	NSImage* image = [NSImage imageWithSystemSymbolName: systemSymbolName accessibilityDescription:toolTip];
	[self updateStatusItemWithImage:image AndToolTip:toolTip];
}

- (void) dispatchUpdateStatusItemWithImage:(NSImage*)image AndToolTip:(NSString*)toolTip {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self updateStatusItemWithImage:image AndToolTip:toolTip];
	});
}

- (void) updateStatusItemWithImage:(NSImage*)image AndToolTip:(NSString*)toolTip {
	self->statusItem.button.image = image;
	self->statusItem.button.toolTip = toolTip;
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
	return YES;
}

- (void)addObserver {
	[NSApp addObserver:self forKeyPath:@"effectiveAppearance" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver {
	[NSApp removeObserver:self forKeyPath:@"effectiveAppearance"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"effectiveAppearance"]) {
		[self onWeatherChanged:weatherManager.currentWeather];
	}
}

@end
