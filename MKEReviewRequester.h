//
//  MKEReviewRequester.h
//  
//
//  Created by John McKerrell on 05/04/2011.
//  Copyright 2011 MKE Computing Ltd. All rights reserved.
//
// Based on information found here:
// http://whiskybiscuit.co.uk/2011/tutorial-review-prompt/
#import <UIKit/UIKit.h>

enum MKEReviewRequesterResult {
    MKEReviewRequesterRated,
    MKEReviewRequesterDelayed,
    MKEReviewRequesterDisabled
};

typedef enum MKEReviewRequesterResult MKEReviewRequesterResult;

@protocol MKEReviewRequesterDelegate <NSObject>

- (void) reviewRequesterDidFinishWithResult:(MKEReviewRequesterResult)result;

@end

@interface MKEReviewRequester : NSObject {
}

+ (void) setupWithAppLink:(NSString*)userAppLink 
               appVersion:(CGFloat)userAppVersion 
      minimumTimeInterval:(NSTimeInterval)userMinTimeInterval 
          minimumRunCount:(NSInteger)userMinRunCount 
            runCountDelay:(NSInteger)userRunCountDelay
                 delegate:(id<MKEReviewRequesterDelegate>)userDelegate;

+ (void) rateApp;

+ (void) delayRating;

+ (void) disableRating;

+ (void) increaseRunCount;

+ (BOOL) checkAndShowPrompt;


@end

