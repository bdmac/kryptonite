//
//  HGViewController.m
//  kryptonite
//
//  Created by Brian McManus on 6/8/13.
//  Copyright (c) 2013 Brian McManus. All rights reserved.
//

#import "HGViewController.h"
#import "HGAppDelegate.h"
#import <Parse/Parse.h>
#import "BlockAlertView.h"
#import "PhoneNumberFormatter.h"
#import "HGIncidentView.h"
#import "SORelativeDateTransformer.h"
#import <QuartzCore/QuartzCore.h>

@interface HGViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) id receiveRemoteNotification;
@property (nonatomic, assign) id didEnterBackgroundNotification;
@property (nonatomic, assign) id willEnterForegroundNotification;
@property (nonatomic, strong) PFGeoPoint *lastLocation;
@property (nonatomic, strong) NSArray *incidents;
- (void)startStandardUpdates;
- (void)startSignificantChangeUpdates;
- (void)requestPushPrivilege;
- (void)handleIncidentPush:(PFObject *)incident;
- (void)refreshIncidents;
- (PFObject *)incidentFromPush:(NSDictionary *)info;
@end

@implementation HGViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.receiveRemoteNotification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        self.welcomeImage.image = [UIImage imageNamed:@"Default-568h"];
    } else {
        self.welcomeImage.image = [UIImage imageNamed:@"Default"];
    }
    self.didEnterBackgroundNotification = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *notification) {
        [self startSignificantChangeUpdates];
    }];
    self.willEnterForegroundNotification = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication] queue:nil usingBlock:^(NSNotification *notification) {
        [self startStandardUpdates];
    }];
    self.receiveRemoteNotification = [[NSNotificationCenter defaultCenter] addObserverForName:HGIncidentNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self handleIncidentPush:[self incidentFromPush:notification.userInfo]];
    }];
    self.receiveRemoteNotification = [[NSNotificationCenter defaultCenter] addObserverForName:HGIncidentNotificationForeground object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self handleIncidentPush:[self incidentFromPush:notification.userInfo]];
    }];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    if (self.lastLocation) {
        [self refreshIncidents];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestPushPrivilege];
    [self startStandardUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    // _data is a class member variable that contains one array per section.
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.incidents count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *incident = [self.incidents objectAtIndex:indexPath.row];
    SORelativeDateTransformer *relativeDateTransformer = [[SORelativeDateTransformer alloc] init];
    NSString *relativeTime = [relativeDateTransformer transformedValue:[incident objectForKey:@"date"]];
    HGIncidentView* newCell = (HGIncidentView *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    newCell.incidentLabel.text = [incident objectForKey:@"description"];
    newCell.timeLabel.text = relativeTime;
    if ([[incident objectForKey:@"phoneNumber"] length] > 0) {
        newCell.layer.borderColor = [[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0 blue:0.0f alpha:0.9f] CGColor];
        newCell.warningImageView.hidden = NO;
    }
    else {
        newCell.layer.borderColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.9f] CGColor];
        newCell.warningImageView.hidden = YES;
    }

    return newCell;
}

# pragma mark - UIColledctionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *incident = [self.incidents objectAtIndex:indexPath.row];
    [self handleIncidentPush:incident];
}

# pragma mark - Private

- (void)refreshIncidents {
    self.incidentsLabel.text = @"Finding incidents...";
    PFQuery *query = [PFQuery queryWithClassName:@"Incident"];
    [query whereKey:@"location" nearGeoPoint:self.lastLocation withinMiles:1.0];
    NSDate *yesterday = [[NSDate date] dateByAddingTimeInterval:-86400];
    [query whereKey:@"date" greaterThanOrEqualTo:yesterday];
    [query orderByDescending:@"date"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.incidents = objects;
        if (self.incidents.count > 0) {
            self.incidentsLabel.text = @"Nearby incidents within 24 hours.";
        }
        else {
            self.incidentsLabel.text = @"No recent nearby incidents to show.";
        }
        [self.collectionView reloadData];
    }];
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)startSignificantChangeUpdates {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)startStandardUpdates {
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 50;
    
    [self.locationManager startUpdatingLocation];
}

- (void)requestPushPrivilege {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (PFObject *)incidentFromPush:(NSDictionary *)info {
    PFObject *incident = [PFObject objectWithClassName:@"Incident"];
    [incident setObject:[[info objectForKey:@"aps"] objectForKey:@"alert"] forKey:@"description"];
    [incident setObject:[info objectForKey:@"reference_id"] forKey:@"incidentNumber"];
    [incident setObject:[info objectForKey:@"phone_number"] forKey:@"phoneNumber"];
    return incident;
}

- (void)handleIncidentPush:(PFObject *)incident {
    NSLog(@"Got a push notification: %@", incident);
    NSString *message = [incident objectForKey:@"description"];
    NSString *referenceId = [incident objectForKey:@"incidentNumber"];
    NSString *phoneNumber = [incident objectForKey:@"phoneNumber"];
    id rawPhone;
    if (phoneNumber.length > 0) {
        PhoneNumberFormatter *formatter = [[PhoneNumberFormatter alloc] init];
        phoneNumber = [formatter stringForObjectValue:phoneNumber];
        NSError *error;
        [formatter getObjectValue:&rawPhone forString:phoneNumber errorDescription:&error];
        message = [NSString stringWithFormat:@"%@\n\nYou appear to have been nearby. If you have information reference #%@.", message, referenceId];
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Law Enforcement Request"
                                                       message:message];
        [alert addButtonWithTitle:[NSString stringWithFormat:@"Call %@", phoneNumber] block:^{
            NSString *stringURL = [NSString stringWithFormat:@"tel:%@", rawPhone];
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];
        }];
        [alert addButtonWithTitle:[NSString stringWithFormat:@"Text %@", phoneNumber] block:^{
            NSString *stringURL = [NSString stringWithFormat:@"sms:%@", rawPhone];
            NSURL *url = [NSURL URLWithString:stringURL];
            [[UIApplication sharedApplication] openURL:url];
        }];
        [alert setDestructiveButtonWithTitle:@"Cancel" block:^{
        }];
        [alert show];
    }
    else {
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"Incident Alert"
                                                       message:message];
        [alert setCancelButtonWithTitle:@"Thanks!" block:nil];
        [alert show];
    }
}

# pragma mark - CLLocationManagerDelegate methods

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        PFObject *pfLocation = [PFObject objectWithClassName:@"Location"];
        self.lastLocation = [PFGeoPoint geoPointWithLocation:location];
        [pfLocation setObject:self.lastLocation forKey:@"location"];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [pfLocation setObject:currentInstallation.installationId forKey:@"installation_id"];
        [pfLocation saveInBackground];
        [self refreshIncidents];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Dismised index: %d", buttonIndex);
}
@end
