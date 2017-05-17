//
//  PrefsManager.h
//  COSC428
//
//  Created by Matt Gordon on 25/04/17.
//  Copyright © 2017 Matt Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrefsManager : NSObject

+ (NSInteger)getMedianBlurSize;
+ (void)setMedianBlurSize:(NSInteger)value;

+ (double)getCannyThreshold;
+ (void)setCannyThreshold:(double)value;

+ (NSInteger)getSampleInteger;
+ (void)setSampleInteger:(NSInteger)value;

@end
