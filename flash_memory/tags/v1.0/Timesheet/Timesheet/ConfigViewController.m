//
//  ConfigViewController.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-14.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "ConfigViewController.h"

@interface ConfigViewController ()

@end

@implementation ConfigViewController

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
	// Do any additional setup after loading the view.
    
    appDelegate = (TimesheetAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    [txtEmployeeName setText: appDelegate.employeeName];
    [txtEmailAddress setText: appDelegate.emailAddress];
    [txtCompanyName setText: appDelegate.companyName];
    [lblCompanyName setText: appDelegate.companyName];
    [lblSyncCode setText: appDelegate.syncCode];
    
    if( appDelegate.isAdmin ){
        
        [txtCompanyName setHidden:NO];
        [lblCompanyName setHidden:YES];
    }else{
        
        [txtCompanyName setHidden:YES];
        [lblCompanyName setHidden:NO];
    }
    
    [switchLockDeviceUDID setOn:appDelegate.lockDeviceUDID];
    [switchLunchTime setOn:appDelegate.lunchTime];
    
    NSLog(@"appDelegate.lunchTime: %i", appDelegate.lunchTime);
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"appDelegate.enableLocation: %i", appDelegate.enableLocation);
    
    if( appDelegate.enableLocation ){
        
        lblEnableLocation.text   = @"Habilitado";
        lblLocationDistance.text = [NSString stringWithFormat:@"%i metros", appDelegate.radius];
    }else{
        
        lblEnableLocation.text   = @"Desabilitado";
        lblLocationDistance.text = @"";
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self btnCheckConnectionClick];
    [appDelegate checkNetwork];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnSwitchTimesheetClick {
    
    [appDelegate logout];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController* initialView = [storyboard instantiateViewControllerWithIdentifier:@"startViewController"];
    
    [appDelegate.window setRootViewController:initialView];
}

- (void)btnUpdateInfoClick:(id)sender {
    
    if( [txtCompanyName.text isEqualToString:@""] || [txtEmployeeName.text isEqualToString:@""] || [txtEmailAddress.text isEqualToString:@""] )
        return [appDelegate showAlert:@"Erro" message:@"Preencha todos os campos\npara atualizar as informações!"];
    
    [self.view endEditing:YES];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	HUD.delegate = self;
	HUD.labelText = @"atualizando informações";
    
    NSString *urlString  = [NSString stringWithFormat:@"http://%@/timesheet/updateInfo?deviceUDID=%@&companyName=%@&employeeName=%@&emailAddress=%@&syncCode=%@&companyName=%@&companyId=%i&employeeId=%i&lockDeviceUDID=%i&lunchTime=%i&enableLocation=%i&latitude=%f&longitude=%f&locationDistance=%i", serverAddress, appDelegate.deviceUDID, txtCompanyName.text, txtEmployeeName.text, txtEmailAddress.text, appDelegate.syncCode, appDelegate.companyName, appDelegate.companyId, appDelegate.employeeId, switchLockDeviceUDID.isOn, switchLunchTime.isOn, appDelegate.enableLocation, appDelegate.latitude, appDelegate.longitude, appDelegate.locationDistanceIndex];
    
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"urlString: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError");
    [HUD hide:YES];
    
    [appDelegate showAlert:@"Falha" message:@"Não foi possível atualizar as informações!\nPor favor, tente novamente."];
}

- (void)connection: (NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSLog(@"didReceiveResponse");
    [HUD hide:YES];
}

