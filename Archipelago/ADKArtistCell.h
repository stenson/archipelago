//
//  ADKArtistCell.h
//  Archipelago
//
//  Created by Robert Stenson on 9/29/13.
//  Copyright (c) 2013 ADK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADKArtistCell : UITableViewCell

+ (NSAttributedString *)attributedStringForArtistName:(NSString *)artistName;

@property (nonatomic, copy) NSString *name;

@end
