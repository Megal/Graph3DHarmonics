//
//  Graph3DViewController.m
//  AuraApp
//
//  Created by (´・ω・`) on 09.08.13.
//  Copyright (c) 2013 Quantum Life LLC. All rights reserved.
//

#import "Graph3DViewController.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat _xAngularVelocity=0.06f, _yAngularVelocity=0.03f, _zAngularVelocity=0.01f;

@interface Graph3DViewController ()
{
	GLfloat	*_arrayVetrex;
	GLfloat	*_arrayColor;
	size_t	_countVertex;
	
	GLfloat _xAngle, _yAngle, _zAngle;
}

@end

@implementation Graph3DViewController

#pragma mark - Destroy

- (void) dealloc
{
	// Tear down the context
	if( self.view.context == [EAGLContext currentContext] )
	{
		[EAGLContext setCurrentContext:nil];
	}
	free(_arrayVetrex);
	free(_arrayColor);
}

- (void)viewDidUnload
{
	[self setView:nil];
	self.displayLink = nil;
	[super viewDidUnload];
}

#pragma mark Destroy
#pragma mark - Create

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if( self )
	{
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if( self )
	{
		[self commonInit];
	}
	return self;
}

- (void) commonInit
{
//	static GLfloat coords[] =
//	{
//		-1.0f, 0.0f, -0.5f,
//		-1.0f, -1.0f, -10.5f,
//		0.0f, -1.0f, -20.5f,
//		0.0f, 0.0f, -30.5f,
//		-1.0f, 0.0f, -40.5f,
//		1.0f, 1.0f, -50.5f,
//		0.0f, 1.0f, -60.5f,
//		0.0f, 0.0f, -70.5f,
//		10.0f, 0.0f, -80.5f,
//		10.0f, 10.0f, -90.5f,
//		0.0f, 10.0f, -90.5f,
//		0.0f, 0.0f, -80.5f,
//		-50.0f, -50.0f, -80.5f,
//		50.0f, 0.0f, -70.5f,
//		50.0f, 50.0f, -60.5f,
//		0.0f, 50.0f, -50.5f,
//		0.0f, 0.0f, -40.5f,
//		0.5f, 0.0f, -30.5f,
//		0.5f, 0.5f, -20.5f,
//		0.0f, 0.5f, -10.5f,
//	};
//	static GLfloat coords[] =
//	{
//		-1.0f, 0.0f, -0.1f,
//		-1.0f, -1.0f, -0.15f,
//		0.0f, -1.0f, -0.2f,
//		0.0f, 0.0f, -0.25f,
//		-1.0f, 0.0f, -0.3f,
//		1.0f, 1.0f, -0.35f,
//		0.0f, 1.0f, -0.40f,
//		0.0f, 0.0f, -0.45f,
//		10.0f, 0.0f, -0.5f,
//		10.0f, 10.0f, -0.45f,
//		0.0f, 10.0f, -0.4f,
//		0.0f, 0.0f, -0.35f,
//		-50.0f, -50.0f, -0.3f,
//		50.0f, 0.0f, -0.25f,
//		50.0f, 50.0f, -0.2f,
//		0.0f, 50.0f, -0.15f,
//		0.0f, 0.0f, -0.1f,
//		0.5f, 0.0f, -0.1f,
//		0.5f, 0.5f, -0.1f,
//		0.0f, 0.5f, -0.1f,
//	};
	static GLfloat coords[] =
	{
		-1.0f, 0.0f, 0,
		-1.0f, -1.0f, 0,
		0.0f, -1.0f, 0,
		0.0f, 0.0f, 0,
		-1.0f, 0.0f, 0,
		1.0f, 1.0f, 0,
		0.0f, 1.0f, 0,
		0.0f, 0.0f, 0,
		10.0f, 0.0f, 0,
		10.0f, 10.0f, 0,
		0.0f, 10.0f, 0,
		0.0f, 0.0f, 0,
		-50.0f, -50.0f, 0,
		50.0f, 0.0f, 0,
		50.0f, 50.0f, 0,
		0.0f, 50.0f, 0,
		0.0f, 0.0f, 0,
		0.5f, 0.0f, 0,
		0.5f, 0.5f, 0,
		0.0f, 0.5f, 0,
	};
	_countVertex = sizeof(coords)/sizeof(coords[0])/3;
	
	_arrayVetrex = malloc(sizeof(coords));
	memcpy(_arrayVetrex, coords, sizeof(coords));
		   
	// RGB with float range;
	_arrayColor = malloc( _countVertex * 4 * sizeof(GLfloat) );
	for( int i=0; i<_countVertex; ++i )
	{
		int index = i*4;
		_arrayColor[index] = 1.0; // R = 1.0
		_arrayColor[index+1] = 1.0f * (i / (float)_countVertex); // G
		_arrayColor[index+2] = 1.0f - 1.0f * (i / (float)_countVertex); // B
		_arrayColor[index+3] = 1.0f; // A
	}
	; // nop
}



