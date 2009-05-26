//
//  SpotAlbum.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotAlbum.h"
#import "SpotTrack.h"
#import "SpotSession.h"
#import "SpotURI.h"

@implementation SpotAlbum

@synthesize browsing, playlist;

-(id)initWithAlbum:(struct album*)album_;
{
	if( ! [super init] ) return nil;
	
  browsing = NO;
	memcpy(&album, album_, sizeof(struct album));
  tracks = nil;
  return self;
}

-(id)initWithAlbumBrowse:(struct album_browse*)album_;
{
  if( ! [super init] ) return nil;
  
  browsing = YES;
	memcpy(&albumBrowse, album_, sizeof(struct album_browse));
  
  
  strcpy(album.name, albumBrowse.name);
  strcpy(album.id, albumBrowse.id);
  strcpy(album.cover_id, albumBrowse.cover_id);
  album.popularity = albumBrowse.popularity;
  
  SpotMutablePlaylist *a_playlist = [[SpotMutablePlaylist alloc] init];
  a_playlist.name = self.name;
  NSMutableArray *a_tracks = [[NSMutableArray alloc] initWithCapacity:albumBrowse.num_tracks];
  if(albumBrowse.num_tracks > 0){
    for(struct track *track = albumBrowse.tracks; track != NULL; track = track->next){
      SpotTrack *strack = [[(SpotTrack*)[SpotTrack alloc] initWithTrack:track] autorelease];
      [a_playlist addTrack:strack];
      [a_tracks addObject:strack];
    }
  }
  playlist = a_playlist;
  tracks = a_tracks;
	
	return self;
}

-(SpotAlbum *)moreInfo;
{
  if(browsing) return nil;
  return [[SpotSession defaultSession] albumById:self.id];
}

-(NSComparisonResult)compare:(SpotAlbum*)other;
{
  return [self.name compare:other.name];
}

#pragma mark shared
-(SpotId *)id; { return [SpotId albumId:album.id]; }
-(SpotURI*)uri;
{
  char uri[50];
  return [SpotURI uriWithURI:despotify_album_to_uri(&albumBrowse, uri)];  
}

-(NSString *)name; { return [NSString stringWithUTF8String:album.name]; }
-(SpotId *)coverId; { return [SpotId coverId:album.cover_id]; }
-(float) popularity; { return album.popularity; }

#pragma mark artist only  
-(NSString *)artistName; { return browsing ? nil : [NSString stringWithUTF8String:album.artist]; }
-(SpotId *)artistId; { return browsing ? nil : [SpotId artistId:album.artist_id]; }
  
#pragma mark browsing only
-(int) year; { return browsing ? albumBrowse.year : 0; }
-(NSArray *)tracks; { return tracks; } 

-(BOOL)isEqual:(SpotAlbum*)other;
{
  return [self hash] == [other hash];
}

-(NSInteger)hash;
{
  return [self.id hash];
}

@end
