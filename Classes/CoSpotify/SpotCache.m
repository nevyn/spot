//
//  SpotCache.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotCache.h"


@implementation SpotCache

-(id)init;
{
  if( ! [super init] ) return nil;
  
  cache = [[NSMutableDictionary alloc] init];
  
  //Subscribe to memory warnings to autoflush the cache
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
  
  return self;
}

-(void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [cache release];
  [super dealloc];
}

-(void)didReceiveMemoryWarningNotification:(NSNotification*)n;
{
  [self purge];
}

-(void)addItem:(SpotItem*)item;
{
  [cache setObject:item forKey:item.id];
}

-(SpotItem *)itemById:(NSString*)id_;
{
  SpotItem *item = [cache objectForKey:id_];
  NSLog(@"Cache %s %@", item ? "hit" : "miss", item);
  return item;
}

-(void)purge;
{
  NSLog(@"Purging cache");
  for(SpotItem *item in [cache allValues]){
    NSLog(@"%@ %d", [item className], [item retainCount]);
    if([item retainCount] == 2){
      //item is in cache and allValues only so we want them gone
      NSLog(@"Removing %@", item);
      [cache removeObjectForKey:item.id]; //Hm. Hope id doesn't change!
    } else if([item retainCount] < 2){
      NSLog(@"ROFL! cache got object with RetainCount Below ONE");
    }
  }
}

@end
