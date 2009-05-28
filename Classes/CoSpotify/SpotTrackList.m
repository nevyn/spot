//
//  SpotTrackList.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotTrackList.h"

#import "SpotTrack.h"

@interface NSObject (TrackListDelegate)

-(void)trackList:(SpotTrackList*)trackList trackAdded:(SpotTrack*)track;
-(void)trackList:(SpotTrackList*)trackList trackRemoved:(SpotTrack*)track;

@end


@implementation SpotTrackList

@synthesize delegate, tracks;

-(id)init;
{
  if( ! [super init] ) return nil;
  
  tracks = [[NSMutableArray alloc] init];
  
  return self;
}

-(id)initWithTracks:(NSArray*)tracks_;
{
  if( ! [super init] ) return nil;
  
  tracks = [tracks_ mutableCopy];
  
  return self;
}

-(void)dealloc;
{
  [tracks release];
  [super dealloc];
}

-(void)insertTrack:(SpotTrack*)track atIndex:(int)idx;
{
  if([tracks containsObject:track]) return;
  
  [tracks insertObject:track atIndex:idx];
  
  if([delegate respondsToSelector:@selector(trackList:trackAdded:)])
    [delegate trackList:self trackAdded:track];
}

-(void)addTrack:(SpotTrack*)track;
{
  if([tracks containsObject:track]) return;
  
  [tracks addObject:track];
 
  if([delegate respondsToSelector:@selector(trackList:trackAdded:)])
    [delegate trackList:self trackAdded:track];
}

-(void)removeTrack:(SpotTrack*)track;
{
  if(![tracks containsObject:track]) return;
  
  [tracks removeObject:track];
  
  if([delegate respondsToSelector:@selector(trackList:trackRemoved:)])
    [delegate trackList:self trackRemoved:track];
}

-(void)sortByTrackOrder;
{
  [tracks sortUsingSelector:@selector(comparePlaylistOrder:)];
}

-(SpotTrack*) findTrackWithId:(SpotId*)trackid;
{
  for(SpotTrack *track in tracks)
    if([track.id isEqual:trackid]) return track;
  return nil;
}

-(SpotTrack*) trackBefore:(SpotTrack*)track;
{
  int idx = [tracks indexOfObject:track] - 1;
  if(idx < 0) return nil;
  return [tracks objectAtIndex:idx];
}

-(SpotTrack*) trackAfter:(SpotTrack*)track;
{
  int idx = [tracks indexOfObject:track] + 1;
  if(idx >= [tracks count]) return nil;
  return [tracks objectAtIndex:idx];
}

@end
