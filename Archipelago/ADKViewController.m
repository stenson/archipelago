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
#import <AFNetworking/AFURLRequestSerialization.h>
#import "CGGeometryAdditions.h"
#import "ADKCountriesTable.h"
#import "ADKCountryCell.h"
#import "ADKArtistsTable.h"
#import <Rdio/Rdio.h>

#define ECHONEST_API_KEY @"HEJZB8PY3CZFC1I8R"
#define RDIO_API_KEY @"wfjgaquwyy79wt5ezamvkxfg"
#define RDIO_API_SECRET @"vk3CFKTZK5"

@interface ADKViewController ()<UITableViewDelegate, MKMapViewDelegate, UINavigationBarDelegate, RdioDelegate, RDPlayerDelegate, RDAPIRequestDelegate> {
    UINavigationBar *_navBar;
    BOOL _forceLayout;
    MKMapView *_map;
    ADKCountriesTable *_table;
    ADKArtistsTable *_artists;
    MKPointAnnotation *_currentCountry;
    Rdio *_rdio;
}
@end

#define MAP_ID @"stenson.map-poqvzkjo"
//#define MAP_ID @"stenson.map-k99f0609"

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
    //_map.mapType = MKMapTypeHybrid;
    //_map = [[MBXMapView alloc] initWithFrame:self.view.bounds mapID:MAP_ID showDefaultBaseLayer:NO];
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(19, -123);
    MKCoordinateRegion adjustedRegion = [_map regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 100, 100)];
    [_map setRegion:adjustedRegion animated:YES];
    _map.delegate = self;
    
    _table = [[ADKCountriesTable alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _table.delegate = self;
    
    _artists = [[ADKArtistsTable alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _artists.delegate = self;
    
    [self.view addSubview:_map];
    [self.view addSubview:_artists];
    [self.view addSubview:_table];
    [self.view addSubview:_navBar];
    
    _rdio = [[Rdio alloc] initWithConsumerKey:RDIO_API_KEY andSecret:RDIO_API_SECRET delegate:self];
    _rdio.player.delegate = self;
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
    _artists.hidden = NO;
    NSArray *artists = response[@"response"][@"artists"];
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
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (tableView == _table) {
        [self zoomInToCountryAtIndexPath:indexPath];
    } else if (tableView == _artists) {
        [self zoomToArtistAtIndexPath:indexPath];
    }
}

- (void)zoomInToCountryAtIndexPath:(NSIndexPath *)indexPath
{
    _artists.userInteractionEnabled = YES;
    NSDictionary *countryData = _table.countries[indexPath.row];
    
    UITableViewCell *selectedCell = [_table cellForRowAtIndexPath:indexPath];
    NSArray *cells = [_table visibleCells];
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
    
    NSString *countryName = countryData[@"name"];
    [_navBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:countryName] animated:YES];
    
    [self centerMapOnCountry:countryData];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *safeCountry = [countryName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *parameters = [NSString stringWithFormat:@"?api_key=%@&format=json&artist_location=country:%@&bucket=artist_location&bucket=id:rdio-US&results=50", ECHONEST_API_KEY, safeCountry];
    NSString *url = [@"http://developer.echonest.com/api/v4/artist/search" stringByAppendingString:parameters];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self addEchonestArtistResponseToMap:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)zoomOutToCountry
{
    _artists.userInteractionEnabled = YES;
    NSDictionary *countryData = _table.countries[[_table indexPathForSelectedRow].row];
    [self centerMapOnCountry:countryData];
}

- (void)centerMapOnCountry:(NSDictionary *)countryData
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([countryData[@"lat"] floatValue], [countryData[@"lon"] floatValue]);
    CLLocationCoordinate2D adjusted = CLLocationCoordinate2DMake(center.latitude, center.longitude + 15.f);
    if (CLLocationCoordinate2DIsValid(adjusted) == NO) {
        adjusted = center;
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMake(adjusted, MKCoordinateSpanMake(50.f, 50.f));
    
    [_map setRegion:[_map regionThatFits:region] animated:YES];
    
    [_map removeAnnotations:[_map annotations]];
    MKPointAnnotation *currentCountry = [[MKPointAnnotation alloc] init];
    currentCountry.coordinate = center;
    [_map addAnnotation:currentCountry];
}

- (void)zoomToArtistAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *artistData = _artists.artists[indexPath.row];
    
    NSArray *foreignIds = artistData[@"foreign_ids"];
    if (foreignIds.count > 0) {
        NSString *rdioId = [foreignIds[0][@"foreign_id"] stringByReplacingOccurrencesOfString:@"rdio-US:artist:" withString:@""];
        [_rdio callAPIMethod:@"getTracksForArtist" withParameters:@{@"artist": rdioId} delegate:self];
    }
    
    [_artists animateCellExitsWithCompletion:nil];
    _artists.userInteractionEnabled = NO;
    
    [_navBar pushNavigationItem:[[UINavigationItem alloc] initWithTitle:artistData[@"name"]] animated:YES];
    
    [self performLocalSearchForNaturalLanguageQuery:artistData[@"artist_location"][@"location"] completionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response) {
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            [point setCoordinate:response.boundingRegion.center];
            [point setTitle:artistData[@"name"]];
            [_map removeAnnotations:[_map annotations]];
            [_map addAnnotation:point];
            [_map setRegion:[self adjustedRegionFromRegion:response.boundingRegion pushFromEdge:CGRectMaxYEdge] animated:YES];
        } else {
            NSLog(@"dud");
        }
    }];
}

