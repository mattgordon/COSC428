//
//  MotionViewController.m
//  COSC428
//
//  Created by Matt Gordon on 18/04/17.
//  Copyright © 2017 Matt Gordon. All rights reserved.
//

#import "MotionViewController.h"
#include <math.h>

@interface MotionViewController ()

@property (nonatomic, retain) CMMotionManager *motionManager;

@end

@implementation MotionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1 / 30.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startGravityUpdates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopGravityUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startGravityUpdates {
    [[self motionManager]
     startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
     toQueue:[NSOperationQueue mainQueue]
     withHandler:^void(CMDeviceMotion *motion, NSError *error) {
         [self updateVectorDisplayForX:motion.gravity.x AndY:motion.gravity.y];
     }];
}

- (void)updateVectorDisplayForX:(double)x AndY:(double)y {
    // update the view giving the visual representation of the gravity vector
    [[self gravityView] updateViewForX:x AndY:y];
    double angle = acos(-x / sqrt(x*x + y*y)) * (180.0 / M_PI);
    [[self angleLabel] setText:[NSString stringWithFormat:@"%.2f", angle]];
}

- (void)stopGravityUpdates {
    [[self motionManager] stopDeviceMotionUpdates];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
