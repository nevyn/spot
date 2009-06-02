//
//  SpotTrack.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "despotify.h"
#import "SpotArtist.h"

#import <UIKit/UIKit.h>
#import "SpotItem.h"

@class SpotPlaylist;
@class SpotURI;

@interface SpotTrack : SpotItem {
  struct track de_track; //we need a struct to send to despotify
  
  NSString *trackId;
  NSString *title;
  NSString *artistId;
  NSString *artistName;
  NSString *albumName;
  NSString *albumId;
  NSString *coverId;
  NSArray *similarTrackIds;
  NSArray *files;
  NSDictionary *restrictions;
  
  NSInteger trackNumber;
  NSInteger year;
  float length;
  float popularity;
  
  //despot only
  BOOL isPlayable;
  BOOL hasMetadata;
  
  SpotArtist *artist;
  
  SpotAlbum *album;
}
-(id)initWithTrack:(struct track*)track_;

-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

-(NSComparisonResult)compare:(SpotTrack*)other;

@property (readonly, nonatomic) NSString *trackId;
@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSString *artistId;
@property (readonly, nonatomic) NSString *artistName;
@property (readonly, nonatomic) NSString *albumName;
@property (readonly, nonatomic) NSString *albumId;
@property (readonly, nonatomic) NSString *coverId;
@property (readonly, nonatomic) NSInteger trackNumber;
@property (readonly, nonatomic) float length;
@property (readonly, nonatomic) NSArray *files;
@property (readonly, nonatomic) float popularity;
@property (readonly, nonatomic) NSArray *similarTrackIds;
@property (readonly, nonatomic) NSDictionary *restrictions;
@property (readonly, nonatomic) NSInteger year;

//despot only
@property (readonly, nonatomic) BOOL isPlayable;
@property (readonly, nonatomic) SpotArtist *artist;

//helper
@property (readonly, nonatomic) SpotAlbum *album;

//dont want to need this
@property (readonly, nonatomic) struct track* de_track;

-(NSUInteger)hash;

@end