- (MKCoordinateRegion)adjustedRegionFromRegion:(MKCoordinateRegion)originalRegion pushFromEdge:(CGRectEdge)edge
{
    MKCoordinateRegion region = originalRegion;
    switch (edge) {
        case CGRectMaxXEdge: {
            region.center.longitude += region.span.longitudeDelta/1.5f;
        } break;
        case CGRectMinXEdge: {
            region.center.longitude -= region.span.longitudeDelta/1.5f;
        } break;
        case CGRectMinYEdge: {
            region.center.latitude += region.span.latitudeDelta/1.5f;
        } break;
        case CGRectMaxYEdge: {
            region.center.latitude -= region.span.latitudeDelta/1.5f;
        } break;
    }
    
    region.span.longitudeDelta = region.span.longitudeDelta * 3.f;
    return region;
}

#pragma mark - UINavigationBarDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if (navigationBar.items.count > 2) {
        [self popArtistSelection];
    } else {
        [self popCountrySelection];
    }
    
    return YES;
}

- (void)popCountrySelection
{
    _artists.userInteractionEnabled = NO;
    [_artists animateCellExitsWithCompletion:^(BOOL finished) {
        _artists.hidden = YES;
        [_artists setContentOffset:CGPointMake(0.f, 0.f)];
    }];
    
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
}

- (void)popArtistSelection
{
    [self zoomOutToCountry];
    [_artists animateCellEntrances];
    _artists.userInteractionEnabled = YES;
}

#pragma mark - RdioDelegate

- (void)rdioDidAuthorizeUser:(NSDictionary *)user withAccessToken:(NSString *)accessToken
{
    
}

- (void)rdioAuthorizationFailed:(NSString *)error
{
    
}

#pragma mark - RDPlayerDelegate

- (void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState
{
    
}

//- (BOOL)rdioPlayerCouldNotStreamTrack:(NSString *)trackKey
//{
//    
//}

#pragma mark - RDAPIRequestDelegate

- (void)rdioRequest:(RDAPIRequest *)request didLoadData:(NSArray *)data
{
    NSLog(@"rdio request load: %@ %@", request, data);
    [_rdio.player stop];
    [_rdio.player playSource:data[0][@"key"]];
}

- (void)rdioRequest:(RDAPIRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"rdio request error: %@", error);
}

@end
