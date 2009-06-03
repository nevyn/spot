//
//  SpotPlayer.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotPlayer.h"

#import "SpotSession.h"
#import "SpotTrack.h"
#import "SpotPlaylist.h"
#import "SpotAlbum.h"
/*
@interface PlayerAction : NSObject{
  SpotPlayer *player;
}
+(id)actionWithPlayer:(SpotPlayer*)p;
-(id)initWithPlayer:(SpotPlayer*)p;
-(void)run;
-(void)startCallback;
-(void)stopCallback;
@end

@implementation PlayerAction
+(id)actionWithPlayer:(SpotPlayer*)p;{
  return [[[PlayerAction alloc] initWithPlayer:p] autorelease];
}
-(id)initWithPlayer:(SpotPlayer*)p;
{
  if(![super init])return nil;
  player = p;
  [self run];
  return self;
}
@end


@interface NextAction : PlayerAction{
  
}
@end

@implementation NextAction
-(void)run;{
  [player stop];
}
-(void)startCallback;{
  
}
-(void)stopCallback;{
  [player ]
}
@end

*/

//callback from audioqueue.c
void audioqueue_global_statechange_callback_hack(int state){
  SpotSession *ss = [SpotSession defaultSession];
  NSLog(@"audioqueue_global_statechange_callback_hack %d", state);
  if(state == 0){
    //stopped
    [ss.player performSelectorOnMainThread:@selector(gotPlaybackDidStop) withObject:nil waitUntilDone:NO];
  } else if(state == 1){
    //played
    [ss.player performSelectorOnMainThread:@selector(gotPlaybackDidStart) withObject:nil waitUntilDone:NO];
  }
}


@interface SpotPlayer (Private)

-(void)setState:(PlayerState)newState;

-(void)setCurrentPlaylist:(SpotPlaylist*)pl;
-(void)setCurrentTrack:(SpotTrack*)track;
-(void)trackDidStart;
-(void)trackDidEnd;

//audio device control
-(BOOL)startPlayback;
-(BOOL)stopPlayback;
-(BOOL)pausePlayback;

//callbacks
-(void)gotPlaybackDidStart;
-(void)gotPlaybackDidStop;

//Notifications
-(void)notifyPlaybackWillStart;
-(void)notifyPlaybackDidStart;
-(void)notifyPlaybackWillStop;
-(void)notifyPlaybackDidStop;
-(void)notifyPlaybackDidPause;
-(void)notifyTrackDidStart;
-(void)notifyTrackDidEnd;

@end

//TODO: While waiting for despotify to start or stop playback we need to queue other commands
@implementation SpotPlayer

-(id)initWithSession:(SpotSession*)session_;
{
  if( ! [super init] ) return nil;
  
  session = session_; //probably singleton, dont retain
  
  playModeRepeat = YES;
  playModeShuffle = NO;
  playModeAutoNext = YES;
  
  return self;
}

-(void)dealloc;
{
  [currentTrack dealloc];
  [currentPlaylist dealloc];
  [super dealloc];
}

-(void)setState:(PlayerState)newState;
{
  previousState = currentState;
  currentState = newState;
}

#pragma mark Audio device control

-(BOOL)startPlayback;
{
  NSLog(@"startPlayback. state: %d was: %d want: %d", currentState, previousState, wantState);
  if(self.currentTrack){
    wantState = PLAYER_PLAYING;
    
    if(currentState == PLAYER_PAUSED){
      NSLog(@"calling de_resume");
      despotify_resume(session.session);
      //TODO: Make sure callback is handeled one way or another
      [self setState:PLAYER_PLAYING];
      [self notifyPlaybackDidStart];
    }
    if(currentState == PLAYER_STOPPED || currentState == PLAYER_CHANGE_TRACK){
      NSLog(@"calling de_play");
      [session playTrack:self.currentTrack];
//      despotify_play(session.session, self.currentTrack.de_track, NO); 
    }
  }
  return YES; 
}

-(void)playbackDidStart;
{

}

-(BOOL)stopPlayback;
{
  NSLog(@"stopPlayback. state: %d was: %d want: %d", currentState, previousState, wantState);
  if(currentState == PLAYER_PLAYING || currentState == PLAYER_PAUSED || PLAYER_CHANGE_TRACK){
    wantState = PLAYER_STOPPED;
    NSLog(@"calling de_stop");
    despotify_stop(session.session);  
  }
  return YES;
}

-(void)playbackDidStop;
{

}


