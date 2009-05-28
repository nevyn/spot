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
  
  //clear ab
  memset(&albumBrowse, 0, sizeof(struct album_browse));
  
  return self;
}

-(void)loadBrowse:(struct album_browse*)album_;
{
  browsing = YES;
  
  //copy data
	memcpy(&albumBrowse, album_, sizeof(struct album_browse));
  
  
  NSString *artistName = nil;
  
  NSMutableArray *a_tracks = [[NSMutableArray alloc] initWithCapacity:albumBrowse.num_tracks];
  if(albumBrowse.num_tracks > 0){
    for(struct track *track = albumBrowse.tracks; track != NULL; track = track->next){
      SpotTrack *strack = [[[SpotTrack alloc] initWithTrack:track] autorelease];
      
      //Figure out artist name
      if(artistName && ![artistName isEqual:strack.artist.name]) 
        artistName = @"Various artists";
      else if(!artistName)
        artistName = strack.artist.name;
      
      [a_tracks addObject:strack];
    }
  }
  
  playlist = [[SpotPlaylist alloc] initWithName:self.name author:artistName tracks:a_tracks];
}

-(id)initWithAlbumBrowse:(struct album_browse*)album_;
{
  if( ! [super init] ) return nil;
  
  [self loadBrowse:album_];
  
  //clear album and copy what we can
  memset(&album, 0, sizeof(struct album));
  strcpy(album.name, albumBrowse.name);
  strcpy(album.id, albumBrowse.id);
  strcpy(album.cover_id, albumBrowse.cover_id);
  album.popularity = albumBrowse.popularity;
  

  
  return self;
}

-(void)loadMoreInfo;
{
  if(!browsing){
    NSLog(@"Album %@ loading more info", self);
    struct album_browse *ab = despotify_get_album([SpotSession defaultSession].session, album.id);
    [self loadBrowse:ab];
  }
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
-(int) year; 
{
  if(!browsing) [self loadMoreInfo];
  return albumBrowse.year; 
}

-(SpotPlaylist*)playlist;
{
  if(!browsing) [self loadMoreInfo];
  return playlist;
}

-(BOOL)isEqual:(SpotAlbum*)other;
{
  return [self hash] == [other hash];
}

-(NSInteger)hash;
{
  return [self.id hash];
}

@end
