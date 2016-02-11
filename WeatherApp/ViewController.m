//
//  ViewController.m
//  WeatherApp
//
//  Created by practo on 28/01/16.
//  Copyright © 2016 practo. All rights reserved.
//

#import "ViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) CLLocationManager *locationManager;

@end

@implementation ViewController

NSMutableDictionary *notesJSON;
NSMutableDictionary *notesHourlyJSON;
NSMutableDictionary *notesDailyJSON;
int flag=0;
NSString *cityname,*countrycode;
NSString *imageUrl;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIImage *background = [UIImage imageNamed:@"Images/bg"];

    [self.backgroundImageView setImage:background];
   // [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
   
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.blurredImageView];
    [self.view addSubview:self.tableView];
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    notesJSON = [[NSMutableDictionary alloc] init];
    

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if(newLocation == nil)
        return;
    [_locationManager stopUpdatingLocation];
    CLLocationCoordinate2D currentLocation;
    currentLocation = newLocation.coordinate;
    
    [self currentLocationForecast:currentLocation];
    [self hourlyForecast:currentLocation];
    [self dailyForecast:currentLocation];

    
}

-(void)getImageUrl:(NSString*)img
{
    imageUrl = [NSString stringWithFormat:@"Images/Weather Icons/weather-%@",[img lowercaseString]];
}

-(void)currentLocationForecast:(CLLocationCoordinate2D) currentLocation{
    NSString *url;
    if(flag==0) {
        url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=44db6a862fba0b067b1930da0d769e98",currentLocation.latitude, currentLocation.longitude];
    } else {
        url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@,%@&appid=44db6a862fba0b067b1930da0d769e98",cityname,countrycode];
    }
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"data received");
        
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (httpResp.statusCode == 200) {
            
            NSError *jsonError;
            notesJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.btnCity setTitle:[notesJSON objectForKey:@"name"] forState:UIControlStateNormal];
                
                self.temp.text = [NSString stringWithFormat:@"%.1f°",[[[notesJSON objectForKey:@"main"] objectForKey:@"temp"] doubleValue]-273.15];
                
                self.weather.text = [[[notesJSON objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"];
                [self getImageUrl:self.weather.text];
                self.iconView.image = [UIImage imageNamed:imageUrl];
                
                self.minMaxTemp.text = [NSString stringWithFormat:@"%.1f° / %.1f°",[[[notesJSON objectForKey:@"main"] objectForKey:@"temp_max"] doubleValue]-273.15 ,[[[notesJSON objectForKey:@"main"] objectForKey:@"temp_max"]doubleValue]-273.15];
            });
        }
    }];
    [dataTask resume];
}

-(void)hourlyForecast:(CLLocationCoordinate2D) currentLocation {

    NSString *url;
    if(flag==0) {
        url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&cnt=7&appid=44db6a862fba0b067b1930da0d769e98",currentLocation.latitude, currentLocation.longitude];
    } else {
        url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?q=%@,%@&appid=44db6a862fba0b067b1930da0d769e98",cityname,countrycode];
    }
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
  //  NSLog(url);
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"data received");
        
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (httpResp.statusCode == 200) {
            
            NSError *jsonError;
            notesHourlyJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        }
    }];
    [dataTask resume];
}

-(void)dailyForecast:(CLLocationCoordinate2D) currentLocation {
    
    NSString *url;
    if(flag==0) {
        url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=16&appid=44db6a862fba0b067b1930da0d769e98",currentLocation.latitude, currentLocation.longitude];
    } else {
        url = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@,%@&cnt=16&appid=44db6a862fba0b067b1930da0d769e98",cityname,countrycode];
    }

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"data received");
        
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (httpResp.statusCode == 200) {
            NSError *jsonError;
            notesDailyJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        }
    }];
    [dataTask resume];
}


// 1
#pragma mark - UITableViewDataSource


// 2

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    // 3
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Hourly Forecast";
            cell.detailTextLabel.text = @"";
            cell.textLabel.font = [UIFont systemFontOfSize:30.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:30.0];
            cell.imageView.image = nil;

        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h a"];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:
                            [[[[notesHourlyJSON objectForKey:@"list"] objectAtIndex:indexPath.row-1] objectForKey:@"dt"] doubleValue]];
            NSString *formattedDateString = [dateFormatter stringFromDate:date];
            cell.textLabel.text = formattedDateString;
           
            [self getImageUrl:[[[[[notesHourlyJSON objectForKey:@"list"] objectAtIndex:indexPath.row-1] objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"]];
            
            cell.imageView.image = [UIImage imageNamed:imageUrl];
            
            cell.detailTextLabel.text =[NSString stringWithFormat:@"%.1f°",[[[[[notesHourlyJSON objectForKey:@"list"] objectAtIndex:indexPath.row-1] objectForKey:@"main"] objectForKey:@"temp"] doubleValue]-273.15];
            cell.textLabel.font = [UIFont systemFontOfSize:22.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:22.0];
        }
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Daily Forecast";
            cell.detailTextLabel.text = @"";
            cell.textLabel.font = [UIFont systemFontOfSize:30.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:30.0];
            cell.imageView.image = nil;
            
        } else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:
                            [[[[notesDailyJSON objectForKey:@"list"] objectAtIndex:indexPath.row] objectForKey:@"dt"] doubleValue]];
            NSString *formattedDateString = [dateFormatter stringFromDate:date];
            cell.textLabel.text = formattedDateString;
            
            [self getImageUrl:[[[[[notesDailyJSON objectForKey:@"list"] objectAtIndex:indexPath.row] objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"]];
            
            cell.imageView.image = [UIImage imageNamed:imageUrl];

            cell.detailTextLabel.text =[NSString stringWithFormat:@"%.1f°/%.1f°",[[[[[notesDailyJSON objectForKey:@"list"] objectAtIndex:indexPath.row] objectForKey:@"temp"] objectForKey:@"max"] doubleValue]-273.15,[[[[[notesDailyJSON objectForKey:@"list"] objectAtIndex:indexPath.row] objectForKey:@"temp"] objectForKey:@"min"] doubleValue]-273.15];
            cell.textLabel.font = [UIFont systemFontOfSize:22.0];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:22.0];
        }
    }

    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    [self.blurredImageView setImageToBlur:[UIImage imageNamed:@"Images/bg"] blurRadius:2 completionBlock:nil];
    self.blurredImageView.alpha = percent;
}

- (IBAction)btnCityAction:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Weather Search" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = NSLocalizedString(@"City Name", @"Delhi");
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = NSLocalizedString(@"Country Code", @"in");
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                                   spinner.center = self.view.center;
                                   spinner.hidesWhenStopped = YES;
                                   [self.view addSubview:spinner];
                                   [spinner startAnimating];

                                   dispatch_queue_t downloadQueue = dispatch_queue_create("downloader", NULL);
                                   dispatch_async(downloadQueue, ^{
                                       
                                       // do our long running process here
                                       [NSThread sleepForTimeInterval:1];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [spinner stopAnimating];
                                           cityname = [alertController.textFields objectAtIndex:0].text;
                                           countrycode = [alertController.textFields objectAtIndex:1].text;
                                           
                                           flag=1;
                                           
                                           CLLocationCoordinate2D currentLocation;
                                           [self currentLocationForecast:currentLocation];
                                           [self hourlyForecast:currentLocation];
                                           [self dailyForecast:currentLocation];
                                           flag=0;
                                       });
                                       
                                   });
                                   
                                //   [spinner stopAnimating];
                                   
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
