//
//  LocationConfigViewController.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-17.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "LocationConfigViewController.h"

@interface LocationConfigViewController ()

@end

@implementation LocationConfigViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    appDelegate = (TimesheetAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    distanceOptionIndex = appDelegate.locationDistanceIndex;
    
    if( !appDelegate.enableLocation )
        self.navigationItem.rightBarButtonItem = nil;
    
    // O index 0 é quando está desabilitado
    if( distanceOptionIndex > 0 ){
     
        NSArray *location = [appDelegate.workplaceLocation componentsSeparatedByString:@","];
        float latitude    = [[location objectAtIndex:0] floatValue];
        float longitude   = [[location objectAtIndex:1] floatValue];
        myLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        [self selectFirstLocationOption];
        [self foundLocation];
    }
    
    [switchLocation setOn: appDelegate.enableLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
-(void)selectFirstLocationOption {
    
    NSLog(@"selectFirstLocationOption");
    
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
//    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    NSLog(@"distanceOptionIndex: %i", distanceOptionIndex);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:distanceOptionIndex inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
//    [self.tableView reloadData];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    switch ( section ) {
        case 0:
            // Return the number of rows in the section.
            if( switchLocation.isOn )
                return 7;
            else
                return 1;
            break;
            
        case 1:
            if( switchLocation.isOn )
                return 2;
            else
                return 0;
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
 
    switch ( section ) {
        case 0:
            if( !switchLocation.isOn )
                return @"Ao habilitar o serviço de localização você será notificado quando entrar ou sair da área definida para que seja lembrado de registrar o horário";
            else
                return @"Define o raio de entrada e saída da área de notificação de registro de horário";
            break;
        case 1:
            if( switchLocation.isOn )
                return appDelegate.workplaceAddress;
            else
                return @"";
        default:
            break;
    }
    
    return @"";
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if( indexPath.row==0 || indexPath.section > 0 )
        return;
    
    UITableViewCell *cell;
    
    if( distanceOptionIndex != indexPath.row ){
        
        cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:distanceOptionIndex inSection:0]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    distanceOptionIndex = indexPath.row;
    
    appDelegate.locationDistanceIndex = distanceOptionIndex;
    [appDelegate updateUserInfo];
}

- (IBAction)changeSwitchLocation:(id)sender {

    NSArray *rowSection0List = [[NSArray alloc] initWithObjects:
                                [NSIndexPath indexPathForRow:1 inSection:0],
                                [NSIndexPath indexPathForRow:2 inSection:0],
                                [NSIndexPath indexPathForRow:3 inSection:0],
                                [NSIndexPath indexPathForRow:4 inSection:0],
                                [NSIndexPath indexPathForRow:5 inSection:0],
                                [NSIndexPath indexPathForRow:6 inSection:0],nil];
    
    NSArray *rowSection1List = [[NSArray alloc] initWithObjects:
                                [NSIndexPath indexPathForRow:0 inSection:1],
                                [NSIndexPath indexPathForRow:1 inSection:1],nil];
    
    [self.tableView beginUpdates];
    
    if( switchLocation.isOn ){
        
        NSLog(@"distanceOptionIndex: %i", distanceOptionIndex);
        
        [self.tableView insertRowsAtIndexPaths:rowSection0List withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:rowSection1List withRowAnimation:UITableViewRowAnimationFade];
        appDelegate.enableLocation = YES;
        appDelegate.locationDistanceIndex = distanceOptionIndex;
        self.navigationItem.rightBarButtonItem = btnRedefineLocation;
        
        [appDelegate updateUserInfo];
        
        [self findLocation];
    }else{
        
        [self.tableView deleteRowsAtIndexPaths:rowSection0List withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deleteRowsAtIndexPaths:rowSection1List withRowAnimation:UITableViewRowAnimationFade];
        
//        distanceOptionIndex = 0;
        appDelegate.enableLocation = NO;
        appDelegate.locationDistanceIndex = 0;
        self.navigationItem.rightBarButtonItem = nil;

        [appDelegate updateUserInfo];
    }
    
    [self.tableView endUpdates];
//    [self.tableView reloadData];
    
    if( switchLocation.isOn ){
        
        if( distanceOptionIndex == 0 ){
            
            distanceOptionIndex = 3;
            [self selectFirstLocationOption];
        }
    }
}

- (IBAction)btnRedefineLocationClick:(id)sender {
    
    [self findLocation];
}



-(void)findLocation {
    
    if( locationManager != nil ){
        
        [locationManager startUpdatingLocation];
        [btnRedefineLocation setEnabled:NO];
        return;
    }
    
    // Cria um objeto location manager
    locationManager = [[CLLocationManager alloc] init];
    
    // Define a classe WhereamiAppDelegate como o delegate do objeto criado
    // isso vai enviar as chamadas para o WhereamiAppDelegate
    [locationManager setDelegate:self];
    
    // distanceFilter define a distancia que o aparelho deve percorrer
    // antes de notificar o delegate
    // Nos queremos todos os resultados do location manager
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    // E nos queremos que seja o mais preciso possivel
    // independente de quanto tempo/bateria isso consuma
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    // Diz ao manager para iniciar a procura pela localização imediatamente
    [locationManager startUpdatingLocation];
}

-(void)foundLocation {
    
    if( myLocation!=nil ){
        
        NSLog(@"myLocation: %@", myLocation);
        
        lblLatitude.text  = [NSString stringWithFormat:@"%f", myLocation.coordinate.latitude];
        lblLongitude.text = [NSString stringWithFormat:@"%f", myLocation.coordinate.longitude];
        
        appDelegate.workplaceLocation = [NSString stringWithFormat:@"%f,%f", myLocation.coordinate.latitude, myLocation.coordinate.longitude];
        
        
        
        [appDelegate updateUserInfo];
    }
    
    [locationManager stopUpdatingLocation];
    
    [btnRedefineLocation setEnabled:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    NSLog(@"%@", newLocation);
    
    myLocation = newLocation;
    
    MKReverseGeocoder *geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
    geoCoder.delegate = self;
    [geoCoder start];
    
    [self foundLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [appDelegate showAlert:@"Falha" message:@"Não foi possível determinar sua localização! Por favor, tente novamente."];
    
    if( distanceOptionIndex > 0 ){
        
        [switchLocation setOn:NO animated:YES];
        [self changeSwitchLocation:switchLocation];
    }
    
    [btnRedefineLocation setEnabled:YES];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    
    MKPlacemark * myPlacemark = placemark;
    // with the placemark you can now retrieve the city name
    NSArray *address = [myPlacemark.addressDictionary objectForKey:(NSString*) @"FormattedAddressLines"];
    
    if( address.count > 4 ){
     
        appDelegate.workplaceAddress = [NSString stringWithFormat:@"%@, %@, %@, %@, %@", [address objectAtIndex:0], [address objectAtIndex:1], [address objectAtIndex:2], [address objectAtIndex:3], [address objectAtIndex:4]];
        [self.tableView reloadData];
        
        [appDelegate updateUserInfo];
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    
    NSLog(@"reverseGeocoder:%@ didFailWithError:%@", geocoder, error);    
}

@end