-(BOOL)pausePlayback;
{
  NSLog(@"pausePlayback. state: %d was: %d want: %d", currentState, previousState, wantState);
  if(currentState == PLAYER_PLAYING){
    wantState = PLAYER_PAUSED;
    despotify_pause(session.session);
    [self setState:PLAYER_PAUSED];
  }
  return YES;
}


#pragma mark Actions

-(BOOL)playTrack:(SpotTrack*)track rewind:(BOOL)rewind;
{
  NSLog(@"playTrack. state: %d was: %d want: %d", currentState, previousState, wantState);

  SpotPlaylist *playlist = currentPlaylist;
  
  if(!playlist || ![currentPlaylist.tracks containsObject:track]){
    SpotAlbum *album = track.album;
    if(!album)NSLog(@"track has no album info");
    playlist = track.album.playlist;
  }
  
  return [self playPlaylist:playlist firstTrack:track];
}

-(BOOL)playPlaylist:(SpotPlaylist*)playlist firstTrack:(SpotTrack*)track;
{
  NSLog(@"playPlaylist. state: %d was: %d want: %d", currentState, previousState, wantState);
  
  if(!playlist)
    [NSException raise:@"playPlaylist" format:@"Playlist is nil!"];
  if(!track) 
    track = [playlist.tracks objectAtIndex:0];
  
  [self setCurrentPlaylist:playlist];
  [self setCurrentTrack:track];

  if(currentState == PLAYER_PLAYING || currentState == PLAYER_PAUSED){
    onStop = @selector(play);
    [self stopPlayback];
  }
  if(currentState == PLAYER_STOPPED){
    [self play];
  }
    
  return YES;
}

-(BOOL)pause;
{
  NSLog(@"pause. state: %d was: %d want: %d", currentState, previousState, wantState);
  [self pausePlayback];
  [self notifyPlaybackDidPause];
  return NO;
}

-(BOOL)play;
{
  NSLog(@"play. state: %d was: %d want: %d", currentState, previousState, wantState);
  onStart = @selector(notifyPlaybackDidStart);
  [self startPlayback];
  return YES;
}

-(BOOL)stop;
{
  NSLog(@"stop. state: %d was: %d want: %d", currentState, previousState, wantState);
  onStop = @selector(notifyPlaybackDidStop);
  [self stopPlayback];
  return YES;
}

-(BOOL)next;
{
  NSLog(@"next. state: %d was: %d want: %d", currentState, previousState, wantState);
  //handle as playback never stopped
  
  if(currentState == PLAYER_PLAYING || currentState == PLAYER_PAUSED){
    NSLog(@"next needs to stop playback");
    wantState = currentState;
    [self setState:PLAYER_CHANGE_TRACK];
    //stop and call me again when done
    onStop = @selector(next);
    [self stopPlayback];
  } else if(currentState == PLAYER_STOPPED) {
    NSLog(@"next changes the current track");
    SpotTrack *next = [currentPlaylist trackAfter:self.currentTrack];
    if(!next && playModeRepeat){
      next = [currentPlaylist trackAtPosition:0];
    } else {
      //TODO: set correct mode
    }
    [self setCurrentTrack:next];
    if(previousState == PLAYER_PLAYING || previousState == PLAYER_CHANGE_TRACK){
      NSLog(@"next calls startPlayback");
      onStart = @selector(notifyTrackDidStart);
      [self startPlayback];
    }
  } else {
    NSLog(@"next can not continue with this state: %d", currentState);
  }
  return YES;
}

-(BOOL)previous;
{
  NSLog(@"previous. state: %d was: %d want: %d", currentState, previousState, wantState);
  //handle as playback never stopped
  
  if(currentState == PLAYER_PLAYING || currentState == PLAYER_PAUSED){
    NSLog(@"previous needs to stop playback");
    wantState = currentState;
    [self setState:PLAYER_CHANGE_TRACK];
    //stop and call me again when done
    onStop = @selector(previous);
    [self stopPlayback];
  } else if(currentState == PLAYER_STOPPED) {
    NSLog(@"previous changes the current track");
    SpotTrack *previous = [currentPlaylist trackBefore:self.currentTrack];
    if(!previous && playModeRepeat){
      previous = [currentPlaylist trackAtPosition:[currentPlaylist.tracks count]-1];
    } else {
      //TODO: set correct mode
    }
    [self setCurrentTrack:previous];
    if(previousState == PLAYER_PLAYING || previousState == PLAYER_CHANGE_TRACK){
      NSLog(@"previous calls startPlayback");
      onStart = @selector(notifyTrackDidStart);
      [self startPlayback];
    }
  } else {
    NSLog(@"previous can not continue with this state: %d", currentState);
  }
  return YES;
}

