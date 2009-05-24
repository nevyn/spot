//
//  LoggingInController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoggingInController : UIViewController
{
	NSString *username;
	NSString *password;
	IBOutlet UILabel *error;
	IBOutlet UIButton *tryAgain;
	IBOutlet UIActivityIndicatorView *spinner;
}
@property (retain) NSString *username;
@property (retain) NSString *password;

-(id)initLoggingInAs:(NSString*)name_ password:(NSString*)password_;

-(IBAction)tryAgain;
@end
