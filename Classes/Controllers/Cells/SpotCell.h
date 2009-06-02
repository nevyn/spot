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
  UILabel *subTitle;
  UILabel *bottomTitle;
  UIProgressView *popularity;
}

- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold;

-(void)setTitle:(NSString *)title subTitle:(NSString*)subTitle bottomTitle:(NSString *)bottomTile popularity:(float)popularity image:(BOOL)image imageId:(NSString*)imageId;

@property (nonatomic, retain) UILabel *title;
@property (nonatomic, retain) UILabel *subTitle;
@property (nonatomic, retain) UILabel *bottomTitle;
@property (nonatomic, retain) UIProgressView *popularity;

@end
