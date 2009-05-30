//
//  SpotItem.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotItem.h"


@implementation SpotItem

-(void)ensureFullProfile;
{
  //nothing
}

-(NSString *)id;
{
  [NSException raise:@"NotImplemented" format:@"SpotItem id not overridden"];
  return nil;
}

-(SpotURI *)uri;
{
  return [SpotURI uriWithId:self.id];
}

#if 1
-(void)release;
{
  if([self retainCount] == 1){
    NSLog(@"Will dealloc %@", self);
  }
  [super release];
}

#endif

@end
