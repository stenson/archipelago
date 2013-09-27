//
//  ADKViewController.m
//  Archipelago
//
//  Created by Robert Stenson on 9/27/13.
//  Copyright (c) 2013 ADK. All rights reserved.
//

#import "ADKViewController.h"
#import <MBXMapKit/MBXMapKit.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "CGGeometryAdditions.h"
#import "ADKCountriesTable.h"
#import "ADKCountryCell.h"

#define ECHONEST_API_KEY @"HEJZB8PY3CZFC1I8R"

@interface ADKViewController ()<UITableViewDelegate> {
    UINavigationBar *_navBar;
    BOOL _forceLayout;
    MKMapView *_map;
    ADKCountriesTable *_table;
}
@end

#define MAP_ID @"stenson.map-poqvzkjo"

@implementation ADKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _forceLayout = YES;
    
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
    _navBar.tintColor = [UIColor whiteColor];
    _navBar.barTintColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.6 alpha:1.0];
    [_navBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:@"Countries"] animated:NO];
    //[_navBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:@"Artists"] animated:YES];
    
    UIFont *din = [UIFont fontWithName:@"AvenirNext-Regular" size:20.f];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName:[UIColor whiteColor],
        NSFontAttributeName:din,
    }];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[din fontWithSize:18.f]} forState:UIControlStateNormal];
    
    _map = [[MKMapView alloc] initWithFrame:self.view.bounds];
    //_map = [[MBXMapView alloc] initWithFrame:self.view.bounds mapID:MAP_ID showDefaultBaseLayer:NO];
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(19, -123);
    MKCoordinateRegion adjustedRegion = [_map regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 100, 100)];
    [_map setRegion:adjustedRegion animated:YES];
    
    _table = [[ADKCountriesTable alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _table.delegate = self;
    
    [self.view addSubview:_map];
    [self.view addSubview:_table];
    [self.view addSubview:_navBar];
}

- (void)centerMap
{
    CLLocationCoordinate2D atlantic = CLLocationCoordinate2DMake(45.46, -30.78);
    MKCoordinateSpan span = MKCoordinateSpanMake(90.0, 90.0);
    MKCoordinateRegion region = MKCoordinateRegionMake(atlantic, span);
    [_map setRegion:[_map regionThatFits:region] animated:NO];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_forceLayout) {
        _forceLayout = NO;
        
        _navBar.frame = CGRectTake(self.view.bounds, 64.f, CGRectMinYEdge);
        _table.frame = CGRectTake(self.view.bounds, -64.f, CGRectMaxYEdge);
        
        _map.frame = self.view.bounds;
        [self centerMap];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addEchonestArtistResponseToMap:(NSDictionary *)response
{
//    NSArray *artists = response[@"response"][@"artists"];
//    NSLog(@"%@", artists);
//    
//    CLLocation
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *country = [(ADKCountryCell *)[_table cellForRowAtIndexPath:indexPath] countryName];
    
    [UIView animateWithDuration:0.33f delay:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _table.transform = CGAffineTransformMakeTranslation(0.f, _table.frame.size.height);
    } completion:nil];
    
    [_navBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:country] animated:YES];
    
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = country;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        //MKMapItem *item = response.mapItems[0];
        [_map setRegion:response.boundingRegion animated:YES];
    }];
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{
//        @"api_key": ECHONEST_API_KEY,
//        @"format": @"json",
//        @"artist_location": [NSString stringWithFormat:@"country:%@", country],
//        @"bucket": @"artist_location",
//    };
//    
//    [manager GET:@"http://developer.echonest.com/api/v4/artist/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [self addEchonestArtistResponseToMap:responseObject];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
}

@end
