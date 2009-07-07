//
//  SpotArtist.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotArtist.h"
#import "SpotAlbum.h"
#import "SpotSession.h"
#import "SpotURI.h"



@implementation SpotArtistBio

@synthesize text, portraits;

-(id)initWithText:(NSString*)t;
{
  if( ! [super init] ) return nil;
  
  text = [t retain];
  
  return self;
}

-(void)dealloc;
{
  [text release];
  [portraits release];
  [super dealloc];
}

-(NSString *)description;
{
  return [NSString stringWithFormat:@"<SpotArtistBio text: %@ portraits: %@>", text, portraits];
}

@end




@implementation SpotArtist

@synthesize browsing;
@synthesize name, portraitId, popularity, version, artistId, bios, similarArtists, genres, yearsActive, albums;


-(id)initWithArtist:(struct artist*)artist;
{
	if( ! [super init] ) return nil;
  
  browsing = NO;
	
  name = [[NSString alloc] initWithUTF8String:artist->name];
  artistId = [[NSString alloc] initWithUTF8String:artist->id];
  portraitId = [[NSString alloc] initWithUTF8String:artist->portrait_id];
  popularity = artist->popularity;
  
	return self;
}

-(void)loadBrowse:(struct artist_browse*)artist;
{
  browsing = YES;
	
  name = [[NSString alloc] initWithUTF8String:artist->name];
  artistId = [[NSString alloc] initWithUTF8String:artist->id];
  portraitId = [[NSString alloc] initWithUTF8String:artist->portrait_id];
  genres = [[NSString alloc] initWithUTF8String:artist->genres];
  yearsActive = [[NSString alloc] initWithUTF8String:artist->years_active];
  popularity = artist->popularity;
  
  SpotArtistBio *bio;
  if(artist->text) bio = [[SpotArtistBio alloc] initWithText:[NSString stringWithUTF8String:artist->text]];
  else bio = [[SpotArtistBio alloc] initWithText:@""];
  bios = [[NSArray alloc] initWithObjects:bio, nil];
  [bio release];
  
  NSMutableArray *a_albums = [[NSMutableArray alloc] initWithCapacity:artist->num_albums];
  if(artist->num_albums > 0){
    for(struct album_browse *album = artist->albums; album != NULL; album = album->next){
      [a_albums addObject:[[[SpotAlbum alloc] initWithAlbumBrowse:album] autorelease]];
    }
  }
  albums = a_albums;  
}

-(id)initWithCoder:(NSCoder *)decoder;
{
  self = [super initWithCoder:decoder];
  browsing = [decoder decodeBoolForKey:@"SAbrowsing"];
  name = [[decoder decodeObjectForKey:@"SAname"] retain];
  artistId = [[decoder decodeObjectForKey:@"SAartistId"] retain];
  portraitId = [[decoder decodeObjectForKey:@"SAportraitId"] retain];
  genres = [[decoder decodeObjectForKey:@"SAgenres"] retain];
  yearsActive = [[decoder decodeObjectForKey:@"SAyearsActive"] retain];
  popularity = [decoder decodeFloatForKey:@"SApopularity"];
  bios = [[decoder decodeObjectForKey:@"SAbio"] retain];
  albums = [[decoder decodeObjectForKey:@"SAalbums"] retain];
  return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder;
{
  [super encodeWithCoder:encoder];
  [encoder encodeBool:browsing forKey:@"SAbrowsing"];
  [encoder encodeObject:name forKey:@"SAname"];
  [encoder encodeObject:artistId forKey:@"SAartistId"];
  [encoder encodeObject:portraitId forKey:@"SAportraitId"];
  [encoder encodeObject:genres forKey:@"SAgenres"];
  [encoder encodeObject:yearsActive forKey:@"SAyearsActive"];
  [encoder encodeFloat:popularity forKey:@"SApopularity"];
  [encoder encodeObject:bios forKey:@"SAbio"];
  [encoder encodeObject:albums forKey:@"SAalbums"];
}

-(id)initWithArtistBrowse:(struct artist_browse*)artistBrowse_;
{
	if( ! [super init] ) return nil;
  
  [self loadBrowse:artistBrowse_];
  
	return self;
}

-(void)dealloc;
{
  [name release];
  [portraitId release];
  [artistId release];
  [bios release];
  [similarArtists release];
  [genres release];
  [yearsActive release];
  [albums release];
  
	[super dealloc];
}


-(NSComparisonResult)compare:(SpotArtist*)other;
{
  return [self.name compare:other.name];
}

#pragma mark Properties

-(NSString *)id;
{
  return artistId;
}

-(SpotURI*)uri;
{
  //char uri[50];
  //return [SpotURI uriWithURI:despotify_artist_to_uri(&artistBrowse, uri)];  
  return nil;
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


-(NSString *)text;
{
  if(!bios || [bios count] == 0) return @"";
  return ((SpotArtistBio*)[bios lastObject]).text;
}

-(BOOL)isEqual:(SpotArtist*)other;
{
  return [self hash] == [other hash];
}

-(NSUInteger)hash;
{
  return [self.id hash];
}

@end
