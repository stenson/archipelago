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
#import "ADKArtistsTable.h"

#define ECHONEST_API_KEY @"HEJZB8PY3CZFC1I8R"

@interface ADKViewController ()<UITableViewDelegate, MKMapViewDelegate, UINavigationBarDelegate> {
    UINavigationBar *_navBar;
    BOOL _forceLayout;
    MKMapView *_map;
    ADKCountriesTable *_table;
    ADKArtistsTable *_artists;
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
    _navBar.barTintColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.4 alpha:1.0];
    _navBar.barTintColor = [UIColor colorWithRed:0.f green:0.6f blue:0.5f alpha:1.f];
    //_navBar.barTintColor = [UIColor colorWithWhite:1.f alpha:1.f];
    _navBar.delegate = self;
    [_navBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:@"Countries"] animated:NO];
    
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
    _map.delegate = self;
    
    _table = [[ADKCountriesTable alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _table.delegate = self;
    
    _artists = [[ADKArtistsTable alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    [self.view addSubview:_map];
    [self.view addSubview:_artists];
    [self.view addSubview:_table];
    [self.view addSubview:_navBar];
}

- (void)centerMapAnimated:(BOOL)animated
{
    CLLocationCoordinate2D atlantic = CLLocationCoordinate2DMake(45.46, -30.78);
    MKCoordinateSpan span = MKCoordinateSpanMake(90.0, 90.0);
    MKCoordinateRegion region = MKCoordinateRegionMake(atlantic, span);
    [_map setRegion:[_map regionThatFits:region] animated:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_forceLayout) {
        _forceLayout = NO;
        
        _navBar.frame = CGRectTake(self.view.bounds, 64.f, CGRectMinYEdge);
        _table.frame = self.view.bounds;
        _artists.frame = _table.frame;
        
        _map.frame = self.view.bounds;
        [self centerMapAnimated:NO];
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
    NSArray *artists = response[@"response"][@"artists"];
    
    for (NSDictionary *artist in artists) {
        [self performLocalSearchForNaturalLanguageQuery:artist[@"artist_location"][@"location"] completionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            if (response) {
                MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                [point setCoordinate:response.boundingRegion.center];
                [point setTitle:artist[@"name"]];
                [_map addAnnotation:point];
            } else {
                NSLog(@"dud");
            }
        }];
    }
    
    _artists.artists = artists;
}

- (void)performLocalSearchForNaturalLanguageQuery:(NSString *)nlQuery completionHandler:(MKLocalSearchCompletionHandler)completionHandler
{
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = nlQuery;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [search startWithCompletionHandler:completionHandler];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *country = [(ADKCountryCell *)[_table cellForRowAtIndexPath:indexPath] countryName];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSArray *cells = [tableView visibleCells];
    NSTimeInterval delay = 0.f;
    for (UITableViewCell *cell in cells) {
        if (cell != selectedCell) {
            [UIView animateWithDuration:0.25f delay:delay += 0.04f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                cell.transform = CGAffineTransformMakeTranslation(-cell.contentView.frame.size.width, 0.f);
            } completion:nil];
        }
    }
    
    _table.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.33f delay:delay options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _table.alpha = 0.f;
    } completion:^(BOOL finished) {
        _table.hidden = YES;
    }];
    
    [_navBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:country] animated:YES];
    
    [self performLocalSearchForNaturalLanguageQuery:country completionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        MKCoordinateRegion region = response.boundingRegion;
        NSLog(@"%f %f", region.center.latitude, region.span.latitudeDelta);
        region.span = MKCoordinateSpanMake(region.span.latitudeDelta * 4.f, region.span.longitudeDelta);
        [_map setRegion:region animated:YES];
    }];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
        @"api_key": ECHONEST_API_KEY,
        @"format": @"json",
        @"artist_location": [NSString stringWithFormat:@"country:%@", country],
        @"bucket": @"artist_location",
    };
    
    [manager GET:@"http://developer.echonest.com/api/v4/artist/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self addEchonestArtistResponseToMap:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

#pragma mark - UINavigationBarDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    [_artists animateCellExits];
    
    _table.hidden = NO;
    [UIView animateWithDuration:0.25f animations:^{
        _table.alpha = 1.f;
    } completion:^(BOOL finished) {
        _table.userInteractionEnabled = YES;
    }];
    
    [self centerMapAnimated:YES];
    [_map removeAnnotations:[_map annotations]];
    
    NSArray *cells = [_table visibleCells];
    NSTimeInterval delay = cells.count * 0.05f;
    for (UITableViewCell *cell in cells) {
        [UIView animateWithDuration:0.25f delay:delay -= 0.05f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            cell.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    return YES;
}

//- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
//{
//    [_artists animateCellExits];
//    
//    _table.hidden = NO;
//    [UIView animateWithDuration:0.25f animations:^{
//        _table.alpha = 1.f;
//    } completion:^(BOOL finished) {
//        _table.userInteractionEnabled = YES;
//    }];
//    
//    [self centerMapAnimated:YES];
//    [_map removeAnnotations:[_map annotations]];
//    
//    NSArray *cells = [_table visibleCells];
//    NSTimeInterval delay = cells.count * 0.05f;
//    for (UITableViewCell *cell in cells) {
//        [UIView animateWithDuration:0.25f delay:delay -= 0.05f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//            cell.transform = CGAffineTransformIdentity;
//        } completion:nil];
//    }
//}

@end
