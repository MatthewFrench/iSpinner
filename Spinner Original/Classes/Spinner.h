//
//  Spinner.h
//  Spinner
//
//  Created by Matthew French on 8/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Spinner : UIView {
	IBOutlet UITextField* slicesTxt, *chosenSlice;
	IBOutlet UIImageView* pieImage, *arrowImage;
	
	UIImage* arrow;
	double rotation,rotationVel;
	
	CGPoint startpoint;
	CGPoint endpoint;
	CGPoint starttoset;
	CFTimeInterval swipetimer;
	float swipetimermax;
	float swipemindist;
	float swiperotation;
	
	int oldSliceCount;
	UIImage* pie;
	
	CGPoint oldSwipePos;
	
	BOOL hasSpun;
}
-(UIImage *)updatePie;
-(void)runDraw;

@end
