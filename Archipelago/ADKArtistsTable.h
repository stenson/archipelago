//
//  ADKArtistsTable.h
//  Archipelago
//
//  Created by Robert Stenson on 9/29/13.
//  Copyright (c) 2013 ADK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADKArtistsTable : UITableView

@property (nonatomic, copy) NSArray *artists;

- (void)animateCellExits;

@end
