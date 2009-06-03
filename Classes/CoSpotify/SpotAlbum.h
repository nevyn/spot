//
//  SpotAlbum.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "despotify.h"
#import "SpotArtist.h"
#import "SpotPlaylist.h"
#import "SpotItem.h"

@interface SpotAlbum : SpotItem {
  BOOL browsing;

  NSString *albumId;
  NSInteger version;
  NSString *name;
  NSString *artistName;
  NSString *artistId;
  NSString *type;
  NSInteger year;
  NSString *coverId;
  NSString *review;
  NSArray *copyright;
  NSString *allowed;
  NSString *catalogues; //from restrictions
  NSArray *similarAlbumIds;
  float popularity;
  
  NSArray *discs;
  
  SpotArtist *artist;
  
  
  SpotPlaylist *playlist;
}
-(id)initWithAlbum:(struct album*)album;
-(id)initWithAlbumBrowse:(struct album_browse*)album;

-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

-(NSComparisonResult)compare:(SpotAlbum*)other;

@property (readonly, nonatomic) BOOL browsing;


@property (readonly, nonatomic) NSInteger version;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSString *artistName;
@property (readonly, nonatomic) NSString *artistId;
@property (readonly, nonatomic) NSString *type;
@property (readonly, nonatomic) NSInteger year;
@property (readonly, nonatomic) NSString *coverId;
@property (readonly, nonatomic) NSString *review;
@property (readonly, nonatomic) NSArray *copyright;
@property (readonly, nonatomic) NSString *allowed;
@property (readonly, nonatomic) NSString *catalogues; 
@property (readonly, nonatomic) NSArray *similarAlbumIds;
@property (readonly, nonatomic) float popularity;

@property (readonly, nonatomic) NSArray *discs;

@property (readonly, nonatomic) SpotPlaylist *playlist;

//Helpers
@property (readonly, nonatomic) SpotArtist *artist;
           
@end
