//
//  SpotTouchableLabel.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SpotTouchableLabel : UILabel {
  id delegate;
}

@property (nonatomic, assign) id delegate;

@end
