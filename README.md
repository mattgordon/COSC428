COSC428: Computer Vision Project
================================

This was created to investigate whether orientation data (i.e. the gravity vector obtained from a combination of accelerometer and gyroscope data) is useful when attempting to detect ground and floor planes in images.

Build Instructions
------------------

First, you must download a copy of the [OpenCV](http://opencv.org) iOS framework and place it at `COSC428/opencv2.framework`. This project was built against [version 3.2 of the framework](https://sourceforge.net/projects/opencvlibrary/files/opencv-ios/3.2.0/opencv-3.2.0-ios-framework.zip/download). 

Once this is complete, Xcode (version 8.3 or later) should be able to build the project as normal.

File Structure
--------------

Much of the code of the project is contained within the view controllers. Where a view controller contains OpenCV code, look for a `-(void)processImage:(Mat&)image` method on the class; this is required to conform to the `CvVideoCameraDelegate` protocol and is where the image processing logic is kept. Other methods are likely to interface with the platform (i.e. setup camera, load view, interface with UI, save images).

### View Controllers

`MotionViewController.m`: This simply plots the x and y components of the gravity vector on axes. This uses the `GravityView.m` class, which is also used in the `CombinedViewController` to display the same information.

`VisionViewController.mm`: This is intended to test the median blur filter and Canny hysteresis parameters using live camera capture. These are configurable in the view. The silder changes the Canny hysteresis lower bound; the upper bound is the lower bound multiplied by 3, as recommended by Canny's paper. The stepper changes the median filter kernel size. These parameters, when set, are saved to the `NSUserDefaults` database using the wrapper defined in `PrefsManager.m`.

`CombinedViewController.mm`: This is where most of the action happens. This carries out the method described in the [paper](http://mattgordon.org/static/COSC428_paper.pdf), using parameters from the `PrefsManager` and motion data collected in the same manner as in the `MotionViewController`. This also includes a 'Sample' button, which saves the currently visible image (including lines and detected floor overlay) as a PNG to the phone's storage. This is accessible via iTunes.

### Other Classes

`GravityView.m`: This takes the raw x and y components of the gravity vector and plots them on axes. The view is reusable in other view controllers.

In addition, there is a `PrefsManager.m` which is a simple wrapper around `NSUserDefaults` which stores saved preferences and a count of images stored.
