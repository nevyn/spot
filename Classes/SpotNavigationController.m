//
//  SpotNavigationController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotNavigationController.h"


@implementation SpotNavigationController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) return nil;
	
	NSLog(@"Here's a spot navigation controller");
	
	return self;
}
@end
