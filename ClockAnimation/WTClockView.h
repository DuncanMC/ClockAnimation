//
//  WTClockView.h
//  ClockAnimation
//
//  Created by Duncan Champney on 2/6/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WTClockView : UIView
{
  __weak NSTimer *clockTimer;
  NSCalendar *calendar;
  
//  CATextLayer *timeTextLayer;
  UILabel *timeTextLabel;
  NSDateFormatter *timeFormatter;
}

typedef struct
{
  CGFloat hourHandAngle;
  CGFloat minuteHandAngle;
  CGFloat secondHandAngle;
  
} handAngles;


@property (nonatomic, weak)  IBOutlet UIImageView *hourHand;
@property (nonatomic, weak)  IBOutlet UIImageView *minuteHand;
@property (nonatomic, weak)  IBOutlet UIImageView *secondHand;

@property (nonatomic, assign) BOOL running;
@end
