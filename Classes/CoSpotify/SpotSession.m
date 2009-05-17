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

static void print_info(struct despotify_session* ds)
{
    struct user_info* user = ds->user_info;
    wprintf(L"Username       : %s\n", user->username);
    wprintf(L"Country        : %s\n", user->country);
    wprintf(L"Account type   : %s\n", user->type);
    wprintf(L"Account expiry : %s", ctime(&user->expiry));
    wprintf(L"Host           : %s:%d\n", user->server_host, user->server_port);
    wprintf(L"Last ping      : %s", ctime(&user->last_ping));
	
    if (strncmp(user->type, "premium", 7)) {
        wprintf(L"\n=================================================\n"
				"                  N O T I C E\n"
				"       You do not have a premium account.\n"
				"     Spotify services will not be available.\n"
				"=================================================\n");
    }
}


@implementation SpotSession
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
		print_info(session);
		NSLog(@"Successfully logged in as %@", user);
	}	
	return success;
}

-(NSArray*)playlists;
{
	NSMutableArray *playlists = [NSMutableArray array];
	
	struct playlist *rootlist = despotify_get_stored_playlists(session);
	for(struct playlist *pl = rootlist; pl; pl = pl->next) {
		SpotPlaylist *playlist = [[[SpotPlaylist alloc] initWithPlaylist:pl] autorelease];
		[playlists addObject:playlist];
	}
	despotify_free_playlist(rootlist);
	
	return playlists;
}
@end