#pragma mark - View Controller Lifecycle stuff

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
	if( !context )
	{
		NSLog( @"Error : context set to GL1 unsucessfully :(");
		return ;
	}
	
	// Setup context : openGL ES 1.1
	[self.view setContext:context];
	// Enable transparency
	[self.view setOpaque:NO];
	// Prepare for drawing, without conflics with other openGL surfaces
	[self.view setFramebuffer];
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


-(void)viewDidDisappear:(BOOL)animated
{
	self.isSurfacePrepared = NO;
	[super viewDidDisappear:animated];
}


-(void)viewDidAppear:(BOOL)animated
{
	self.isSurfacePrepared = NO;
	[super viewDidAppear:animated];
}


#pragma mark - Drawing routine

//! draw each Frame. Must be called by display link.
- (void) drawFrame
{
	[self.view setFramebuffer];
	
	if( !self.isSurfacePrepared )
	{
		[self prepareSurface];
	}
	
	// clear everything
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	
	// Applies subsequent matrix operations to the modelview matrix stack.
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	glOrthof(-2.0f, 2.0f, -2.0f, 2.0f, -10.0f, 10.0f);
	[self probeGLError];
	
	[self rotateMatrix];
	
	// Disable Textures
	glDisable(GL_TEXTURE_2D);
	
	// set line width
	glLineWidth(2.0f);
	[self probeGLError];
	
	// Enable vertex array, and set it
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, _arrayVetrex);
	[self probeGLError];
	
	// Enable color array and set it
	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4, GL_FLOAT, 0, _arrayColor);
	[self probeGLError];

	// Draw lines! Actial drawing is here
	glDrawArrays(GL_LINE_STRIP, 0, _countVertex);
	[self probeGLError];
	
	// DEBUG errors.
	
	[self.view presentFramebuffer];
}


- (void) rotateMatrix
{
	_xAngle += _xAngularVelocity;
	_yAngle += _yAngularVelocity;
	_zAngle += _zAngularVelocity;
	
	glRotatef(_xAngle, 1, 0, 0);
	glRotatef(_yAngle, 0, 1, 0);
	glRotatef(_zAngle, 0, 0, 1);
}


// Clear display from previously drawn objects
- (void) cleanup
{
	[self.view setFramebuffer];

	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	[self probeGLError];
	
	[self.view presentFramebuffer];
}


//! check if there was an open GL error
- (void) probeGLError
{
	GLenum errorCode = glGetError();
	if( errorCode != GL_NO_ERROR )
	{
		NSLog( @"Error code: 0x%x", errorCode );
	}
}

//! Call it once before first frame draw. Need to call it again if openGL surface was teared down.
- (void) prepareSurface
{
	if( !self.displayLink ) return;
	
	// test for depth
	glEnable(GL_DEPTH_TEST);
	[self probeGLError];
	
	// depth function for depth
	glDepthFunc(GL_LEQUAL);
	[self probeGLError];

	// ??
	glDisable(GL_DITHER);
	[self probeGLError];
	
	// set line parameters. super-smooth lines.
	glEnable(GL_LINE_SMOOTH);
	[self probeGLError];
	glHint( GL_LINE_SMOOTH_HINT, GL_NICEST );
	[self probeGLError];

	self.isSurfacePrepared = YES;
}

#pragma mark - Animation control methods

- (void) startAnimation
{
	if( self.displayLink ) return;
	
	CADisplayLink *displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
	[displayLink setFrameInterval:1];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

	self.displayLink = displayLink;
}

- (void) stopAnimation
{
	[self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self cleanup];
	
	self.displayLink = nil;
	self.isSurfacePrepared = NO;
	
	[self.view setNeedsDisplay];
}


#pragma mark - 

@end
