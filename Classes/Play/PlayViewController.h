//
//  PlayViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotPlaylist.h"

@interface PlayViewController : UIViewController {
	SpotPlaylist *currentPlaylist;
	SpotTrack *currentTrack;
	
	IBOutlet UIButton *playPauseButton;
	IBOutlet UILabel *artistLabel;
	IBOutlet UILabel *trackLabel;
	IBOutlet UILabel *albumLabel;
	
	IBOutlet UIImageView *albumArt;
}
+defaultController;

-(void)playPlaylist:(SpotPlaylist*)playlist;
-(void)playPlaylist:(SpotPlaylist*)playlist startingAtTrack:(SpotTrack*)track;
-(void)playTrack:(SpotTrack*)track;

-(IBAction)togglePlaying:(id)sender;
-(IBAction)pause;
-(IBAction)play;
-(IBAction)next;
-(IBAction)prev;

//-(IBAction)takeLooping:(id)sender;
//-(IBAction)takeShuffling:(id)sender;

@property (readonly, retain, nonatomic) SpotPlaylist *currentPlaylist;
@property (readonly, retain, nonatomic) SpotTrack *currentTrack;
@property (readonly, nonatomic) BOOL playing;
@end
