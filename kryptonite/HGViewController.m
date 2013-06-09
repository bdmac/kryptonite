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

@interface HGViewController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) id receiveRemoteNotification;
- (void)startSignificantChangeUpdates;
- (void)requestPushPrivilege;
- (void)handleIncidentPush:(NSDictionary *)info;
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
    self.receiveRemoteNotification = [[NSNotificationCenter defaultCenter] addObserverForName:HGIncidentNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self handleIncidentPush:notification.userInfo];
    }];
    self.receiveRemoteNotification = [[NSNotificationCenter defaultCenter] addObserverForName:HGIncidentNotificationForeground object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self handleIncidentPush:notification.userInfo];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestPushPrivilege];
    [self startSignificantChangeUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Private

- (CLLocationManager *)locationManager {
    if (!_locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}

- (void)startSignificantChangeUpdates {
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)requestPushPrivilege {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)handleIncidentPush:(NSDictionary *)info {
    NSLog(@"Got a push notification: %@", info);
    NSString *message = [[info objectForKey:@"aps"] objectForKey:@"alert"];
    NSString *referenceId = [info objectForKey:@"reference_id"];
    NSString *phoneNumber = [info objectForKey:@"phone_number"];
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
        [alert setDestructiveButtonWithTitle:@"Ignore" block:^{
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
        [pfLocation setObject:[PFGeoPoint geoPointWithLocation:location] forKey:@"location"];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [pfLocation setObject:currentInstallation.installationId forKey:@"installation_id"];
        [pfLocation saveInBackground];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Dismised index: %d", buttonIndex);
}
@end
