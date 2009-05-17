//
//  SpotSession.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "despotify.h"

@interface SpotSession : NSObject {
	struct despotify_session *session;
}
+(SpotSession*)defaultSession;
-(void)cleanup;

-(BOOL)authenticate:(NSString *)user password:(NSString*)password error:(NSError**)error;

@end

extern NSString *SpotSessionErrorDomain;
typedef enum {
	SpotSessionErrorCodeDefault = 1
} SpotSessionErrorCode;
