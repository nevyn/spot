//
//  FlipView.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FlipView.h"


@implementation FlipView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}

-(void)flip;
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:nil context:context];
  [UIView setAnimationDuration: 0.8];
  [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
  [self exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
  [[[self subviews] objectAtIndex:1] setHidden:NO];
  [[[self subviews] objectAtIndex:0] setHidden:YES];
  [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
  swipeStart = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
  
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
  CGPoint swipeEnd = [[touches anyObject] locationInView:self];
  float x = abs(swipeEnd.x - swipeStart.x);
  float y = abs(swipeEnd.y - swipeStart.y);
  float l = sqrt(x*x + y*y);
  x /= l;
  y /= l;
  if(x > 0.95 && l > 130)
    [self flip];
  NSLog(@"sweep: %f, %f  %f", x, y, l);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
  
}


@end
