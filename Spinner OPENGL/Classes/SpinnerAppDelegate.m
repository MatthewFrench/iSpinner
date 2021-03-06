#import "SpinnerAppDelegate.h"
#import "SpinnerViewController.h"

@implementation SpinnerAppDelegate

@synthesize window;
@synthesize viewController, hasSpun;

- (void)appTimerTick {
	displayFps += 1;
	if (displayFps >= 6) {
		float count = 1/(CFAbsoluteTimeGetCurrent() - fpsCounter);
		NSLog(@"%f",count);
		displayFps = 0;
	}
	fpsCounter = CFAbsoluteTimeGetCurrent();
	[spinnerView renderScene];
}
-(IBAction)addSlice:(id)sender {
	int slices = [[slicesTxt text] intValue];
	[slicesTxt setText:[NSString stringWithFormat:@"%d", slices + 1]];
	[slicesTxt resignFirstResponder];
}
-(IBAction)loseSlice:(id)sender {
	int slices = [[slicesTxt text] intValue];
	if (slices != 1) {
		[slicesTxt setText:[NSString stringWithFormat:@"%d", slices - 1]];
	}
	[slicesTxt resignFirstResponder];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
	[viewController setView:spinnerView];
    [window addSubview:spinnerView];
    [window makeKeyAndVisible];

	appTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/40.0 target:self selector:@selector(appTimerTick) userInfo:nil repeats:YES];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
