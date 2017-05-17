//
//  MotionViewController.h
//  COSC428
//
//  Created by Matt Gordon on 18/04/17.
//  Copyright © 2017 Matt Gordon. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>
#import "GravityView.h"

@interface MotionViewController : UIViewController

@property (weak, nonatomic) IBOutlet GravityView *gravityView;
@property (weak, nonatomic) IBOutlet UILabel *angleLabel;

@end
