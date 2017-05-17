//
//  ViewController.m
//  COSC428
//
//  Created by Matt Gordon on 16/04/17.
//  Copyright © 2017 Matt Gordon. All rights reserved.
//

#import "VisionViewController.h"
#import "PrefsManager.h"

using namespace cv;

@interface VisionViewController ()

@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider;
@property (weak, nonatomic) IBOutlet UILabel *kernelLabel;
@property (weak, nonatomic) IBOutlet UIStepper *kernelStepper;

@property int kernelSize;

@end

@implementation VisionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = YES;
    
    self.kernelSize = (int)[PrefsManager getMedianBlurSize];
    self.kernelStepper.value = self.kernelSize;
    
    self.thresholdSlider.value = [PrefsManager getCannyThreshold];
    
    [self updateKernelSize];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)kernelSizeChanged:(id)sender {
    self.kernelSize = self.kernelStepper.value;
    [self updateKernelSize];
}


- (IBAction)startPressed:(id)sender {

    [self.videoCamera start];
}

- (void)updateKernelSize {
    self.kernelLabel.text = [NSString stringWithFormat:@"%d", self.kernelSize];
}

- (void)processImage:(Mat&)image;
{
    std::vector<Vec4i> lines;
    
    // Do some OpenCV stuff with the image
    medianBlur(image, image, self.kernelSize);
    Canny(image, image, self.thresholdSlider.value, self.thresholdSlider.value * 3);
    
    HoughLinesP(image, lines, 1, CV_PI/180, 80, 30, 10);
    cvtColor(image, image, CV_GRAY2BGR);
    for ( size_t i = 0; i < lines.size(); i++) {
        line(image, cv::Point(lines[i][0], lines[i][1]),
             cv::Point(lines[i][2], lines[i][3]), Scalar(0, 0, 255), 3, 8);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self videoCamera] stop];
    [PrefsManager setMedianBlurSize:[self kernelSize]];
    [PrefsManager setCannyThreshold:[[self thresholdSlider] value]];
    [super viewWillDisappear:animated];
}


@end
