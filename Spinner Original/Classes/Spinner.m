//
//  Spinner.m
//  Spinner
//
//  Created by Matthew French on 8/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Spinner.h"

@implementation Spinner


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}
- (void)awakeFromNib {
	arrow = [UIImage imageNamed:@"arrow.png"];
	[arrow retain];
	//rotationVel = 100;
	
	swipetimermax = 0.3;
	swipemindist = 100;
	
	oldSliceCount = 0;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)runDraw{
	
	CGRect parentViewBounds = self.bounds;
	
	
	int slices = [[slicesTxt text] intValue];
	
	//Update pie
	if (oldSliceCount != slices) {
		if (pie != nil) {[pie release]; pie = nil;}
		pie = [self updatePie];
		[pie retain];
		oldSliceCount = slices;
		[pieImage setImage:pie];
	}
	//[pie drawAtPoint:CGPointMake(parentViewBounds.size.width/2.0 - pie.size.width/2.0,parentViewBounds.size.height/2.0 - pie.size.height/2.0)];
	
	//draw arrow
	//CGContextTranslateCTM(UIGraphicsGetCurrentContext(), parentViewBounds.size.width/2.0, parentViewBounds.size.height/2.0);
	//CGContextRotateCTM(UIGraphicsGetCurrentContext(), rotation * M_PI / 180);
	pieImage.center = CGPointMake(parentViewBounds.size.width/2.0,parentViewBounds.size.height/2.0);
	arrowImage.center = CGPointMake(parentViewBounds.size.width/2.0,parentViewBounds.size.height/2.0);
	//arrowImage.image.size = CGSizeMake(230, 50);
	
	arrowImage.transform = CGAffineTransformMakeRotation(rotation * M_PI / 180);
	//[arrow drawAtPoint:CGPointMake(parentViewBounds.size.width/2.0 - arrow.size.width/2.0,parentViewBounds.size.height/2.0 - arrow.size.height/2.0)];
	//[arrow drawAtPoint:CGPointMake(- arrow.size.width/2.0,- arrow.size.height/2.0)];
	
	//Update the textfield with the chosen slice
	if (hasSpun) {
		int chosen = floor(rotation/360*slices);
		if (chosen >= 0) {chosen = -chosen + slices;} else {chosen *= -1;}
		[chosenSlice setText:[NSString stringWithFormat:@"Chosen: %d", chosen]];
	}
	
	rotation += rotationVel;
	if (rotation > 360) {rotation -= 360;}
	if (rotation < -360) {rotation += 360;}
	if (abs(rotationVel) < 2) {
		rotationVel *= .96;
	} else {
		rotationVel *= .98;
	}
}


