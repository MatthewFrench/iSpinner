//
//  SpinnerAppDelegate.h
//  Spinner
//
//  Created by Matthew French on 8/5/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spinner.h"

@class SpinnerViewController;

@interface SpinnerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SpinnerViewController *viewController;
	
	NSTimer* appTimer;
	IBOutlet Spinner* spinnerView;
	IBOutlet UITextField* slicesTxt;
	
	
	CFTimeInterval fpsCounter;
	int displayFps;
}
-(IBAction)addSlice:(id)sender;
-(IBAction)loseSlice:(id)sender;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SpinnerViewController *viewController;
@property (nonatomic) BOOL hasSpun;

@end

