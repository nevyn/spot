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
#import "SpotURI.h"

@implementation SpotArtist

@synthesize browsing;

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

-(void)loadBrowse:(struct artist_browse*)artistBrowse_;
{
  browsing = YES;
	
	memcpy(&artistBrowse, artistBrowse_, sizeof(struct artist_browse));
  
  NSMutableArray *a_albums = [[NSMutableArray alloc] initWithCapacity:artistBrowse.num_albums];
  if(artistBrowse.num_albums > 0){
    for(struct album_browse *album = artistBrowse.albums; album != NULL; album = album->next){
      [a_albums addObject:[[[SpotAlbum alloc] initWithAlbumBrowse:album] autorelease]];
    }
  }
  albums = a_albums;  
}

-(id)initWithArtistBrowse:(struct artist_browse*)artistBrowse_;
{
	if( ! [super init] ) return nil;
  
  [self loadBrowse:artistBrowse_];
  
	return self;
}

-(void)dealloc;
{
	[super dealloc];
}

-(void)loadMoreInfo;
{
  if(!browsing){
    NSLog(@"Artist %@ loading more info", self);
    struct artist_browse *ab = despotify_get_artist([SpotSession defaultSession].session, artist.id);
    [self loadBrowse:ab];
  }
}

-(NSComparisonResult)compare:(SpotArtist*)other;
{
  return [self.name compare:other.name];
}

#pragma mark Properties

-(SpotId *)id;
{
  return [SpotId artistId:artistBrowse.id];
}

-(SpotURI*)uri;
{
  char uri[50];
  return [SpotURI uriWithURI:despotify_artist_to_uri(&artistBrowse, uri)];  
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
  if(!browsing) [self loadMoreInfo];
  return albums;
}

-(NSString *)yearsActive;
{
  if(!browsing) [self loadMoreInfo];
  return [NSString stringWithCString:artistBrowse.years_active];
}

-(NSString *)genres;
{
  if(!browsing) [self loadMoreInfo];
  return [NSString stringWithCString:artistBrowse.genres];
}

-(NSString *)text;
{
  if(!browsing) [self loadMoreInfo];
  if(!artistBrowse.text) return @"";
  return [NSString stringWithCString:artistBrowse.text];
}

-(BOOL)isEqual:(SpotArtist*)other;
{
  return [self hash] == [other hash];
}

-(NSInteger)hash;
{
  return [self.id hash];
}

@end
