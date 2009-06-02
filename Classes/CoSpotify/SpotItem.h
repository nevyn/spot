//
//  SpotItem.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotURI.h"

@interface SpotItem : NSObject <NSCoding> {

}

-(id)initWithCoder:(NSCoder *)decoder;
-(void)encodeWithCoder:(NSCoder *)encoder;

//Ensure that as much data as possible is loaded
-(void)ensureFullProfile;

@property (readonly, nonatomic) NSString *id;
@property (readonly, nonatomic) SpotURI *uri;

@end
