//
//  SpotSession.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "despotify.h"
#import "SpotPlayer.h"
#import "SpotURI.h"
#import "SpotItem.h"
#import "SpotCache.h"
#import "SpotImage.h"
#import "SpotCache.h"

@class SpotArtist;
@class SpotAlbum;
@class SpotTrack;

@interface SpotSession : NSObject {
  NSThread *thread;
  NSLock *networkLock;
  
	struct despotify_session *session;
	BOOL loggedIn;
  
  SpotPlayer *player;
  
  SpotCache *cache;
  
  NSMutableArray *playlists;
}
+(SpotSession*)defaultSession;
-(void)cleanup;

-(BOOL)authenticate:(NSString *)user password:(NSString*)password error:(NSError**)error;

-(NSArray*)playlists;


-(void)asyncImageById:(NSString *)id_ respondTo:(id)object selector:(SEL)selector;

-(SpotArtist *)artistById:(NSString *)id_;
-(SpotAlbum *)albumById:(NSString *)id;
-(SpotTrack *)trackById:(NSString *)id;
-(SpotPlaylist *)playlistById:(NSString *)id;

-(SpotAlbum*)albumByURI:(SpotURI*)uri;
-(SpotArtist*)artistByURI:(SpotURI*)uri;
-(SpotTrack*)trackByURI:(SpotURI*)uri;
-(SpotPlaylist*)playlistByURI:(SpotURI*)uri;
-(SpotSearch*)searchByURI:(SpotURI*)uri;

-(SpotItem *)cachedItemById:(NSString*)id;


-(void)playTrack:(SpotTrack*)track;

-(void)addPlaylist:(SpotPlaylist*)playlist;

@property (nonatomic, readonly) BOOL loggedIn;
@property (readonly) NSString *username;
@property (readonly) NSString *country;
@property (readonly) NSString *accountType;
@property (readonly) NSDate *expires;
@property (readonly) NSString *serverHost;
@property (readonly) NSUInteger serverPort;
@property (readonly) NSDate *lastPing;
@property (readonly) SpotPlayer *player;

@property (readonly) struct despotify_session *session;
@end

extern NSString *SpotSessionErrorDomain;
typedef enum {
	SpotSessionErrorCodeDefault = 1
} SpotSessionErrorCode;
