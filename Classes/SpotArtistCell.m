//
//  SpotArtistCell.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotArtistCell.h"


@implementation SpotArtistCell

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


- (void)dealloc {
    [super dealloc];
}


@end
