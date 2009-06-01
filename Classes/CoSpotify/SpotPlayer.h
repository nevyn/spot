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

typedef enum {
  PLAYER_STOPPED = 0,
  PLAYER_PLAYING = 1,
  PLAYER_PAUSED  = 2,
  PLAYER_CHANGE_TRACK = 3 //change track while playing
} PlayerState;

@interface SpotPlayer : NSObject {
  SpotSession *session;
  
  SpotTrack *currentTrack;
  SpotPlaylist *currentPlaylist;
  
  PlayerState previousState;
  PlayerState currentState;
  PlayerState wantState; //To remind us what we intended state to become, once the callback comes.
  
  SEL onStop;
  SEL onStart;
  
  BOOL playModeRepeat; //play from beginning when end of playlist
  BOOL playModeShuffle; //select random next song
  BOOL playModeAutoNext; //automatically play next song. NO = play single track and stop
}

-(id)initWithSession:(SpotSession*)session;

//helpers that sett currentTrack before playing
-(BOOL)playTrack:(SpotTrack*)track rewind:(BOOL)rewind;
-(BOOL)playPlaylist:(SpotPlaylist*)playlist firstTrack:(SpotTrack*)track;

-(BOOL)play;
-(BOOL)stop;
-(BOOL)pause;
-(BOOL)next;
-(BOOL)previous;

@property (readonly, retain) SpotTrack *currentTrack;
@property (readonly, retain) SpotPlaylist *currentPlaylist;
@property (readonly) BOOL isPlaying;


@end
