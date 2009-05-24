//
//  SpotSession.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotSession.h"
#import "SpotPlaylist.h"
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <wchar.h>


SpotSession *SpotSessionSingleton;

NSString *SpotSessionErrorDomain = @"SpotSessionErrorDomain";

@interface SpotSession ()
@property (nonatomic, readwrite) BOOL loggedIn;

@end


@implementation SpotSession
@synthesize loggedIn;

+(SpotSession*)defaultSession;
{
	if(!SpotSessionSingleton)
		SpotSessionSingleton = [[SpotSession alloc] init];
	
	return SpotSessionSingleton;
}

-(id)init;
{
	if( ! [super init] ) return nil;
	
	if(!despotify_init()) {
		NSLog(@"Init failed");
		[self release];
		return nil;
	}
	
	session = despotify_init_client();
	if( !session) {
		NSLog(@"Init client failed");
		[self release];
		return nil;
	}
	
	self.loggedIn = NO;
	
	return self;
}
-(void)dealloc;
{
	NSLog(@"Logged out");
	despotify_exit(session);
	despotify_cleanup();
	[super dealloc];
}

-(void)cleanup;
{
	[self release];
	SpotSessionSingleton = nil;
}

-(BOOL)authenticate:(NSString *)user password:(NSString*)password error:(NSError**)error;
{
	BOOL success = despotify_authenticate(session, [user UTF8String], [password UTF8String]);
	if(!success && error)
		*error = [NSError errorWithDomain:SpotSessionErrorDomain code:SpotSessionErrorCodeDefault userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%s", despotify_get_error(session)] forKey:NSLocalizedDescriptionKey]];
	usleep(500000);
	if(success) {
		NSLog(@"Successfully logged in as %@", user);
	}
	self.loggedIn = success;
	return success;
}

-(NSArray*)playlists;
{
	NSMutableArray *playlists = [NSMutableArray array];
	return playlists; // until they fix their playlist servers
	
	struct playlist *rootlist = despotify_get_stored_playlists(session);
	for(struct playlist *pl = rootlist; pl; pl = pl->next) {
		SpotPlaylist *playlist = [[[SpotPlaylist alloc] initWithPlaylist:pl] autorelease];
		[playlists addObject:playlist];
	}
	despotify_free_playlist(rootlist);
	
	return playlists;
}


-(NSString*)username;
{
	return [NSString stringWithUTF8String:session->user_info->username];	
}
-(NSString*)country;
{
	return [NSString stringWithUTF8String:session->user_info->country];
}
-(NSString*)accountType;
{
	return [NSString stringWithUTF8String:session->user_info->type];
}
-(NSDate*)expires;
{
	return [NSDate dateWithTimeIntervalSince1970:session->user_info->expiry];
}
-(NSString*)serverHost;
{
	return [NSString stringWithUTF8String:session->user_info->server_host];
}
-(NSUInteger)serverPort;
{
	return session->user_info->server_port;
}
-(NSDate*)lastPing;
{
	return [NSDate dateWithTimeIntervalSince1970:session->user_info->last_ping];
}
@end
