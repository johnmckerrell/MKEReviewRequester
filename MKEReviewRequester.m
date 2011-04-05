//
//  MKEReviewRequester.m
//  
//
//  Created by John McKerrell on 05/04/2011.
//  Copyright 2011 MKE Computing Ltd. All rights reserved.
//

#import "MKEReviewRequester.h"

@interface MKEReviewRequester_AlertDelegate : NSObject <UIAlertViewDelegate> {
    UIAlertView *_alertView;
}

@property (nonatomic, retain) UIAlertView *alertView;

@end

@implementation MKEReviewRequester_AlertDelegate

@synthesize alertView = _alertView;

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Clicked buttonIndex = %i", buttonIndex);
    if (alertView == self.alertView) {
        // 1 - yes, rate
        // 2 - don't ask
        // 0 - later
        if (buttonIndex == 1) {
            [MKEReviewRequester rateApp];
        } else if (buttonIndex == 0) {
            [MKEReviewRequester delayRating];
        } else {
            // Failing very safe by assuming anything else is "don't ask"
            [MKEReviewRequester disableRating];
        }
    }
}

- (void)dealloc {
    self.alertView = nil;
    
    [super dealloc];
}

@end

@implementation MKEReviewRequester

static NSString *appLink = nil;
static CGFloat appVersion = 0;
static NSTimeInterval minTimeInterval = 0;
static NSInteger minRunCount = 0;
static MKEReviewRequester_AlertDelegate *alertDelegate = nil;
static NSInteger runCountDelay = 0;
static id<MKEReviewRequesterDelegate> delegate = nil;

+ (void) setupWithAppLink:(NSString*)userAppLink 
               appVersion:(CGFloat)userAppVersion 
      minimumTimeInterval:(NSTimeInterval)userMinTimeInterval 
          minimumRunCount:(NSInteger)userMinRunCount 
            runCountDelay:(NSInteger)userRunCountDelay
                 delegate:(id<MKEReviewRequesterDelegate>)userDelegate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (appLink) {
        [appLink release];
    }
    appLink = [userAppLink retain];
    appVersion = userAppVersion;
    minTimeInterval = userMinTimeInterval;
    minRunCount = userMinRunCount;
    runCountDelay = userRunCountDelay;
    delegate = userDelegate;
    
    if (! [defaults objectForKey:@"MKE.appFirstRun"]) {
        [defaults setObject:[NSDate date] forKey:@"MKE.appFirstRun"];
        [defaults setBool:YES forKey:@"MKE.reviewAllowed"];
        [defaults setFloat:appVersion forKey:@"MKE.appVersion"];
        [defaults setBool:NO forKey:@"MKE.appAskedForRating"];
        [defaults setInteger:0 forKey:@"MKE.runCount"];
        [defaults synchronize];
    } else if( [defaults floatForKey:@"MKE.appVersion"] < appVersion) {
        [defaults setObject:[NSDate date] forKey:@"MKE.appFirstRun"];
        [defaults setFloat:appVersion forKey:@"MKE.appVersion"];
        [defaults setBool:NO forKey:@"MKE.appAskedForRating"];
        [defaults setInteger:0 forKey:@"MKE.runCount"];
    }
}

+ (void) rateApp {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"MKE.appAskedForRating"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [alertDelegate release]; alertDelegate = nil;
    [delegate reviewRequesterDidFinishWithResult:MKEReviewRequesterRated];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appLink]];
}

+ (void) delayRating {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int runCount = [defaults integerForKey:@"MKE.runCount"];
    runCount = runCount - runCountDelay;
    [defaults setInteger:runCount forKey:@"MKE.runCount"];
    [[NSUserDefaults standardUserDefaults] synchronize ];
    [alertDelegate release]; alertDelegate = nil;
    [delegate reviewRequesterDidFinishWithResult:MKEReviewRequesterDelayed];
}

+ (void) disableRating {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"MKE.reviewAllowed"];
    [[NSUserDefaults standardUserDefaults] synchronize ];
    [alertDelegate release]; alertDelegate = nil;
    [delegate reviewRequesterDidFinishWithResult:MKEReviewRequesterDisabled];
}

+ (void) increaseRunCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger runCount = [defaults integerForKey:@"MKE.runCount"] + 1;
    [defaults setInteger:runCount forKey:@"MKE.runCount"];
    [defaults synchronize];
}

+ (BOOL) checkAndShowPrompt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if( [defaults boolForKey:@"MKE.appAskedForRating"] == NO 
       && [defaults boolForKey:@"MKE.reviewAllowed"] == YES
       && alertDelegate == nil)
    {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:[defaults objectForKey:@"MKE.appFirstRun"]];
        if (timeInterval >= minTimeInterval
            && [defaults integerForKey:@"MKE.runCount"] >= minRunCount) {
            NSLog(@"Show prompt");
            alertDelegate = [[MKEReviewRequester_AlertDelegate alloc] init];
            // This is retained (by init) and gets released when we handle the alert disappearing
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enjoying this app?", @"")
                                                                message:NSLocalizedString(@"If you're enjoying this version of the app please let us know by reviewing it on the app store", @"") 
                                                               delegate:alertDelegate
                                                      cancelButtonTitle:NSLocalizedString(@"Remind me later", @"")
                                                      otherButtonTitles:NSLocalizedString(@"Yes, rate it!", @""),
                                      NSLocalizedString(@"Don't ask again", @""), nil];
            [alertView show];
            alertDelegate.alertView = alertView;
            [alertView release]; alertView = nil;
            
            return YES;
        }
    }
    return NO;
}

#pragma mark -
#pragma mark Static class methods

+ (id)allocWithZone:(NSZone *)zone {
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return nil;
}

- (id)retain {
    return nil;
}

- (unsigned)retainCount {
    return 0;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return nil;
}


@end

