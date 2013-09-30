//
//  ADKCountryCell.m
//  Archipelago
//
//  Created by Robert Stenson on 9/27/13.
//  Copyright (c) 2013 ADK. All rights reserved.
//

#import "ADKCountryCell.h"
#import "CGGeometryAdditions.h"

#define PINK [UIColor colorWithRed:1.f green:0.4f blue:0.5f alpha:0.8f]

@implementation ADKCountryCell

+ (CGRect)boundingRectForWidth:(CGFloat)width attributedCountryName:(NSAttributedString *)attributedCountryName
{
    return [attributedCountryName boundingRectWithSize:CGSizeMake(width, 300.f) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
}

+ (NSAttributedString *)attributedStringForCountryName:(NSString *)countryName
{
    NSDictionary *attrs = @{
        NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Bold" size:18.f],
        NSForegroundColorAttributeName:[UIColor whiteColor],
    };
    return [[NSAttributedString alloc] initWithString:countryName attributes:attrs];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] init];
        //self.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        self.selectedBackgroundView.backgroundColor = PINK;
        self.contentView.backgroundColor = PINK;
        //self.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95f];
    }
    return self;
}

- (void)setCountryName:(NSString *)countryName
{
    _countryName = countryName;
    self.textLabel.attributedText = [ADKCountryCell attributedStringForCountryName:countryName];
    [self setNeedsLayout];
}

- (BOOL)xCoordinateInside:(CGFloat)x
{
    return CGRectContainsPoint(self.contentView.bounds, CGPointMake(x, 20.f));
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounding = [ADKCountryCell boundingRectForWidth:self.bounds.size.width attributedCountryName:self.textLabel.attributedText];
    CGFloat width = bounding.size.width;
    self.contentView.frame = CGRectTake(self.bounds, width + 34.f, CGRectMinXEdge);
    self.selectedBackgroundView.frame = self.contentView.frame;
    self.contentView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
