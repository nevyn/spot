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

@interface SpotPlayer (Private)

-(void)setCurrentPlaylist:(SpotPlaylist*)pl;
-(void)setCurrentTrack:(SpotTrack*)track;

@end


@implementation SpotPlayer

-(id)initWithSession:(SpotSession*)session_;
{
  if( ! [super init] ) return nil;
  
  session = session_;
  
  return self;
}

-(void)playTrack:(SpotTrack*)track rewind:(BOOL)rewind;
{
  if(!track) return;
  //dont do anything if track is playing and we dont want to rewind
  if([self.currentTrack isEqual:track] && !rewind)
    return;

  [self stop];
  
  [self setCurrentTrack:track];
  
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"track" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:track, @"track", nil]]];
  
  [self play];
}

-(void)playPlaylist:(SpotPlaylist*)playlist firstTrack:(SpotTrack*)track;
{
  /*
   set current playlist and play first song
   */
  if(!playlist && !track) return;
  if(!track) track = [playlist.tracks objectAtIndex:0];
  if(!playlist) playlist = track.playlist;
  if(!playlist){
    //Get the playlist for the track's album
    playlist = [[[SpotSession defaultSession] albumById:track.albumId] playlist];
    track = [playlist trackWithId:track.id];
//    playlist = [[[SpotPlaylist alloc] initWithTrack:track] autorelease];
  }
  
  if(![playlist.tracks containsObject:track])
    [NSException raise:NSInvalidArgumentException format:@"The 'track' argument must be in the playlist given"];
  
  [self setCurrentPlaylist:playlist];
  
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"playlist" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:playlist, @"playlist", nil]]];
  
  [self playTrack:track rewind:YES];
}

-(void)pause;
{
  //stop playback
  if(self.isPlaying){
    [UIApplication sharedApplication].idleTimerDisabled = NO; //can sleep while paused
    isPlaying = !despotify_pause([SpotSession defaultSession].session) && isPlaying;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"pause" object:self]];
  }
}

-(void)play;
{
  if(self.isPlaying) return;
  //start playback if we have something to play
  if(self.currentTrack){
    [UIApplication sharedApplication].idleTimerDisabled = YES; //dont sleep while playing music
    //if([self.savedTrack isEqual:self.currentTrack])
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"willplay" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:currentPlaylist, @"playlist", currentTrack, @"track", nil]]];
    if([self.savedTrack isEqual:self.currentTrack])
      isPlaying = despotify_resume([SpotSession defaultSession].session);
    else
      isPlaying = despotify_play([SpotSession defaultSession].session, self.currentTrack.track, YES);
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"play" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:currentPlaylist, @"playlist", currentTrack, @"track", nil]]];
  }
}

-(void)stop;
{
  if(self.isPlaying){
    [UIApplication sharedApplication].idleTimerDisabled = NO; //can sleep while not playing
    isPlaying = !despotify_pause([SpotSession defaultSession].session) && isPlaying;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"stop" object:self]];
  }
}

-(void)playNextTrack;
{
  [self playTrack:[currentPlaylist trackAfter:self.currentTrack] rewind:NO];
}

-(void)playPreviousTrack;
{
  [self playTrack:[currentPlaylist trackBefore:self.currentTrack] rewind:NO];
}

#pragma mark Private
-(void)setCurrentPlaylist:(SpotPlaylist*)pl;
{
  [pl retain];
  [currentPlaylist release];
  currentPlaylist = pl;
}

-(void)setCurrentTrack:(SpotTrack*)track;
{
  [track retain];
  [currentTrack release];
  currentTrack = track;
}

#pragma mark Property accessors
@synthesize currentTrack, currentPlaylist;

-(SpotTrack*)currentTrack;
{
  if(!currentTrack){
    //try to fetch
    self.currentTrack = [self savedTrack];
  }
  return currentTrack;
}

-(BOOL)isPlaying;
{
  //TODO: might want to verify somehow
  return isPlaying;
}

-(SpotTrack *) savedTrack;
{
  struct track *track = despotify_get_current_track(session.session);
  if(!track) return nil;
  return [[SpotTrack alloc] initWithTrack:track];
}


@end
