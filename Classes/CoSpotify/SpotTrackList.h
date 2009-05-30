//
//  SpotTrackList.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-27.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpotTrack;

@interface SpotTrackList : NSObject {
  id delegate;
  NSMutableArray *tracks;
}

-(id)init;
-(id)initWithTracks:(NSArray*)tracks;

-(void)addTrack:(SpotTrack*)track;
-(void)removeTrack:(SpotTrack*)track;

-(void)sortByTrackOrder;

-(SpotTrack*) findTrackWithId:(NSString*)trackid;

-(SpotTrack*) trackBefore:(SpotTrack*)track;
-(SpotTrack*) trackAfter:(SpotTrack*)track;


@property (readwrite, assign) id delegate;
@property (readonly, nonatomic) NSArray *tracks;

@end

