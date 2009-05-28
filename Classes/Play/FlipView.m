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



@end
