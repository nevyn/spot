//
//  ProfileViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-19.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProfileViewController : UIViewController {
	IBOutlet UILabel *username;
	IBOutlet UILabel *country;
	IBOutlet UILabel *accountType;
	IBOutlet UILabel *expiry;
	IBOutlet UILabel *server;
	IBOutlet UILabel *lastServerContact;
  
  IBOutlet UISwitch *autoLoginSwitch;
  IBOutlet UISwitch *coversInSearchSwitch;
  IBOutlet UISwitch *experimentalSwitch;
}
-(id)init;

-(IBAction)toggleAutoLogin:(UISwitch*)sender;
-(IBAction)toggleCovers:(UISwitch*)sender;
-(IBAction)toggleExperimental:(UISwitch*)sender;
@end
