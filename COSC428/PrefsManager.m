//
//  PrefsManager.m
//  COSC428
//
//  Created by Matt Gordon on 25/04/17.
//  Copyright © 2017 Matt Gordon. All rights reserved.
//

#import "PrefsManager.h"

@implementation PrefsManager

static NSString* const kMedianBlurSizeKey = @"medianBlurSize";
static NSInteger kMedianBlurDefault = 3;
static NSString* const kCannyThresholdKey = @"cannyThreshold";
static NSString* const kSampleInteger = @"sampleInteger";

+ (NSInteger)getMedianBlurSize {
    NSUserDefaults *sharedDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger val = [sharedDefaults integerForKey:kMedianBlurSizeKey];
    
    if (val == 0) {
        val = kMedianBlurDefault; // default value
    }
    
    return val;
}

+ (void)setMedianBlurSize:(NSInteger)value {
    NSLog(@"[PrefsManager]: Set Median blur size to %d", (int)value);
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kMedianBlurSizeKey];
}

+ (double)getCannyThreshold {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kCannyThresholdKey];
}

+ (void)setCannyThreshold:(double)value {
    NSLog(@"[PrefsManager]: Set Canny threshold to %.2f", value);
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:kCannyThresholdKey];
}

+ (NSInteger)getSampleInteger {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kSampleInteger];
}

+ (void)setSampleInteger:(NSInteger) value {
    NSLog(@"[PrefsManager]: Set sample integer to %ld", (long)value);
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kSampleInteger];
}

@end
