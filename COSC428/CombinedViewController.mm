//
//  CombinedViewController.m
//  COSC428
//
//  Created by Matt Gordon on 25/04/17.
//  Copyright © 2017 Matt Gordon. All rights reserved.
//

#import "CombinedViewController.h"
#import "PrefsManager.h"
#import <CoreMotion/CoreMotion.h>

using namespace cv;

@interface CombinedViewController ()

@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (nonatomic, retain) CMMotionManager *motionManager;

@end


// scale a line segment to
Vec4i scaledLineSegment(Vec4i inLine, double scale) {
    double x1 = inLine[0];
    double y1 = inLine[1];
    double x2 = inLine[2];
    double y2 = inLine[3];
    
    double xDiff = x1 - x2;
    double yDiff = y1 - y2;
    
    double norm = sqrt(xDiff*xDiff + yDiff*yDiff);
    
    double xNormed = xDiff / norm;
    double yNormed = yDiff / norm;
    
    return Vec4i(x1 - xNormed * scale, y1 - yNormed * scale,
                 x1 + xNormed * scale, y1 + yNormed * scale);
}

// find a point perpendicular to the line, with an offset from the line
Vec2i perpPoint(Vec4i inLine, double offset) {
    double x1 = inLine[0];
    double y1 = inLine[1];
    double x2 = inLine[2];
    double y2 = inLine[3];
    
    double xDiff = x1 - x2;
    double yDiff = y1 - y2;
    
    double norm = sqrt(xDiff*xDiff + yDiff*yDiff);
    
    double xNormed = xDiff / norm;
    double yNormed = yDiff / norm;
    
    return Vec2i(x1 + yNormed * offset, y1 - xNormed * offset);
}

@implementation CombinedViewController

NSInteger _kernelSize = 3;
double _cannyThreshold = 0;

double _gravityX, _gravityY, _gravityZ, _normGravityX, _normGravityY, _normGravityZ,
       _gravityNorm, _gravityDotProductXAxis, _tilt, _mag;

// THIS IS A REALLY UGLY HACK
// The 'proper' way is to get the videoFieldOfView property from the appropriate
// AVCaptureDeviceFormat instance, but CvVideoCamera does not seem to expose this
// in a convenient way
// This is valid for iPhone 7 rear camera:
double _cameraFov = 58.975/2;

BOOL _shouldSample;

Mat _dilutionKernel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _kernelSize = [PrefsManager getMedianBlurSize];
    _cannyThreshold = [PrefsManager getCannyThreshold];
    
    // Set up the camera
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageView];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1 / 30.0;
    
    _dilutionKernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(3,3));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[self videoCamera] start];
    
    [[self motionManager]
     startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
     toQueue:[NSOperationQueue mainQueue]
     withHandler:^void(CMDeviceMotion *motion, NSError *error) {
         _gravityX = -motion.gravity.x;
         _gravityY = motion.gravity.y;
         _gravityZ = motion.gravity.z;
         _gravityNorm = sqrt(_gravityX * _gravityX + _gravityY * _gravityY + _gravityZ * _gravityZ);
         _normGravityX = _gravityX / _gravityNorm;
         _normGravityY = _gravityY / _gravityNorm;
         _normGravityZ = _gravityZ / _gravityNorm;
         _gravityDotProductXAxis = _gravityX / sqrt(_gravityX * _gravityX + _gravityY * _gravityY);
         _mag = sqrt(_gravityX*_gravityX + _gravityY*_gravityY + _gravityZ*_gravityZ);
         _tilt = acos(_gravityZ/_mag) * (180.0 / M_PI) - 90.0;
         [[self gravityView] updateViewForX:-_gravityX AndY:_gravityY];
     }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self videoCamera] stop];
    [[self motionManager] stopDeviceMotionUpdates];
    [super viewWillDisappear:animated];
}

- (void)sampleInitial:(Mat&) image {
    
}

