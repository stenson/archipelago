//
//  ADKCountryCell.h
//  Archipelago
//
//  Created by Robert Stenson on 9/27/13.
//  Copyright (c) 2013 ADK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADKCountryCell : UITableViewCell

+ (CGRect)boundingRectForWidth:(CGFloat)width attributedCountryName:(NSAttributedString *)attributedCountryName;
+ (NSAttributedString *)attributedStringForCountryName:(NSString *)countryName;

@property (nonatomic, copy) NSString *countryName;

- (BOOL)xCoordinateInside:(CGFloat)x;

@end
