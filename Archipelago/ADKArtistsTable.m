//
//  ADKArtistsTable.m
//  Archipelago
//
//  Created by Robert Stenson on 9/29/13.
//  Copyright (c) 2013 ADK. All rights reserved.
//

#import "ADKArtistsTable.h"
#import "ADKArtistCell.h"

@interface ADKArtistsTable ()<UITableViewDataSource, UITableViewDelegate> {
    BOOL _entranceAnimated;
}
@end

#define REUSE @"Cell"

@implementation ADKArtistsTable

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[ADKArtistCell class] forCellReuseIdentifier:REUSE];
    }
    return self;
}

- (void)setArtists:(NSArray *)artists
{
    _artists = artists;
    _entranceAnimated = NO;
    [self reloadData];
    
    for (ADKArtistCell *cell in [self visibleCells]) {
        cell.hidden = YES;
    }
    
    [self performSelector:@selector(animateCellEntrances) withObject:nil afterDelay:0.25f];
}

- (void)animateCellEntrances
{
    _entranceAnimated = YES;
    CGFloat delay = 0.f;
    for (ADKArtistCell *cell in self.visibleCells) {
        cell.hidden = NO;
        cell.transform = CGAffineTransformMakeTranslation(cell.contentView.frame.size.width, 0.f);
        [UIView animateWithDuration:0.25f delay:(delay += 0.05f) options:0 animations:^{
            cell.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

- (void)animateCellExits
{
    CGFloat delay = 0.f;
    for (ADKArtistCell *cell in [self.visibleCells reverseObjectEnumerator]) {
        [UIView animateWithDuration:0.25f delay:(delay += 0.05f) options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            cell.transform = CGAffineTransformMakeTranslation(cell.contentView.frame.size.width, 0.f);
        } completion:^(BOOL finished) {
            cell.transform = CGAffineTransformIdentity;
            cell.hidden = YES;
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _artists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ADKArtistCell *cell = (ADKArtistCell *)[self dequeueReusableCellWithIdentifier:REUSE forIndexPath:indexPath];
    NSDictionary *artist = (NSDictionary *)_artists[indexPath.row];
    cell.name = artist[@"name"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_entranceAnimated) {
        //[self performSelector:@selector(animateEntranceForCell:) withObject:cell afterDelay:0.1f];
        
        //[UIView animateWithDuration:0.25f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        //cell.contentView.transform = CGAffineTransformMakeTranslation(-cell.contentView.frame.size.width, 0.f);;
        //} completion:nil];
    }
}

- (void)animateEntranceForCell:(ADKArtistCell *)cell
{
    //cell.contentView.transform = CGAffineTransformIdentity;
    //cell.contentView.transform = CGAffineTransformMakeTranslation(-cell.contentView.frame.size.width, 0.f);
    //NSLog(@"cell %@", NSStringFromCGAffineTransform(cell.contentView.transform));
}

@end
