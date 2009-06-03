//
//  SpotArtist.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "despotify.h"
#import "SpotItem.h"

@interface SpotArtistBio : NSObject
{
  NSString *text;
  NSArray *portraits;
}

@property (readonly) NSString *text;
@property (readonly) NSArray *portraits;

@end



@interface SpotArtist : SpotItem <NSCoding>{
  BOOL browsing;
  
  NSString *name;
  NSString *portraitId;
  float popularity;
  NSInteger version;
  NSString *artistId;
  
  NSArray *bios;
  
  NSArray *similarArtists;
  NSString *genres;
  NSString *yearsActive;
  
  NSArray *albums;
  
}
-(id)initWithArtist:(struct artist*)artist;
-(id)initWithArtistBrowse:(struct artist_browse*)artistBrowse;

-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;


-(NSComparisonResult)compare:(SpotArtist*)other;

@property (readonly, nonatomic) NSString *text;

@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *portraitId;
@property (readonly, nonatomic) float popularity;
@property (readonly, nonatomic) NSInteger version;
@property (readonly, nonatomic) NSString *artistId;
@property (readonly, nonatomic) NSArray *bios;
@property (readonly, nonatomic) NSArray *similarArtists;
@property (readonly, nonatomic) NSString *genres;
@property (readonly, nonatomic) NSString *yearsActive;
@property (readonly, nonatomic) NSArray *albums;

@property (readonly, nonatomic) BOOL browsing;

@end
