//
//  Graph3DViewController.h
//  AuraApp
//
//  Created by (´・ω・`) on 09.08.13.
//  Copyright (c) 2013 Quantum Life LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"
#import "Graph3DHarmonicsDrawPreset.h"

@interface Graph3DViewController : UIViewController

@property (strong, nonatomic) IBOutlet EAGLView 			*view;
@property (weak, nonatomic) CADisplayLink					*displayLink;
@property (atomic, assign) BOOL								isSurfacePrepared;
@property (strong, nonatomic) Graph3DHarmonicsDrawPreset	*graph3D;

#pragma mark - Animation control methods
- (void) startAnimation;
- (void) stopAnimation;


@end
