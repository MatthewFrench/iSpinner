#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"
#import "Image.h"

@interface Spinner : UIView {
	CGPoint screenDimensions;
	
	IBOutlet UITextField* slicesTxt, *chosenSlice;
	
	UIImage* arrow;
	Image* glArrow;
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
	Image* glPie;
	
	CGPoint oldSwipePos;
	
	BOOL hasSpun;
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
}
@property (nonatomic, retain) EAGLContext *context;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
- (void) renderScene;
- (void) drawImage:(Image*)image AtPoint:(CGPoint)point;
- (void) drawRect:(CGRect)rect color:(float[])color;
- (BOOL) collisionOfCircles:(CGPoint)c1 rad:(float)c1r c2:(CGPoint)c2 rad:(float)c2r;

-(UIImage *)updatePie;

@end
