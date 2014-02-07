//
//  WTClockView.h
//  ClockAnimation
//
//  Created by Duncan Champney on 2/6/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct
{
  CGFloat hourHandAngle;
  CGFloat minuteHandAngle;
  CGFloat secondHandAngle;
  
} handAngles;



@interface WTClockView : UIView
{
  __weak NSTimer *clockTimer;
  NSCalendar *calendar;
  
  UILabel *timeTextLabel;
  NSDateFormatter *timeFormatter;
  handAngles oldHandAngles;
  id enterBackgroundNotification;
  id enterForegroundNotification;
}


@property (nonatomic, weak)  IBOutlet UIImageView *hourHand;
@property (nonatomic, weak)  IBOutlet UIImageView *minuteHand;
@property (nonatomic, weak)  IBOutlet UIImageView *secondHand;

@property (nonatomic, assign) BOOL running;

- (void) setTimeToDate: (NSDate *)date animated: (BOOL) animated;
- (void) setTimeToNowAnimated: (BOOL) animated;
- (void) setTimeToTenTen;
- (void) setTimeWithTimeString: (NSString *) timeString;;

@end
