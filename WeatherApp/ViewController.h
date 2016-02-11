//
//  ViewController.h
//  WeatherApp
//
//  Created by practo on 28/01/16.
//  Copyright © 2016 practo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "CoreLocation/CoreLocation.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UILabel *minMaxTemp;
@property (weak, nonatomic) IBOutlet UIButton *btnCity;
@property (weak, nonatomic) IBOutlet UILabel *weather;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
- (IBAction)btnCityAction:(id)sender;

@end

