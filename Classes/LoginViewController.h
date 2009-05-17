//
//  LoginViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController {
	IBOutlet UITextField *username;
	IBOutlet UITextField *password;
}
-(id)init;

-(IBAction)login;
@end
