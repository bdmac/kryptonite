//
//  HGViewController.h
//  kryptonite
//
//  Created by Brian McManus on 6/8/13.
//  Copyright (c) 2013 Brian McManus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HGViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *welcomeImage;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@end
