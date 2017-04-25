//
//  ViewController.h
//  COSC428
//
//  Created by Matt Gordon on 16/04/17.
//  Copyright © 2017 Matt Gordon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/videoio/cap_ios.h>

@interface VisionViewController : UIViewController<CvVideoCameraDelegate>


- (IBAction)startPressed:(id)sender;


@end