- (void)connection: (NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"didReceiveData");
    [HUD hide:YES];
    
    webData = [[NSMutableData alloc] init];
    [webData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading");
    [HUD hide:YES];
    
    NSString *result = [[NSString alloc] initWithData:webData encoding:NSASCIIStringEncoding];
    NSLog(@"result: %@", result);
    
    if( webData == nil )
        return [appDelegate showAlert:@"Falha" message:@"Não foi possível atualizar as informações!\nPor favor, tente novamente."];
    
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
    
    NSString *status       = [jsonResponse objectForKey:@"status"];
//    int errorCode          = [[jsonResponse objectForKey:@"errorCode"] intValue];
    NSString *errorMessage = [jsonResponse objectForKey:@"errorMessage"];
    
    if( [status isEqualToString:@"success"] ){
     
        NSMutableDictionary* dictionary = [appDelegate dictionary];
        [dictionary setObject:[jsonResponse objectForKey:kCompanyNameKey] forKey:kCompanyNameKey];
        [dictionary setObject:txtEmployeeName.text forKey:kEmployeeNameKey];
        [dictionary setObject:txtEmailAddress.text forKey:kEmailAddressKey];
        [dictionary setObject:[jsonResponse objectForKey:kIsAdminKey] forKey:kIsAdminKey];
        [dictionary setObject:[jsonResponse objectForKey:kLockDeviceUDIDKey] forKey:kLockDeviceUDIDKey];
        [dictionary setObject:[jsonResponse objectForKey:kLunchTimeKey] forKey:kLunchTimeKey];
        [dictionary setObject:[jsonResponse objectForKey:kEnableLocationKey] forKey:kEnableLocationKey];
        [dictionary setObject:[jsonResponse objectForKey:kLatitudeKey] forKey:kLatitudeKey];
        [dictionary setObject:[jsonResponse objectForKey:kLongitudeKey] forKey:kLongitudeKey];
        [dictionary setObject:[jsonResponse objectForKey:kLocationDistanceKey] forKey:kLocationDistanceIndexKey];
        
//        BOOL syncResult = [appDelegate updateUserInfo];
        BOOL syncResult = [appDelegate updateUserInfo: dictionary];
        
        NSLog(@"appDelegate.lunchTime: %i", appDelegate.lunchTime);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetLabels" object:nil userInfo:nil];
        
        if( !syncResult )
            [appDelegate showAlert:@"Erro" message:@"Ocorreu um erro ao atualizar as informações!\nPor favor, tente novamente."];
    }else if( [status isEqualToString:@"warning"] ){
        
        [appDelegate showAlert:@"Erro" message:errorMessage];
    }else{
        
        [appDelegate showAlert:@"Erro" message:errorMessage];
    }
}

- (void)checkNetworkStatus:(NSNotification *)notice {
    
    NSLog(@"checkNetworkStatus");
    
    if( [appDelegate checkedHost] && [appDelegate hostActive]==YES ){
        
        [imgInternetStatus setImage:[UIImage imageNamed:@"bullet-green-icon.png"]];
        [lblInternetStatus setText:@"Conectado"];
    }else if( [appDelegate checkedHost] && [appDelegate hostActive]==NO ){
        
        [imgInternetStatus setImage:[UIImage imageNamed:@"bullet-red-icon.png"]];
        [lblInternetStatus setText:@"Sem conexão"];
    }else {
        
        [imgInternetStatus setImage:[UIImage imageNamed:@"bullet-black-icon.png"]];
        [lblInternetStatus setText:@"Falha na conexão"];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)btnCheckConnectionClick {
    
    [lblInternetStatus setText:@"Verificando conexão"];
    [imgInternetStatus setImage:[UIImage imageNamed:@"bullet-yellow-icon.png"]];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [appDelegate checkNetwork];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if( section == 1 && !appDelegate.isAdmin )
        return 0.1;
    
    return [super tableView:tableView heightForHeaderInSection:section];
}

/* Height of section footer */
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if( section == 1 && !appDelegate.isAdmin )
        return 0.1;
    
    return [super tableView:tableView heightForFooterInSection:section];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    switch( section ){
        case 0:
            return @"Configurações da conta";
        case 1:
            if( !appDelegate.isAdmin )
                return nil;
            
            return @"Opções de uso";
        case 2:
            return @"Localização";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 5;
        case 1:
            return (appDelegate.isAdmin?1:0);
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        case 4:
            return 1;
            break;
            
        default:
            break;
    }
    return 0;
}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if( indexPath.section== 4 )
       [self btnSwitchTimesheetClick];
}

@end
