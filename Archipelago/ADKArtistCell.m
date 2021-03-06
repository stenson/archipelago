//
//  ADKArtistCell.m
//  Archipelago
//
//  Created by Robert Stenson on 9/29/13.
//  Copyright (c) 2013 ADK. All rights reserved.
//

#import "ADKArtistCell.h"
#import "CGGeometryAdditions.h"
#import <Archimedes.h>

@interface ADKArtistCell () {
    BOOL _forceLayout;
}
@end

#define BLUE [UIColor colorWithRed:0.4f green:0.5f blue:1.f alpha:0.8f]

@implementation ADKArtistCell

+ (NSAttributedString *)attributedStringForArtistName:(NSString *)artistName
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    
    return [[NSAttributedString alloc] initWithString:artistName attributes:@{
        NSForegroundColorAttributeName:[UIColor whiteColor],
        NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Bold" size:15.f],
        NSParagraphStyleAttributeName: style,
    }];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _forceLayout = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = BLUE;
        self.contentView.backgroundColor = BLUE;
    }
    return self;
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.textLabel.attributedText = [ADKArtistCell attributedStringForArtistName:name];
    self.contentView.transform = CGAffineTransformIdentity;
    _forceLayout = YES;
    [self setNeedsLayout];
}

- (BOOL)xCoordinateInside:(CGFloat)x
{
    return CGRectContainsPoint(self.contentView.frame, CGPointMake(x, 20.f));
}

- (void)layoutSubviews
{
    if (_forceLayout == YES) {
        _forceLayout = NO;
        
        [super layoutSubviews];
        CGRect bounding = [self.textLabel.attributedText boundingRectWithSize:self.frame.size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesDeviceMetrics context:nil];
        CGFloat width = floorf(bounding.size.width + 40.f);
        self.contentView.frame = MEDRectSlice(self.bounds, width, CGRectMaxXEdge);
        self.textLabel.frame = self.contentView.bounds;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
