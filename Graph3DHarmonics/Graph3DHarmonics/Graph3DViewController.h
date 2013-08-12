//
//  Graph3DViewController.h
//  AuraApp
//
//  Created by (´・ω・`) on 09.08.13.
//  Copyright (c) 2013 Quantum Life LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"

@interface Graph3DViewController : UIViewController

@property (strong, nonatomic) IBOutlet EAGLView 	*view;
@property (weak, nonatomic) CADisplayLink			*displayLink;
@property (atomic, assign) BOOL						isSurfacePrepared;

#pragma mark - Animation control methods
- (void) startAnimation;
- (void) stopAnimation;


@end
