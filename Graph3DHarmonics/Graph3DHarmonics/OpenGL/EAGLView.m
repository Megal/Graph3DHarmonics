//
//  EAGLView.m
//  OpenGLES_iPhone
//
//  Created by mmalc Crawford on 11/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EAGLView.h"

@interface EAGLView (/*PrivateMethods*/)
{
	BOOL isRendering_PATCH_VARIABLE;
}

- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation EAGLView

@synthesize context;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:.
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
	if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
    }
    
    return self;
}

- (void)dealloc
{
    [self deleteFramebuffer];    
    
}

- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext) {
        [self deleteFramebuffer];
        
        context = newContext;
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer
{
    if (context && !defaultFramebuffer) {
        [EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object.
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)deleteFramebuffer
{
	if( isRendering_PATCH_VARIABLE )
	{
		return;
	}
	else if ( context /* && !isRendering_PATCH_VARIABLE */ )
	{
		[EAGLContext setCurrentContext:context];
		
		if (defaultFramebuffer) {
			glDeleteFramebuffers(1, &defaultFramebuffer);
			defaultFramebuffer = 0;
		}
		
		if (colorRenderbuffer) {
			glDeleteRenderbuffers(1, &colorRenderbuffer);
			colorRenderbuffer = 0;
		}
	}
}

- (void)setFramebuffer
{
	if (context)
	{
		isRendering_PATCH_VARIABLE = YES;

		[EAGLContext setCurrentContext:context];
		
		if (!defaultFramebuffer)
		{
			[self createFramebuffer];
		}

		[EAGLContext setCurrentContext:context];
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
		[context presentRenderbuffer:GL_RENDERBUFFER_OES];
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, 0);

		isRendering_PATCH_VARIABLE = NO;
	}

	glViewport(0, 0, framebufferWidth, framebufferHeight);
}


- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if ([context respondsToSelector:@selector(presentRenderbuffer:)]) {
        [EAGLContext setCurrentContext:context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

@end