- (void)processImage:(Mat&)image;
{
    // declare working variables
    std::vector<Vec4i> allLines;
    
    cvtColor(image, image, CV_RGBA2BGR);
    
    
    Mat workingImage; // grayscale working image for Canny, Hough
    Mat workingMask = Mat(image.rows, image.cols, CV_8UC1); // Mask per line
    Mat thresholder = Mat(image.rows, image.cols, CV_8UC1); // Cumulative thresholding image
    Mat workingBinary = Mat(image.rows, image.cols, CV_8UC1); // Binary mask for above-horizon
    cvtColor(image, workingImage, CV_BGR2GRAY);
    
    double xDiff, yDiff, dotProductNormalised, angle, z, newX1, newY1, newX2, newY2;
    Scalar colour;
    
    
    medianBlur(workingImage, workingImage, (int)_kernelSize);
    Canny(workingImage, workingImage, _cannyThreshold, _cannyThreshold * 3);
    
    HoughLinesP(workingImage, allLines, 1, CV_PI/180, 80, 30, 10);
    
    // calculate artificial horizon
    // centre point
    z = (_tilt / _cameraFov) * (image.rows / 2);
    newX1 = _normGravityY * image.rows  + z*_normGravityX + image.cols/2;
    newY1 = -_normGravityX * image.rows  + z*_normGravityY + image.rows/2;
    newX2 = _normGravityY * -(image.rows) + z*_normGravityX + image.cols/2;
    newY2 = _normGravityX * image.rows + z*_normGravityY + image.rows/2;
    
    workingMask.setTo(Scalar(0));
    
    thresholder.setTo(Scalar(0));
    
    for ( size_t i = 0; i < allLines.size(); i++) {
        // NOTE: camera/image space x and y are swapped relative to device motion
        // x and y
        
        // calculate line segment vector
        xDiff = allLines[i][0] - allLines[i][2];
        yDiff = allLines[i][1] - allLines[i][3];
        
        // take normalised dot product of line segment vector with gravity vec.
        dotProductNormalised = (xDiff * _gravityX + yDiff * _gravityY) /
            (sqrt(xDiff * xDiff + yDiff * yDiff) *
             sqrt(_gravityX * _gravityX + _gravityY * _gravityY));
        angle = acos(dotProductNormalised) * (180.0/M_PI);
        
        //b -1, a-2
        if (((newX1 - newX2) * (allLines[i][1] - newY2) -
             (newY1 - newY2) * (allLines[i][0] - newX2)) > 0) {
            if (((newX1 - newX2) * (allLines[i][3] - newY2) -
                 (newY1 - newY2) * (allLines[i][2] - newX2)) > 0) {
                // line segment lies entirely above horizon, is useless. prune!
                continue;
            }
        }
        
        // classify lines by angle
        if (angle < 160 && angle > 20) {
            // horizontal line
            line(image, cv::Point(allLines[i][0], allLines[i][1]),
                 cv::Point(allLines[i][2], allLines[i][3]),
                 Scalar(255, 255, 0), 3, 8);
            workingMask.setTo(Scalar(0));
            
            // distance from horizon
            double dist = 2 * sqrt(((newX1 + newX2) / 2 - (allLines[i][0] + allLines[i][2])/2)*
                                   ((newX1 + newX2) - (allLines[i][0] + allLines[i][2])/2) +
                                   ((newY1 + newY2) / 2 - (allLines[i][1] + allLines[i][3])/2)*
                                   ((newY1 + newY2) - (allLines[i][1] + allLines[i][3])/2)) / image.rows;
            if (angle < 120 && angle > 30){
                dist+=1; // tight horizontal line
            }
            
            
            Vec4i scaledLine = scaledLineSegment(allLines[i], 1000);
            line(workingMask, cv::Point(scaledLine[0], scaledLine[1]),
                 cv::Point(scaledLine[2], scaledLine[3]), Scalar(floor(2 + dist)), 1, 8);
            double fillX = max(0.0, min(allLines[i][0] -_normGravityX*2, (double)image.cols-1));
            double fillY = max(0.0, min(allLines[i][1] - _normGravityY*2, (double)image.rows-1));
            floodFill(workingMask, cv::Point(fillX, fillY), Scalar(floor(2 + dist)));
            
            cv::add(workingMask, thresholder, thresholder);
        }
    }
    
    line(image, cv::Point(newX1, newY1), cv::Point(newX2, newY2), Scalar(255,255, 255), 3, 8);
    
    Vec4i workingLine;
    
    workingBinary.setTo(Scalar(0));
    // put horizon line on last
    double fillX = max(0.0, min((newX1 + newX2)/2 + _gravityX*2, (double)image.cols-1));
    double fillY = max(0.0, min((newY1 + newY2)/2 + _gravityY*2, (double)image.rows-1));
    line(workingBinary, cv::Point(newX1, newY1) , cv::Point(newX2, newY2), Scalar(2), 1, 8);
    floodFill(workingBinary, cv::Point(fillX, fillY), Scalar(2));
    
    // mask off the above-horizon area
    thresholder.setTo(Scalar(0), workingBinary);
    
    // Otsu thresholding on grayscale threshold cumulative image
    cv::threshold(thresholder, thresholder, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    
    workingImage = Mat(image.rows, image.cols, CV_8UC3);
    
    workingImage.setTo(Scalar(128, 0, 0), thresholder);
    
    cv::addWeighted(image, 1, workingImage, 1, 0, image);
    
    if(_shouldSample) {
        [self sampleFinal:image];
    }
    
    
}


// from http://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (void)sampleFinal:(Mat&) image {
    UIImage *savableImage = [self UIImageFromCVMat:image];
    NSData *imageData = UIImagePNGRepresentation(savableImage);
    
    NSInteger sampleInteger = [PrefsManager getSampleInteger];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"Sample-%ld.png", (long)sampleInteger]];
    
    sampleInteger += 1;
    [PrefsManager setSampleInteger:sampleInteger];
    
    [imageData writeToFile:path atomically:YES];
    _shouldSample = NO;
}


- (IBAction)samplePressed:(id)sender {
    _shouldSample = YES;
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