#pragma mark Internal callbacks

-(void)trackDidEnd;
{
  NSLog(@"trackDidEnd");
  wantState = currentState;
  if(playModeAutoNext){
    NSLog(@"trackDidEnd autoplay next");
    [self next];
  }
  [self notifyTrackDidEnd];
}

#pragma mark Callbacks

-(void)gotPlaybackDidStart;
{
  NSLog(@"gotPlaybackDidStart. state: %d was: %d want: %d", currentState, previousState, wantState);
  [self setState:PLAYER_PLAYING];
  
  if(wantState == PLAYER_PLAYING)
    [self playbackDidStart];
  if(onStart){
    NSLog(@"Performing selector onStart %s", onStart);
    [self performSelector:onStart];
  } else {
    NSLog(@"No selector onStart. Assuming trackDidStart. state: %d was: %d want: %d", currentState, previousState, wantState);
    [self notifyTrackDidStart];
  }
  onStart = nil;
}

-(void)gotPlaybackDidStop;
{
  NSLog(@"gotPlaybackDidStop. state: %d was: %d want: %d", currentState, previousState, wantState);
  [self setState:PLAYER_STOPPED];
  
  if(previousState == PLAYER_CHANGE_TRACK){
    NSLog(@"gotPlaybackDidStop going to change track.");
    [self performSelector:onStop];
    onStop = nil;
  } else if(wantState == PLAYER_STOPPED) {
    [self playbackDidStop];
  }
  
  if(onStop){
    NSLog(@"Performing selector onStop %s", onStop);
    [self performSelector:onStop];
  } else if(previousState == PLAYER_PLAYING) {
    NSLog(@"gotPlaybackDidStop previousState is PLAYING. sending trackDidEnd. state: %d was: %d want: %d", currentState, previousState, wantState);
    //getting a stop while playing == we ran out of stuff to play
    [self trackDidEnd];
  }
  onStop = nil;
}

#pragma mark Notifications

//send notifications
-(void)postNotification:(NSString *)name info:(NSDictionary*)info;
{
  NSLog(@"Notifying %@", name);
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:name object:self userInfo:info]];
}
-(void)notifyPlaybackWillStart;
{
  NSString *name = @"playbackWillstart";
  NSDictionary *object = nil;
  [self postNotification:name info:object];
}

-(void)notifyPlaybackDidStart;
{
  //playback started because you pressed the play button
  NSString *name = @"playbackDidStart";
  NSDictionary *object = nil;
  [self postNotification:name info:object];
}

-(void)notifyPlaybackWillStop;
{
  NSString *name = @"playbackWillStop";
  NSDictionary *object = nil;
  [self postNotification:name info:object];
}

-(void)notifyPlaybackDidStop;
{
  //playback stopped because you pressed the stop button
  NSString *name = @"playbackDidStop";
  NSDictionary *object = nil;
  [self postNotification:name info:object];
}

-(void)notifyPlaybackDidPause;
{
  NSString *name = @"playbackDidPause";
  NSDictionary *object = nil;
  [self postNotification:name info:object];
}

-(void)notifyTrackDidStart;
{
  //playback started because playback started on a new song
  NSString *name = @"trackDidStart";
  NSDictionary *object = nil;
  [self postNotification:name info:object];
}

-(void)notifyTrackDidEnd;
{
  //playback stopped because there was no more data to play
  NSString *name = @"trackDidEnd";
  NSDictionary *object = nil;
  [self postNotification:name info:object];
}

#pragma mark Old stuff

-(void)setCurrentPlaylist:(SpotPlaylist*)pl;
{
  if(currentPlaylist != pl){
    [pl retain];
    [currentPlaylist release];
    currentPlaylist = pl;

    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"playlistDidChange" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:currentPlaylist, @"playlist", nil]]];
  }
}

-(void)setCurrentTrack:(SpotTrack*)track;
{
  if(currentTrack != track){
    [track retain];
    [currentTrack release];

    currentTrack = track;
  
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"trackDidChange" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:track, @"track", nil]]];
  }
}

#pragma mark Property accessors
@synthesize currentTrack, currentPlaylist;

-(BOOL)isPlaying;
{
  //TODO: might want to verify somehow
  return (currentState == PLAYER_PLAYING);
}


@end
