//
//  WTClockView.m
//  ClockAnimation
//
//  Created by Duncan Champney on 2/6/14.
//  Copyright (c) 2014 WareTo. All rights reserved.
//

#import "WTClockView.h"
#import "NSObject+performBlockAfterDelay.h"

@implementation WTClockView

//-----------------------------------------------------------------------------------------------------------
#pragma mark - object lifecycle methods
//-----------------------------------------------------------------------------------------------------------
- (void) doInitSetup;
{
  enterForegroundNotification = [[NSNotificationCenter defaultCenter] addObserverForName: UIApplicationWillEnterForegroundNotification
                                 
                                                                                  object: nil
                                                                                   queue: nil
                                                                              usingBlock: ^(NSNotification *note)
                                 
                                 {
                                   //NSLog(@"Returning from background");
                                   [self setTimeToNowAnimated: NO];
                                   if (self.running)
                                     self.running = YES;
                                 }
                                 ];
  enterBackgroundNotification = [[NSNotificationCenter defaultCenter] addObserverForName: UIApplicationDidEnterBackgroundNotification
                                 
                                                                                  object: nil
                                                                                   queue: nil
                                                                              usingBlock: ^(NSNotification *note)
                                 
                                 {
                                   //NSLog(@"Exiting to background");
                                   [clockTimer invalidate];
                                 }
                                 ];
}

//-----------------------------------------------------------------------------------------------------------

- (id) initWithCoder:(NSCoder *)aDecoder;
{
  self = [super initWithCoder: aDecoder];
  if (self)
    [self doInitSetup];
  return self;
}

//-----------------------------------------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
      [self doInitSetup];
    }

    return self;
}

//-----------------------------------------------------------------------------------------------------------

//This custom view type is intended to be a "drop-in." It automatically adds subviews and layers
//to display the clock face

- (void) awakeFromNib;
{
  
  //Create a layer for a circle outline of the clock face.
  CALayer *circle = [CALayer layer];
  
  //Make the circle fit in a square area (don't include the space at the bottom for the digital time)
  
  CGRect bounds = self.layer.bounds;
  bounds.size.height = self.layer.bounds.size.width;
  circle.bounds = bounds;
  
  circle.cornerRadius = bounds.size.width/2;
  circle.borderWidth = 1;
  circle.borderColor = [UIColor lightGrayColor].CGColor;
  circle.backgroundColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 183/255.0 alpha: 1.0].CGColor;
  CGPoint position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
  position = [self.superview convertPoint: position fromView: self];
  circle.position = position;
  [self.layer.superlayer insertSublayer: circle  below:self.layer];
  
  UIImage *wareToImage = [UIImage imageNamed: @"wareto logo 120x92"];
  
  CALayer *imageLayer = [CALayer layer];
  CGRect imageBounds = CGRectMake(0,0, wareToImage.size.width, wareToImage.size.height);
  position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) - 75);

  imageLayer.bounds = imageBounds;
  imageLayer.position = position;
  imageLayer.contents = (id) wareToImage.CGImage;
  [circle addSublayer: imageLayer];
  
  

  
  //Create an array of our labels for the clock face.
  NSArray *numbers = @[@12, @1, @2, @3, @4, @5, @6, @7, @8, @9, @10, @11];
  
  //Calculate the radius of the circle where we put our time labels.
  CGFloat radius = circle.bounds.size.width/2 - 10;
  
  //Loop through the 4 time values.
  [numbers enumerateObjectsUsingBlock:
   ^(NSNumber *aNumber, NSUInteger  index, BOOL *stop)
   {
     //Calculate angles in pi/2 steps (quarter circles)
     CGFloat angle = ((NSInteger)index) * M_PI * 2/ [numbers count] - M_PI_2;
     
     //Calculate the x/y position for this label based on the angle
     CGFloat x = round(cosf(angle) * radius) + CGRectGetMidX(bounds);
     CGFloat y = round(sinf(angle) * radius) + CGRectGetMidY(bounds);
     CGPoint center = CGPointMake (x, y);
     
     
     //Create a label.
     UILabel *aLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 25, 18)];
     
     //Set up it's font, color, position, center alignment, etc.
     aLabel.font = [UIFont systemFontOfSize: 14];
     aLabel.textColor = [UIColor blackColor];
     aLabel.center = center;
     aLabel.textAlignment = NSTextAlignmentCenter;

     aLabel.text = [NSString stringWithFormat: @"%d", [aNumber integerValue]];

     //Finally, add the label to the clock view.
     [self addSubview: aLabel];

   }
   ];
  
  //Create a label for a
  //digital time at the bottom of the clock face.
  timeTextLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 28)];
  timeTextLabel.textAlignment = NSTextAlignmentCenter;
  timeTextLabel.font = [UIFont systemFontOfSize: 22];
  timeTextLabel.center = CGPointMake( CGRectGetMidX(self.layer.bounds), self.layer.bounds.size.height- (timeTextLabel.bounds.size.height/2 +3)  );
  timeTextLabel.layer.borderWidth = 1;
  timeTextLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
  
  [self addSubview: timeTextLabel];

  [self setTimeToNowAnimated: NO];
  
  _hourHand.alpha = .5;
  _minuteHand.alpha = .5;
  _secondHand.alpha = .5;
}