-(UIImage *)updatePie{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(NULL, 151*2, 151*2, 8, 4 * 151*2, colorSpace, kCGImageAlphaPremultipliedFirst);
    
	CGPoint offset = CGPointMake(1, 1);
	
	int slices = [[slicesTxt text] intValue];
	if (slices > 1000) {slices = 1000;}
	int radius = 150;
	
	CGContextSetRGBStrokeColor(contextRef, 0, 0, 255, 1.0);
	float color[] = {1.0,0.0,0.0,1.0};
	CGContextSetFillColor(contextRef, color);
	CGContextSetLineWidth(contextRef,2.0);
	
	CGContextStrokeEllipseInRect(contextRef, CGRectMake(offset.x,offset.y, radius*2, radius*2));
	
	if (slices > 1) {
		for (int i = 0; i < slices; i++) {
			CGContextMoveToPoint(contextRef, radius+offset.x, radius+offset.y);
			CGContextAddLineToPoint(contextRef, radius + cos(2*M_PI/slices*i)*radius+offset.x, radius + sin(2*M_PI/slices*i)*radius+offset.y);
			CGContextStrokePath(contextRef);
			//draw text
			NSString* number = [NSString stringWithFormat:@"%d",i+1];
			CGSize size = [number sizeWithFont:[UIFont fontWithName:@"Georgia" size:20]];
			char* text	= (char *)[number cStringUsingEncoding:NSASCIIStringEncoding];// "05/05/09";
			CGContextSelectFont(contextRef, "Georgia", 20, kCGEncodingMacRoman);
			CGContextSetTextDrawingMode(contextRef, kCGTextFill);
			CGContextSetRGBFillColor(contextRef, 255, 0, 0, 1);
			CGContextShowTextAtPoint(contextRef, 
									 radius + cos(2.0*M_PI/slices*(i+0.5))*(radius*0.9) - size.width/2.0+offset.x,  
									 radius + sin(2.0*M_PI/slices*(i+0.5))*(radius*0.9) - size.height/4.0+offset.y, text, strlen(text));
		}
	} else {
		//draw text
		NSString* number = [NSString stringWithFormat:@"%d",1];
		CGSize size = [number sizeWithFont:[UIFont fontWithName:@"Georgia" size:20]];
		char* text	= (char *)[number cStringUsingEncoding:NSASCIIStringEncoding];// "05/05/09";
		CGContextSelectFont(contextRef, "Georgia", 20, kCGEncodingMacRoman);
		CGContextSetTextDrawingMode(contextRef, kCGTextFill);
		CGContextSetRGBFillColor(contextRef, 255, 0, 0, 1);
		CGContextShowTextAtPoint(contextRef, 
								 radius - size.width/2.0+offset.x,  
								 radius*1.905 - size.height/4.0+offset.y, text, strlen(text));
	}
	

    CGImageRef imageMasked = CGBitmapContextCreateImage(contextRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
	
    return [UIImage imageWithCGImage:imageMasked];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
	 NSArray* allTouches = [touches allObjects];
	 
	CGPoint touch = CGPointMake([[allTouches objectAtIndex:0] locationInView:self].x, [[allTouches objectAtIndex:0] locationInView:self].y);
	
	/**
	starttoset = touch;
	startpoint = CGPointMake(-1, -1);
	endpoint = CGPointMake(-1, -1);
	swipetimer = CFAbsoluteTimeGetCurrent();
	 **/
	oldSwipePos = touch;
	
	hasSpun = TRUE;
	 
	[slicesTxt resignFirstResponder];
}
- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{
	NSArray* allTouches = [touches allObjects];
	
	CGPoint touch = CGPointMake([[allTouches objectAtIndex:0] locationInView:self].x, [[allTouches objectAtIndex:0] locationInView:self].y);
	
	CGRect parentViewBounds = self.bounds;
	
	float omega1 = atan2(oldSwipePos.y - parentViewBounds.size.height/2.0, oldSwipePos.x - parentViewBounds.size.width/2.0) / M_PI * 180;
	float omega2 = atan2(touch.y - parentViewBounds.size.height/2.0, touch.x - parentViewBounds.size.width/2.0) / M_PI * 180;
	if (omega1 < -90 && omega2 > 90) {omega1 += 360;}
	if (omega2 < -90 && omega1 > 90) {omega2 += 360;}
	rotationVel += (omega2-omega1)* sqrt((touch.x*2)+(touch.y*2))/100;
	
	oldSwipePos = touch;
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	 //NSArray* allTouches = [touches allObjects];
	 //CGPoint touch = CGPointMake([[allTouches objectAtIndex:0] locationInView:self].x, [[allTouches objectAtIndex:0] locationInView:self].y);
	
	/**
	float xleg = touch.x-starttoset.x;
	float yleg = touch.y-starttoset.y;
	float hypotenuse = sqrt((xleg*xleg)+(yleg*yleg));
	CFTimeInterval time = CFAbsoluteTimeGetCurrent();
	float delta = (time - swipetimer);
	//NSLog(@"Delta: %f vs Max:%f", delta,  swipetimermax);
	if (delta < swipetimermax && hypotenuse >= swipemindist) {
		startpoint = starttoset;
		endpoint = touch;
		swiperotation = atan2(yleg, xleg) / M_PI * 180;
		rotationVel += hypotenuse*delta;
	}
	 **/
}



- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)dealloc {
	if (pie != nil) {
		[pie release];
		pie = nil;
	}
	[arrow release];
    [super dealloc];
}


@end
