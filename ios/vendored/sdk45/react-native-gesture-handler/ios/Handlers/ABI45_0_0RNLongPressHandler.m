//
//  ABI45_0_0RNLongPressHandler.m
//  ABI45_0_0RNGestureHandler
//
//  Created by Krzysztof Magiera on 12/10/2017.
//  Copyright © 2017 Software Mansion. All rights reserved.
//

#import "ABI45_0_0RNLongPressHandler.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#import <ABI45_0_0React/ABI45_0_0RCTConvert.h>

#import <mach/mach_time.h>

@interface ABI45_0_0RNBetterLongPressGestureRecognizer : UILongPressGestureRecognizer {
  uint64_t startTime;
  uint64_t previousTime;
}

- (id)initWithGestureHandler:(ABI45_0_0RNGestureHandler*)gestureHandler;
- (void)handleGesture:(UIGestureRecognizer *)recognizer;
- (NSUInteger) getDuration;

@end

@implementation ABI45_0_0RNBetterLongPressGestureRecognizer {
  __weak ABI45_0_0RNGestureHandler *_gestureHandler;
  CGPoint _initPosition;
}

- (id)initWithGestureHandler:(ABI45_0_0RNGestureHandler*)gestureHandler
{
  if ((self = [super initWithTarget:self action:@selector(handleGesture:)])) {
    _gestureHandler = gestureHandler;
  }
  return self;
}

- (void)handleGesture:(UIGestureRecognizer *)recognizer
{
  previousTime = mach_absolute_time();
  [_gestureHandler handleGesture:recognizer];
}

- (void)triggerAction
{
  [self handleGesture:self];
}

- (CGPoint)translationInView
{
  CGPoint currentPosition = [self locationInView:self.view];
  return CGPointMake(currentPosition.x - _initPosition.x, currentPosition.y - _initPosition.y);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];
  [_gestureHandler.pointerTracker touchesBegan:touches withEvent:event];

  _initPosition = [self locationInView:self.view];
  startTime = mach_absolute_time();
  [_gestureHandler reset];
  [self triggerAction];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
  [_gestureHandler.pointerTracker touchesMoved:touches withEvent:event];
  
  CGPoint trans = [self translationInView];
  if ((_gestureHandler.shouldCancelWhenOutside && ![_gestureHandler containsPointInView])
      || (TEST_MAX_IF_NOT_NAN(fabs(trans.y * trans.y + trans.x + trans.x), self.allowableMovement * self.allowableMovement))) {
    self.enabled = NO;
    self.enabled = YES;
  }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  [_gestureHandler.pointerTracker touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];
  [_gestureHandler.pointerTracker touchesCancelled:touches withEvent:event];
}

- (void)reset
{
  if (self.state == UIGestureRecognizerStateFailed) {
    [self triggerAction];
  }
  
  [_gestureHandler.pointerTracker reset];
  
  [super reset];
}

- (NSUInteger)getDuration
{
  static mach_timebase_info_data_t sTimebaseInfo;
  
  if (sTimebaseInfo.denom == 0) {
    mach_timebase_info(&sTimebaseInfo);
  }
  
  return (NSUInteger)(((previousTime - startTime) * sTimebaseInfo.numer / (sTimebaseInfo.denom * 1000000)));
}

@end


@implementation ABI45_0_0RNLongPressGestureHandler

- (instancetype)initWithTag:(NSNumber *)tag
{
  if ((self = [super initWithTag:tag])) {
    _recognizer = [[ABI45_0_0RNBetterLongPressGestureRecognizer alloc] initWithGestureHandler:self];
  }
  return self;
}

- (void)resetConfig
{
  [super resetConfig];
  UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer *)_recognizer;
  
  recognizer.minimumPressDuration = 0.5;
  recognizer.allowableMovement = 10;
}

- (void)configure:(NSDictionary *)config
{
  [super configure:config];
  UILongPressGestureRecognizer *recognizer = (UILongPressGestureRecognizer *)_recognizer;
  
  id prop = config[@"minDurationMs"];
  if (prop != nil) {
    recognizer.minimumPressDuration = [ABI45_0_0RCTConvert CGFloat:prop] / 1000.0;
  }
  
  prop = config[@"maxDist"];
  if (prop != nil) {
    recognizer.allowableMovement = [ABI45_0_0RCTConvert CGFloat:prop];
  }
}

- (ABI45_0_0RNGestureHandlerState)state
{
  // For long press recognizer we treat "Began" state as "active"
  // as it changes its state to "Began" as soon as the the minimum
  // hold duration timeout is reached, whereas state "Changed" is
  // only set after "Began" phase if there is some movement.
  if (_recognizer.state == UIGestureRecognizerStateBegan) {
    return ABI45_0_0RNGestureHandlerStateActive;
  }
  return [super state];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  //same as TapGH, this needs to be unified when all handlers are updated
  ABI45_0_0RNGestureHandlerState savedState = _lastState;
  BOOL shouldBegin = [super gestureRecognizerShouldBegin:gestureRecognizer];
  _lastState = savedState;
  
  return shouldBegin;
}

- (ABI45_0_0RNGestureHandlerEventExtraData *)eventExtraData:(UIGestureRecognizer *)recognizer
{
    return [ABI45_0_0RNGestureHandlerEventExtraData
            forPosition:[recognizer locationInView:recognizer.view]
            withAbsolutePosition:[recognizer locationInView:recognizer.view.window]
            withNumberOfTouches:recognizer.numberOfTouches
            withDuration:[(ABI45_0_0RNBetterLongPressGestureRecognizer*)recognizer getDuration]];
}
@end

