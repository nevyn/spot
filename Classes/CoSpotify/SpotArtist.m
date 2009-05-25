//
//  SpotArtist.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotArtist.h"
#import "SpotAlbum.h"
#import "SpotId.h"
#import "SpotSession.h"

@implementation SpotArtist
-(id)initWithArtist:(struct artist*)artist_;
{
	if( ! [super init] ) return nil;
  
  browsing = NO;
	
	memcpy(&artist, artist_, sizeof(struct artist));
  
  strcpy(artistBrowse.name, artist.name);
  strcpy(artistBrowse.id, artist.id);
  strcpy(artistBrowse.portrait_id, artist.portrait_id);
  artistBrowse.popularity = artist.popularity;
  
  artistBrowse.text = "";
  memset(artistBrowse.genres, 0, sizeof(artistBrowse.genres));
    memset(artistBrowse.years_active, 0, sizeof(artistBrowse.years_active));
  artistBrowse.num_albums = 0;
  artistBrowse.albums = NULL;
  
  albums = nil;
  
	return self;
}

-(id)initWithArtistBrowse:(struct artist_browse*)artistBrowse_;
{
	if( ! [super init] ) return nil;
  
  browsing = YES;
	
	memcpy(&artistBrowse, artistBrowse_, sizeof(struct artist_browse));
  
  NSMutableArray *a_albums = [[NSMutableArray alloc] initWithCapacity:artistBrowse.num_albums];
  if(artistBrowse.num_albums > 0){
    for(struct album_browse *album = artistBrowse.albums; album != NULL; album = album->next){
      [a_albums addObject:[[[SpotAlbum alloc] initWithAlbumBrowse:album] autorelease]];
    }
  }
  albums = a_albums;
  
	return self;
}

-(void)dealloc;
{
	[super dealloc];
}

-(SpotId *)id;
{
  return [SpotId artistId:artistBrowse.id];
}

-(NSString*)name;
{
  return [NSString stringWithUTF8String:artistBrowse.name];
}
-(float)popularity;
{
	return artistBrowse.popularity;
}

-(SpotId *)portraitId;
{ 
  return [SpotId portraitId:artistBrowse.portrait_id];
}

-(UIImage*)portrait;
{
  if(!portrait) portrait = [[SpotSession defaultSession] imageById:self.portraitId];
  return portrait;
}

-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotArtist %@>", self.name];
}

#pragma mark props form _browse

-(NSArray *)albums;
{
  return albums;
}

-(NSString *)yearsActive;
{
  return [NSString stringWithCString:artistBrowse.years_active];
}

-(NSString *)genres;
{
  return [NSString stringWithCString:artistBrowse.genres];
}

@end
