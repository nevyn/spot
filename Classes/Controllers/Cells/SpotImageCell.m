//
//  SpotImageCell.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotImageCell.h"


@implementation SpotImageCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
  
  [super layoutSubviews];
  
	// getting the cell size
  CGRect contentRect = self.contentView.bounds;
  CGRect selfRect = [self bounds];
  
	// In this example we will never be editing, but this illustrates the appropriate pattern
  if (!self.editing) {
    CGRect frame;
    
    //image
    frame = CGRectMake(selfRect.origin.x+10, selfRect.origin.y+1, selfRect.size.height, selfRect.size.height-1);
    spotArt.frame = frame;
    
  }    
}

- (void)dealloc {
  [spotArt release];
  [super dealloc];
}

-(NSString*)artId; 
{
  return spotArt.artId;
}

-(void)setArtId:(NSString*)artId;
{
  spotArt.artId = artId;
}


@end
