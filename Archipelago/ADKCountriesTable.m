//
//  ADKCountriesTable.m
//  Archipelago
//
//  Created by Robert Stenson on 9/27/13.
//  Copyright (c) 2013 ADK. All rights reserved.
//

#import "ADKCountriesTable.h"
#import "CGGeometryAdditions.h"
#import "ADKCountryCell.h"

@interface ADKCountriesTable ()<UITableViewDataSource, UITableViewDelegate> {
    NSArray *_countries;
}
@end

#define REUSE @"Cell"

@implementation ADKCountriesTable

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        self.dataSource = self;
        
        [self registerClass:[ADKCountryCell class] forCellReuseIdentifier:REUSE];
        _countries = [self countriesFromJSON];
    }
    return self;
}

- (NSArray *)countriesFromJSON
{
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    NSString *countries = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSData *data = [countries dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    return array;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _countries.count;
}

- (NSAttributedString *)attributedStringForIndexPath:(NSIndexPath *)indexPath
{
    return [ADKCountryCell attributedStringForCountryName:_countries[indexPath.row][@"name"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAttributedString *name = [self attributedStringForIndexPath:indexPath];
    CGRect rect = [ADKCountryCell boundingRectForWidth:self.bounds.size.width attributedCountryName:name];
    return rect.size.height + 20.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ADKCountryCell *cell = [self dequeueReusableCellWithIdentifier:REUSE forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.countryName = _countries[indexPath.row][@"name"];
    return cell;
}

@end
