//
//  SpotSession.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotSession.h"

SpotSession *SpotSessionSingleton;

NSString *SpotSessionErrorDomain = @"SpotSessionErrorDomain";

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
	
	despotify_init();
	
	session = despotify_init_client();
	
	return self;
}
-(void)dealloc;
{
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
	return success;
}
@end
