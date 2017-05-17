//
//  CombinedViewController.h
//  COSC428
//
//  Created by Matt Gordon on 25/04/17.
//  Copyright © 2017 Matt Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>
#import "GravityView.h"

@interface CombinedViewController : UIViewController<CvVideoCameraDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet GravityView *gravityView;

@end
