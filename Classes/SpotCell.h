//
//  SpotCell.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotImageCell.h"
//Image and 2 labels

@interface SpotCell : SpotImageCell {
  UILabel *title;
  UILabel *subText;
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *subText;

@end
