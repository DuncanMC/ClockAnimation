//
//  ViewController.h
//  ClockAnimation
//
//  Created by Duncan Champney on 2/6/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTClockView.h"

@interface ViewController : UIViewController
{
  __weak IBOutlet WTClockView *theClockView;
  __weak IBOutlet UIButton *startButton;
}
- (IBAction)handleStartButton:(id)sender;

@end
