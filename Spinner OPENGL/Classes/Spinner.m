#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "Spinner.h"
//#import "AppDelegate.h"

#define USE_DEPTH_BUFFER 0


@implementation Spinner

@synthesize context;


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
		
		//CGRect rect = [[UIScreen mainScreen] bounds];
		
			
		// Set up OpenGL projection matrix
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrthof(0, 320, 0, 480, -1, 1);
		glViewport(0, 0, 320, 480);
		//glTranslatef(-100, -320/2, 0.0f );
		glMatrixMode(GL_MODELVIEW);
		//glTranslatef(-0, -240.0f, 0.0f );
		//glRotatef(180.0f, 0.0f, 0.0f, 1.0f);
		//glScalef(-1.0, 1.0, 1.0);
		
		
		// Initialize OpenGL states
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		//glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_DEPTH_TEST);
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND_SRC);
		glEnableClientState(GL_VERTEX_ARRAY);
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		
		
		
		screenDimensions = CGPointMake([self bounds].size.width, [self bounds].size.height);
		//[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
		
	}
    return self;
	
}
- (void)awakeFromNib {
	arrow = [UIImage imageNamed:@"arrow.png"];
	[arrow retain];
	glArrow = [[Image alloc] initWithImage:arrow];
	//rotationVel = 100;
	
	swipetimermax = 0.3;
	swipemindist = 100;
	
	oldSliceCount = 0;
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
- (void)redraw {
	
	CGRect parentViewBounds = self.bounds;
	NSLog(@"%f",parentViewBounds.size.height);	
	
	int slices = [[slicesTxt text] intValue];
	
	//Update pie
	if (oldSliceCount != slices) {
		if (pie != nil) {[pie release]; [glPie release]; pie = nil;}
		pie = [self updatePie];
		[pie retain];
		glPie = [[Image alloc] initWithImage:pie];
		oldSliceCount = slices;
	}
	//if (parentViewBounds.size.height >= 460) {
	//	[self drawImage:glPie AtPoint:CGPointMake(0,0)];
	//}
	[self drawImage:glPie AtPoint:CGPointMake(parentViewBounds.size.width/2.0 - pie.size.width/2.0,parentViewBounds.size.height/2.0 - pie.size.height/2.0)];
	
	//draw arrow
	//CGContextTranslateCTM(UIGraphicsGetCurrentContext(), parentViewBounds.size.width/2.0, parentViewBounds.size.height/2.0);
	//CGContextRotateCTM(UIGraphicsGetCurrentContext(), rotation * M_PI / 180);
	//[arrow drawAtPoint:CGPointMake(parentViewBounds.size.width/2.0 - arrow.size.width/2.0,parentViewBounds.size.height/2.0 - arrow.size.height/2.0)];
	//[arrow drawAtPoint:CGPointMake(- arrow.size.width/2.0,- arrow.size.height/2.0)];
	
	//glTranslatef(parentViewBounds.size.width/2.0, parentViewBounds.size.height/2.0, 0);
	//glRotatef(rotation * M_PI / 180, 0, 0, 0);
	[self drawImage:glArrow AtPoint:CGPointMake(- arrow.size.width/2.0,- arrow.size.height/2.0)];
	//glRotatef(-rotation * M_PI / 180, 0, 0, 0);
	//glTranslatef(-parentViewBounds.size.width/2.0, -parentViewBounds.size.height/2.0, 0);
	
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


- (void)renderScene {
	// Make sure we are renderin to the frame buffer
	[EAGLContext setCurrentContext:context];
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	
	// Clear the color buffer with the glClearColor which has been set
	glClear(GL_COLOR_BUFFER_BIT);
	
	[self redraw];
	
	// Switch the render buffer and framebuffer so our scene is displayed on the screen
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
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

- (void)drawImage:(Image*)image AtPoint:(CGPoint)point {
	
	[image renderAtPoint:CGPointMake(point.x, (point.y-image.imageHeight)+460) centerOfImage:NO];
}

- (void)drawRect:(CGRect)rect color:(float[])color {
	/**
	 GLfloat vertx[4*2];
	 
	 vertx[2] = rect.origin.x;
	 vertx[3] = 320-rect.origin.y;
	 vertx[0] = rect.size.width;
	 vertx[1] = 320-rect.origin.y;
	 vertx[4] = rect.size.width;
	 vertx[5] = 320-rect.size.height;
	 vertx[6] = rect.origin.x;
	 vertx[7] = 320-rect.size.height;
	 
	 GLfloat colors[4 * 4];
	 
	 for(int i = 0; i < 4 * 4; i++) {
	 colors[i] = color[0];
	 colors[++i] = color[1];
	 colors[++i] = color[2];
	 colors[++i] = color[3];
	 }
	 glEnable(GL_BLEND);
	 //glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	 glDisable(GL_DEPTH_TEST);
	 
	 glVertexPointer(2, GL_FLOAT, 0, vertx);
	 glEnableClientState(GL_VERTEX_ARRAY);
	 glColorPointer(4, GL_FLOAT, 0, colors);
	 glEnableClientState(GL_COLOR_ARRAY);
	 glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	 glDisableClientState(GL_COLOR_ARRAY);
	 
	 //glEnable(GL_DEPTH_TEST);
	 glDisable(GL_BLEND);
	 **/
	// Replace the implementation of this method to do your own custom drawing
	
	GLfloat squareVertices[] = {
        rect.origin.x,  320-rect.origin.y,
		rect.size.width, 320-rect.origin.y,
        rect.origin.x,  320-rect.size.height,
		rect.size.width,  320-rect.size.height,
    };
	
	GLubyte squareColors[] = {
        255*color[0], 255*color[1],   255*color[2], 255*color[3],
        255*color[0], 255*color[1],   255*color[2], 255*color[3],
        255*color[0], 255*color[1],   255*color[2], 255*color[3],
        255*color[0], 255*color[1],   255*color[2], 255*color[3],
    };
	glEnable(GL_BLEND);
	
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);
	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisableClientState(GL_COLOR_ARRAY);
	
	glDisable(GL_BLEND);
	
}

- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r  {
	float a, dx, dy, d, h, rx, ry;
	float x2, y2;
	
	/* dx and dy are the vertical and horizontal distances between
	 * the circle centers.
	 */
	dx = c2.x - c1.x;
	dy = c2.y - c1.y;
	
	/* Determine the straight-line distance between the centers. */
	//d = sqrt((dy*dy) + (dx*dx));
	d = hypot(dx,dy); // Suggested by Keith Briggs
	
	/* Check for solvability. */
	if (d > (c1r + c2r))
	{
		/* no solution. circles do not intersect. */
		return FALSE;
	}
	if (d < abs(c1r - c2r))
	{
		/* no solution. one circle is contained in the other */
		return TRUE;
	}
	
	/* 'point 2' is the point where the line through the circle
	 * intersection points crosses the line between the circle
	 * centers.  
	 */
	
	/* Determine the distance from point 0 to point 2. */
	a = ((c1r*c1r) - (c2r*c2r) + (d*d)) / (2.0 * d) ;
	
	/* Determine the coordinates of point 2. */
	x2 = c1.x + (dx * a/d);
	y2 = c1.y + (dy * a/d);
	
	/* Determine the distance from point 2 to either of the
	 * intersection points.
	 */
	h = sqrt((c1r*c1r) - (a*a));
	
	/* Now determine the offsets of the intersection points from
	 * point 2.
	 */
	rx = -dy * (h/d);
	ry = dx * (h/d);
	
	/* Determine the absolute intersection points. */
	
	return TRUE;
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self renderScene];
}
- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}
- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (void)dealloc {
	if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
	if (pie != nil) {
		[pie release];
		[glPie release];
		pie = nil;
	}
	[arrow release];
	[glArrow release];
    [super dealloc];
}

@end
