//
//  EmployeeViewController.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-04.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "EmployeeViewController.h"

@interface EmployeeViewController ()

@end

@implementation EmployeeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    
    UIImage *buttonImage = [[UIImage imageNamed:@"blackButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blackButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    
    [btnCreateEmployee setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [btnCreateEmployee setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
//    [txtEmployeeName setText:@"Angélica"];
//    [txtEmailAddress setText:@"angelica@esferas.com.br"];
//    [txtEmployeeName setText:@"Luciano"];
//    [txtEmailAddress setText:@"lucianostegun@gmail.com"];
//    [txtSyncCode setText:@"STEGUN01"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (IBAction)dismissSwipeDown:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
//    if( [textField isEqual:txtSyncCode] )
        [self btnCreateEmployeeClick:nil];
    
    return YES;
}

-(void)keyboardWillShow {
    
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
        [self setViewMovedUp:YES];
    //    else if (self.view.frame.origin.y < 0)
    //        [self setViewMovedUp:NO];
}

-(void)keyboardWillHide {
    
    //    if (self.view.frame.origin.y >= 0)
    //        [self setViewMovedUp:YES];
    //    else
    if (self.view.frame.origin.y < 0)
        [self setViewMovedUp:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if( [sender isEqual:txtEmailAddress] ){
        
        //move the main view, so that the keyboard does not hide it.
        if( self.view.frame.origin.y >= 0)
            [self setViewMovedUp:YES];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        if (screenSize.height > 480.0f)
            return; // Se for iPhone 5 não faz nada pq não precisa dar scroll na tela
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if( movedUp ){
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }else{
        
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (void)btnCreateEmployeeClick:(id)sender {
    
    if( [txtEmployeeName.text isEqualToString:@""] || [txtEmailAddress.text isEqualToString:@""] )
        return [appDelegate showAlert:@"Erro" message:@"Preencha todos os campos\npara iniciar o controle de horas!"];
    
    [self.view endEditing:YES];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	HUD.delegate = self;
	HUD.labelText = @"acessando controle de horas";
    
    NSString *urlString  = [NSString stringWithFormat:@"http://%@/timesheet/createEmployee?deviceUDID=%@&employeeName=%@&emailAddress=%@&syncCode=%@", serverAddress, appDelegate.deviceUDID, txtEmployeeName.text, txtEmailAddress.text, txtSyncCode.text];
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"urlString: %@", urlString);
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error);
    [HUD hide:YES];
    
    [appDelegate showAlert:@"Falha" message:@"Não foi possível iniciar o controle de horas!\nPor favor, tente novamente."];
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
        return [appDelegate showAlert:@"Falha" message:@"Não foi possível iniciar o controle de horas!\nPor favor, tente novamente."];
    
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
//    NSString *result = [[NSString alloc] initWithData:webData encoding:NSASCIIStringEncoding];
    
//    NSLog(@"result: %@", result);
    
    NSString *status       = [jsonResponse objectForKey:@"status"];
    int errorCode          = [[jsonResponse objectForKey:@"errorCode"] intValue];
    NSString *errorMessage = [jsonResponse objectForKey:@"errorMessage"];
    
    if( [status isEqualToString:@"success"] ){

        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:[jsonResponse objectForKey:kSyncCodeKey] forKey:kSyncCodeKey];
        [dictionary setObject:[jsonResponse objectForKey:kCompanyIdKey] forKey:kCompanyIdKey];
        [dictionary setObject:[jsonResponse objectForKey:kEmployeeIdKey] forKey:kEmployeeIdKey];
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

        appDelegate.workplaceLocation = [NSString stringWithFormat:@"%@,%@", [jsonResponse objectForKey:kLatitudeKey], [jsonResponse objectForKey:kLongitudeKey]];
        
        BOOL syncResult = [appDelegate updateUserInfo: dictionary];
    
        if( !syncResult )
            return [appDelegate showAlert:@"Erro" message:@"Ocorreu um erro ao processar as informações!\nPor favor, tente novamente."];
    
        [self performSegueWithIdentifier:@"showMainTabBar" sender:self];
    }else if( [status isEqualToString:@"warning"] ){
        
        switch( errorCode ){
            case ERROR_USER_NOT_FOUND:
                [appDelegate showAlert:@"Código não encontrado" message:@"Verifique código informado\ne tente novamente."];
                break;
            case ERROR_INVALID_DEVICEUDID:
                [appDelegate showAlert:@"Dispositivo inválido" message:errorMessage];
                break;
            default:
                [appDelegate showAlert:@"Erro" message:errorMessage];
        }
    }else{
        
        [appDelegate showAlert:@"Erro" message:@"Não foi possível iniciar o controle de horas!\nPor favor, tente novamente."];
    }
}

@end
