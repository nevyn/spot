//
//  SpotId.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotId.h"


@implementation SpotId

//TODO: is this resonable or safe to assume sizeof(id) ?

+(SpotId*)trackId:(char[33])id;
{  return [[[SpotId alloc] initWithId:id size:33] autorelease];  }

+(SpotId*)artistId:(char[33])id;
{  return [[[SpotId alloc] initWithId:id size:33] autorelease];  }

+(SpotId*)albumId:(char[33])id;
{  return [[[SpotId alloc] initWithId:id size:33] autorelease];  }

+(SpotId*)playlistId:(char[35])id;
{  return [[[SpotId alloc] initWithId:id size:35] autorelease];  }

+(SpotId*)fileId:(char[41])id;
{  return [[[SpotId alloc] initWithId:id size:41] autorelease];  }

+(SpotId*)coverId:(char[41])id;
{  return [[[SpotId alloc] initWithId:id size:41] autorelease];  }

+(SpotId*)portraitId:(char[41])id;
{  return [[[SpotId alloc] initWithId:id size:41] autorelease];  }

-(id)initWithId:(char*)id_ size:(char)size;
{
  if( ! [super init] ) return nil;

  if(memcmp(id_, "\0\0\0\0\0\0\0\0\0\0", 10) == 0) //if no id
    return nil;
    
  memset(_id, 0, 50);
  memcpy(_id, id_, size);
  
  return self;
}

-(char *)id; { return _id; };

-(NSString *)description;
{
  return [NSString stringWithFormat:@"ID: %s", _id];
}

-(NSInteger)hash;
{
  return [[NSString stringWithCString:_id] hash];
}

@end
