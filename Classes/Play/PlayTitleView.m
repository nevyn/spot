//
//  PlayTitleView.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlayTitleView.h"
#import "SpotSession.h"


@implementation PlayTitleView

@synthesize artistLabel, trackLabel, albumLabel, delegate;


/*
-(void)didTouchLabel:(id)sender;
{
  SpotPlayer *player = [SpotSession defaultSession].player;
  if(sender == artistLabel){
    [self.navigationController showArtist:player.currentTrack.artist];
  } else if(sender == albumLabel){
    [self.navigationController showAlbum:player.currentTrack.album];
  }
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
  NSLog(@"touchy");
  if([self.delegate respondsToSelector:@selector(titleViewTouched:)]){
    [self.delegate performSelector:@selector(titleViewTouched:) withObject:self];
  }
}

@end
