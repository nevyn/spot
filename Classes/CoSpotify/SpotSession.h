//
//  SpotSession.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "despotify.h"
#import "SpotId.h"
@class SpotArtist;


@interface SpotSession : NSObject {
	struct despotify_session *session;
	BOOL loggedIn;
}
+(SpotSession*)defaultSession;
-(void)cleanup;

-(BOOL)authenticate:(NSString *)user password:(NSString*)password error:(NSError**)error;

-(NSArray*)playlists;

-(SpotArtist *)artistById:(SpotId *)id_;
-(void *)imageById:(SpotId*)id;

@property (nonatomic, readonly) BOOL loggedIn;
@property (readonly) NSString *username;
@property (readonly) NSString *country;
@property (readonly) NSString *accountType;
@property (readonly) NSDate *expires;
@property (readonly) NSString *serverHost;
@property (readonly) NSUInteger serverPort;
@property (readonly) NSDate *lastPing;

@property (readonly) struct despotify_session *session;
@end

extern NSString *SpotSessionErrorDomain;
typedef enum {
	SpotSessionErrorCodeDefault = 1
} SpotSessionErrorCode;
