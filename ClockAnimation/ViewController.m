//
//  ViewController.m
//  ClockAnimation
//
//  Created by Duncan Champney on 2/6/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+performBlockAfterDelay.h"

@interface ViewController ()

@end

@implementation ViewController


//-----------------------------------------------------------------------------------------------------------
#pragma mark - VC life cycle methods
//-----------------------------------------------------------------------------------------------------------
- (void) setClockRunningState: (BOOL) newState;
{
  theClockView.running = newState;
  NSString *buttonTitle;
  
  if (newState)
    buttonTitle = NSLocalizedString( @"Stop", nil);
  else
    buttonTitle  =  NSLocalizedString( @"Run", nil);
  
  [startButton setTitle: buttonTitle forState: UIControlStateNormal];
}


- (void) viewWillAppear:(BOOL)animated;
{
//  [theClockView setTimeWithTimeString: @"9:14:30"];
  [self setClockRunningState: YES];
  
//  UIGraphicsBeginImageContextWithOptions(theClockView.bounds.size, NO, 0.0);
//
//  [theClockView drawViewHierarchyInRect:theClockView.bounds afterScreenUpdates:NO];
//  UIImage *clockImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();

}

//-----------------------------------------------------------------------------------------------------------
#pragma mark - IBAction methods
//-----------------------------------------------------------------------------------------------------------

- (IBAction)handleStartButton:(id)sender
{
  [self setClockRunningState: !theClockView.running];
}

@end
