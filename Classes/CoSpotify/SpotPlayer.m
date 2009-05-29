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

@interface SpotPlayer (Private)

-(void)setCurrentPlaylist:(SpotPlaylist*)pl;
-(void)setCurrentTrack:(SpotTrack*)track;

@end

//TODO: While waiting for despotify to start or stop playback we need to queue other commands
@implementation SpotPlayer

-(id)initWithSession:(SpotSession*)session_;
{
  if( ! [super init] ) return nil;
  
  session = session_;
  
  return self;
}

#pragma mark Playback control

-(BOOL)startPlayback;
{
  if(self.isPlaying || willPlay) return NO;
  //start playback if we have something to play
  if(self.currentTrack){
    [UIApplication sharedApplication].idleTimerDisabled = YES; //dont sleep while playing music
    //if([self.savedTrack isEqual:self.currentTrack])
    
    if([self.savedTrack isEqual:self.currentTrack])
      willPlay = despotify_resume([SpotSession defaultSession].session);
    else
      willPlay = despotify_play([SpotSession defaultSession].session, self.currentTrack.track, NO); 
    return willPlay;
  }
  return NO; 
}

-(BOOL)stopPlayback;
{
  if(self.isPlaying && !willPlay){
    [UIApplication sharedApplication].idleTimerDisabled = NO; //can sleep while not playing
    isPlaying = !despotify_stop([SpotSession defaultSession].session) && isPlaying;  
    return !isPlaying;
  }
  return NO;
}

#pragma mark Player "buttons"

-(BOOL)playTrack:(SpotTrack*)track rewind:(BOOL)rewind;
{
  if(willPlay) return NO;
  if(!track) return NO;
  //dont do anything if track is playing and we dont want to rewind
  if([self.currentTrack isEqual:track] && !rewind)
    return NO;

  if(self.isPlaying)
    [self stop];
  
  SpotAlbum *album = track.album;
  if(!album)NSLog(@"track has no album info");
  SpotPlaylist *playlist = track.album.playlist;
  
  return [self playPlaylist:playlist firstTrack:track];
}

-(BOOL)playPlaylist:(SpotPlaylist*)playlist firstTrack:(SpotTrack*)track;
{
  /*
   set current playlist and play first song
   */
  if(willPlay) return NO;
  if(!playlist) return NO;
  if(!track) track = [playlist.tracks objectAtIndex:0];
  
  if(![playlist.tracks containsObject:track])
    [NSException raise:NSInvalidArgumentException format:@"The 'track' argument must be in the playlist given"];
  
  [self setCurrentPlaylist:playlist];
  [self setCurrentTrack:track];
  
  return [self play];
}

-(BOOL)pause;
{
  //stop playback
  if(self.isPlaying && !willPlay){
    [UIApplication sharedApplication].idleTimerDisabled = NO; //can sleep while paused
    isPlaying = !despotify_pause([SpotSession defaultSession].session) && isPlaying;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"pause" object:self]];
    return YES;
  }
  return NO;
}

-(BOOL)play;
{
  if([self startPlayback]){
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"willplay" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:currentPlaylist, @"playlist", currentTrack, @"track", nil]]];
    return YES;
  }
  return NO;
}

-(BOOL)stop;
{
  if([self stopPlayback]){
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"stop" object:self]];
    return YES;
  }
  return NO;
}

-(BOOL)playNextTrack;
{
  SpotTrack *next = [currentPlaylist trackAfter:self.currentTrack];
  if(next){
    [self playTrack:next rewind:NO];
    return YES;
  }
  return NO;
}

-(BOOL)playPreviousTrack;
{
  SpotTrack *prev = [currentPlaylist trackBefore:self.currentTrack];
  if(prev) {
    [self playTrack:prev rewind:NO];
    return YES;
  }
  return NO;
}

#pragma mark Private

-(void)trackDidStart;
{
  willPlay = NO;
  isPlaying = YES;
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"play" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:currentPlaylist, @"playlist", currentTrack, @"track", nil]]];
}

-(void)trackDidEnd;
{
  [self stopPlayback];
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"trackDidEnd" object:self]];
}

-(void)setCurrentPlaylist:(SpotPlaylist*)pl;
{
  [pl retain];
  [currentPlaylist release];
  SpotPlaylist *old = currentPlaylist;
  currentPlaylist = pl;
  if(old != pl)
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"playlist" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:currentPlaylist, @"playlist", nil]]];
}

-(void)setCurrentTrack:(SpotTrack*)track;
{
  [track retain];
  [currentTrack release];
  SpotTrack *old = currentTrack;
  currentTrack = track;
  
  if(old != track){
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"track" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:track, @"track", nil]]];
  }
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