//-----------------------------------------------------------------------------------------------------------
- (void) dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver: enterBackgroundNotification];
  enterBackgroundNotification = nil;

  [[NSNotificationCenter defaultCenter] removeObserver: enterForegroundNotification];
  enterForegroundNotification = nil;
}
//-----------------------------------------------------------------------------------------------------------
#pragma mark - property  methods
//-----------------------------------------------------------------------------------------------------------

- (void) setRunning:(BOOL)running
{
  _running = running;

  //Kill the previous timer. It's set to weak, so it will nil automatically.
  if (clockTimer)
    [clockTimer invalidate];
  
  if (running)
  {
    //Figure out the NSTimeInterval for the next even second.
    NSTimeInterval nextSecondInterval = floor([NSDate timeIntervalSinceReferenceDate]) + 1;
    
    //Create an NSTime for that instant in time.
    NSDate *nextSecond = [NSDate dateWithTimeIntervalSinceReferenceDate: nextSecondInterval];
    
    //Create a repeating timer that fires on the next even time interval.
    NSTimer *newTimer = [[NSTimer alloc] initWithFireDate: nextSecond
                                          interval: 1.0 target: self
                                          selector: @selector(displayTime:)
                                          userInfo: nil
                                           repeats: YES];
    clockTimer = newTimer;
    
    //Start the timer running
    [[NSRunLoop mainRunLoop] addTimer: clockTimer
                              forMode: NSRunLoopCommonModes];
    
  }
}

//-----------------------------------------------------------------------------------------------------------
#pragma mark - instace methods
//-----------------------------------------------------------------------------------------------------------

//This is the method invoked by the NSTimer

- (void) displayTime: (NSTimer *)timer
{
  [self setTimeToNowAnimated: YES];
}
//-----------------------------------------------------------------------------------------------------------
//This method animates a clock hand to a specific angle, using a spring animation.

- (void) animateHandView: (UIView *) theHandView
                 toAngle: (CGFloat) newAngle
                duration: (CGFloat) duration;
{
  CGFloat damping = .2;
  if (duration > .4)
    damping = .6;
  //Create the spring animation to the new angle. The clock hands rotate around their geometric centers
  [UIView animateWithDuration: duration
                        delay: 0
       usingSpringWithDamping: damping
        initialSpringVelocity: .8
                      options: 0
                   animations: ^
   {
     theHandView.transform = CGAffineTransformMakeRotation(newAngle);
   }
                   completion: nil
   ];
}

//-----------------------------------------------------------------------------------------------------------
//Figure out angles for the hour, minute, and second hands based on the current time.

