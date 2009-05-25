//
//  SpotId.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotId.h"


@implementation SpotId


+(SpotId*)trackId:(char[33])id;
{  return [[[SpotId alloc] initWithId:id size:33] autorelease];  }

+(SpotId*)fileId:(char[41])id;
{  return [[[SpotId alloc] initWithId:id size:41] autorelease];  }

+(SpotId*)albumId:(char[33])id;
{  return [[[SpotId alloc] initWithId:id size:33] autorelease];  }

+(SpotId*)coverId:(char[41])id;
{  return [[[SpotId alloc] initWithId:id size:41] autorelease];  }

+(SpotId*)artistId:(char[33])id;
{  return [[[SpotId alloc] initWithId:id size:33] autorelease];  }

+(SpotId*)playlistId:(char[35])id;
{  return [[[SpotId alloc] initWithId:id size:35] autorelease];  }

-(id)initWithId:(char*)id_ size:(char)size;
{
  if( ! [super init] ) return nil;
  
  memcpy(_id, id_, size);
  
  return self;
}

-(char *)trackId; { return _id; };
-(char *)fileId; { return _id; };
-(char *)albumId; { return _id; };
-(char *)coverId; { return _id; };
-(char *)artistId; { return _id; };
-(char *)playlistId; { return _id; };

@end
