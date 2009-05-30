//
//  SpotImageCell.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotImageView.h"

@interface SpotImageCell : UITableViewCell {
  SpotImageView *spotArt;
}

@property (nonatomic, assign) NSString *artId;

@end