- (handAngles) calculateHandAnglesForDate: (NSDate *) date;
{
  handAngles result;
  
  //Lazily create a calenadar object;
  if (!calendar)   //NSGregorianCalendar
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
  
  //Ask our calendar for the current hour/minute/second
  NSDateComponents *timeComponents = [calendar components: NSHourCalendarUnit + NSMinuteCalendarUnit + NSSecondCalendarUnit fromDate: date];
  NSInteger hour = timeComponents.hour %12;
  NSInteger minute = timeComponents.minute;
  NSInteger second = timeComponents.second;
  
  //calculate the correct angle for each hand.
  
  //The hour angle is a full circle divided into 12 steps
  CGFloat fractionalHours = (hour+minute/60.0);
  result.hourHandAngle = M_PI * 2 * fractionalHours/12.0;
  
  //The minute angle is 2pi • minutes/60
  result.minuteHandAngle = M_PI * 2 * minute/60.0;
  
  //The seconds angle is 2p • seconds/60
  result.secondHandAngle = M_PI * 2 * second/60.0;
  
  return result;
  
}

//-----------------------------------------------------------------------------------------------------------
//Set the current time to an arbitrary NSDate
//If animated = FALSE, set the hands without animating them.

- (void) setTimeToDate: (NSDate *)date animated: (BOOL) animated;
{
  handAngles theHandAngles = [self calculateHandAnglesForDate: date];
  if (!animated)
  {
    _hourHand.transform = CGAffineTransformMakeRotation(theHandAngles.hourHandAngle);
    _minuteHand.transform = CGAffineTransformMakeRotation(theHandAngles.minuteHandAngle);
    _secondHand.transform = CGAffineTransformMakeRotation(theHandAngles.secondHandAngle);
  }
  else
  {
    CGFloat duration;
    BOOL big_change;
    
    {
      big_change = fabs(theHandAngles.secondHandAngle - oldHandAngles.secondHandAngle) > M_PI_4;
      duration = big_change ? .6 : .3;
      [self animateHandView: _secondHand toAngle: theHandAngles.secondHandAngle duration: duration];
    }
    [self performBlockOnMainQueue: ^
     {
       CGFloat duration;
       BOOL big_change;
       big_change = fabs(theHandAngles.minuteHandAngle - oldHandAngles.minuteHandAngle) > M_PI_4;
       duration = big_change ? .6 : .3;
       [self animateHandView: _minuteHand toAngle: theHandAngles.minuteHandAngle duration: duration];
       
       big_change = fabs(theHandAngles.hourHandAngle - oldHandAngles.hourHandAngle) > M_PI_4;
       duration = big_change ? .6 : .3;
       [self animateHandView: _hourHand toAngle: theHandAngles.hourHandAngle duration: duration];
     }
                       afterDelay: .05];
    
}
  
  oldHandAngles = theHandAngles;
  
  if (!timeFormatter)
  {
    timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"h:mm:ss";
  }
  NSString *timeString = [timeFormatter stringFromDate: date];
  timeTextLabel.text = timeString;
}

//-----------------------------------------------------------------------------------------------------------

//Set the time to the current NSDate.
//If animated = FALSE, set the hands without animating them.

//-----------------------------------------------------------------------------------------------------------

- (void) setTimeToNowAnimated: (BOOL) animated;
{
  [self setTimeToDate: [NSDate date] animated: animated];
}

//-----------------------------------------------------------------------------------------------------------
- (void) setTimeWithTimeString: (NSString *) timeString;
{
  NSDate *date = [timeFormatter dateFromString: timeString];
  [self setTimeToDate: date animated: NO];
}

//-----------------------------------------------------------------------------------------------------------

- (void) setTimeToTenTen;
{
  NSString *tenTenString = @"10:10:30";
  [self setTimeWithTimeString: tenTenString];
  NSDate *tenTen = [timeFormatter dateFromString: tenTenString];
  [self setTimeToDate: tenTen animated: NO];
}
//-----------------------------------------------------------------------------------------------------------


@end
