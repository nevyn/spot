//
//  SpotPlayer.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpotSession;
@class SpotTrack;
@class SpotPlaylist;

@interface SpotPlayer : NSObject {
  SpotSession *session;
  
  SpotTrack *currentTrack;
  SpotPlaylist *currentPlaylist;
  
  BOOL isPlaying;
  BOOL willPlay;
  
  NSMutableArray *queuedCommands;
}

-(id)initWithSession:(SpotSession*)session;

-(BOOL)playTrack:(SpotTrack*)track rewind:(BOOL)rewind;
-(BOOL)playPlaylist:(SpotPlaylist*)playlist firstTrack:(SpotTrack*)track;
-(BOOL)pause;
-(BOOL)play; //resume current track
-(BOOL)stop;
-(BOOL)playNextTrack;
-(BOOL)playPreviousTrack;

@property (readonly, retain) SpotTrack *currentTrack;
@property (readonly, retain) SpotPlaylist *currentPlaylist;
@property (readonly) BOOL isPlaying;
@property (readonly) SpotTrack *savedTrack;

@end
