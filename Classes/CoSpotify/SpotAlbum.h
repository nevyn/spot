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
  
  
  SpotPlaylist *playlist;
}
-(id)initWithAlbum:(struct album*)album;
-(id)initWithAlbumBrowse:(struct album_browse*)album;

-(void)loadMoreInfo;

-(NSComparisonResult)compare:(SpotAlbum*)other;

@property (readonly, nonatomic) BOOL browsing;


@property (readonly) NSInteger version;
@property (readonly) NSString *name;
@property (readonly) NSString *artistName;
@property (readonly) NSString *artistId;
@property (readonly) NSString *type;
@property (readonly) NSInteger year;
@property (readonly) NSString *coverId;
@property (readonly) NSString *review;
@property (readonly) NSArray *copyright;
@property (readonly) NSString *allowed;
@property (readonly) NSString *catalogues; 
@property (readonly) NSArray *similarAlbumIds;
@property (readonly) float popularity;

@property (readonly) NSArray *discs;

@property (readonly) SpotPlaylist *playlist;
           
@end
