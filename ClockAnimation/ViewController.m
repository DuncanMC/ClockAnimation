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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleStartButton:(id)sender
{
  theClockView.running = !theClockView.running;
  
  NSString *buttonTitle;
  
  if (theClockView.running)
    buttonTitle = NSLocalizedString( @"Stop", nil);
  else
    buttonTitle  =  NSLocalizedString( @"Start", nil);
  
  [startButton setTitle: buttonTitle forState: UIControlStateNormal];

}
@end
