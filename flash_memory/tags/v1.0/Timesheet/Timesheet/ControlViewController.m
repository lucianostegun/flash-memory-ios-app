//
//  ControlViewController.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-03.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "ControlViewController.h"
#import "Constants.h"
#import "Shift.h"
#import <QuartzCore/QuartzCore.h>

@interface ControlViewController ()

@end

@implementation ControlViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [lblCurrentWeekday setFont:[UIFont fontWithName:@"Crystal" size:25]];
    [lblCurrentDate setFont:[UIFont fontWithName:@"Crystal" size:35]];
    [lblCurrentTime setFont:[UIFont fontWithName:@"Crystal" size:80]];
    
    appDelegate = (TimesheetAppDelegate *)[[UIApplication sharedApplication] delegate];
       
    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    // Set the background for any states you plan to use
    [btnRegister setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [btnRegister setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
   
    [self updateCurrentTime];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetLabels:) name:@"resetLabels" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [self resetLabels:nil];
    
    btnRegister.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 42.0f, 0.0f, 0.0f);
    [btnRegister setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    if( appDelegate.lunchTime ){
        
        if( ![lblValue1.text isEqualToString:@"Não registrado"] && ![lblValue4.text isEqualToString:@"Não registrado"] )
            appDelegate.pendingSync = YES;
        
        if( appDelegate.pendingSync ){
            
            [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-yellow-icon.png"]];
            [lblSyncStatus setText:@"Sincronização pendente!"];
            
            UIImage *buttonImage = [UIImage imageNamed:@"sync.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"SINCRONIZAR AGORA" forState:UIControlStateNormal];
            [btnRegister setEnabled:YES];
        }else{
            
            if( [lblValue1.text isEqualToString:@"Não registrado"] ){
                
                UIImage *buttonImage = [UIImage imageNamed:@"entrance.png"];
                [btnRegister setImage:buttonImage forState:UIControlStateNormal];
                [btnRegister setTitle:@"REGISTRAR ENTRADA" forState:UIControlStateNormal];
                [btnRegister setEnabled:YES];
            }else if( [lblValue2.text isEqualToString:@"Não registrado"] ){
                
                UIImage *buttonImage = [UIImage imageNamed:@"lunch-stop.png"];
                [btnRegister setImage:buttonImage forState:UIControlStateNormal];
                [btnRegister setTitle:@"SAÍDA PARA ALMOÇO" forState:UIControlStateNormal];
                [btnRegister setEnabled:YES];
            }else if( [lblValue3.text isEqualToString:@"Não registrado"] ){
                
                UIImage *buttonImage = [UIImage imageNamed:@"lunch-start.png"];
                [btnRegister setImage:buttonImage forState:UIControlStateNormal];
                [btnRegister setTitle:@"RETORNO DO ALMOÇO" forState:UIControlStateNormal];
                [btnRegister setEnabled:YES];
            }else if( [lblValue4.text isEqualToString:@"Não registrado"] ){
                
                UIImage *buttonImage = [UIImage imageNamed:@"exit.png"];
                [btnRegister setImage:buttonImage forState:UIControlStateNormal];
                [btnRegister setTitle:@"REGISTRAR SAÍDA" forState:UIControlStateNormal];
                [btnRegister setEnabled:YES];
            }else {
                
                [btnRegister setEnabled:YES];
            }
        }
    }else{
        
        if( ![lblValue1.text isEqualToString:@"Não registrado"] && ![lblValue2.text isEqualToString:@"Não registrado"])
            appDelegate.pendingSync = YES;
        
        if( appDelegate.pendingSync ){
            
            [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-yellow-icon.png"]];
            [lblSyncStatus setText:@"Sincronização pendente!"];
            
            UIImage *buttonImage = [UIImage imageNamed:@"sync.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"SINCRONIZAR AGORA" forState:UIControlStateNormal];
            [btnRegister setEnabled:YES];
        }else if( ![lblValue1.text isEqualToString:@"Não registrado"] && [lblValue2.text isEqualToString:@"Não registrado"] ){
            
            UIImage *buttonImage = [UIImage imageNamed:@"exit.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"REGISTRAR SAÍDA" forState:UIControlStateNormal];
            [btnRegister setEnabled:YES];
        }else{
            
            [btnRegister setEnabled:YES];
        }
    }
}


- (void)updateCurrentTime {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit| NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    NSInteger hour = [dateComponents hour];
    NSInteger second = [dateComponents second];
    NSInteger minute = [dateComponents minute];
    NSInteger day = [dateComponents day];
    NSInteger month = [dateComponents month];
    NSInteger year = [dateComponents year];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    //    NSString *ampm = @"AM";
    //    if(hour > 11)
    //        ampm = @"PM";
    //    if(hour > 12)
    //        hour -= 12;
    
    
    NSString *dayString    = [NSString stringWithFormat:@"%d",day];
    NSString *monthString  = [NSString stringWithFormat:@"%d",month];
    NSString *yearString   = [NSString stringWithFormat:@"%d",year];
    NSString *hourString   = [NSString stringWithFormat:@"%d",hour];
    NSString *minuteString = [NSString stringWithFormat:@"%d",minute];
    NSString *secondString = [NSString stringWithFormat:@"%d",second];
    
    if(hour < 10)
        hourString = [NSString stringWithFormat:@"0%@",hourString];
    
    if(minute < 10)
        minuteString = [NSString stringWithFormat:@"0%@",minuteString];
    
    if(second < 10)
        secondString = [NSString stringWithFormat:@"0%@",secondString];
    
    if(day < 10)
        dayString = [NSString stringWithFormat:@"0%@", dayString];
    
    if(month < 10)
        monthString = [NSString stringWithFormat:@"0%@", monthString];
    
    NSString *weekDay = [dateFormatter stringFromDate:[NSDate date]];
    weekDay = [weekDay uppercaseString];
    weekDay = [weekDay stringByReplacingOccurrencesOfString:@"-FEIRA" withString:@""];
    
    if( [weekDay isEqualToString:@"MONDAY"] )
        weekDay = @"segunda";
    else if( [weekDay isEqualToString:@"TUESDAY"] )
        weekDay = @"terca";
    else if( [weekDay isEqualToString:@"TERÇA"] )
        weekDay = @"terca";
    else if( [weekDay isEqualToString:@"WEDNESDAY"] )
        weekDay = @"quarta";
    else if( [weekDay isEqualToString:@"THURSDAY"] )
        weekDay = @"quinta";
    else if( [weekDay isEqualToString:@"FRIDAY"] )
        weekDay = @"sexta";
    else if( [weekDay isEqualToString:@"SATURDAY"] )
        weekDay = @"sabado";
    else if( [weekDay isEqualToString:@"SUNDAY"] )
        weekDay = @"domingo";
    
    weekDay = [weekDay uppercaseString];
    
    [lblCurrentWeekday setText:[NSString stringWithFormat:@"%@", weekDay]];
    [lblCurrentDate setText:[NSString stringWithFormat:@"%@/%@/%@", dayString, monthString, yearString]];
    [lblCurrentTime setText:[NSString stringWithFormat:@"%@:%@:%@", hourString, minuteString, secondString]];
    
    [self performSelector:@selector(updateCurrentTime) withObject:self afterDelay:1.0];
}

- (void)btnRegisterClick:(id)sender {
    
    if( [appDelegate pendingSync] ){
        
        [self syncWithServer];
        return;
    }
    
    if( appDelegate.lunchTime ){
        
        if( [[appDelegate entranceDateTime] isEqualToString:@""] || [appDelegate entranceDateTime] == nil ){
            
            NSString *entranceDateTime = [NSString stringWithFormat:@"%@ %@", [lblCurrentDate text], [lblCurrentTime text]];
            [lblValue1 setText:entranceDateTime];
            [appDelegate setEntranceDateTime: entranceDateTime];
            
            UIImage *buttonImage = [UIImage imageNamed:@"lunch-start.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"SAÍDA PARA ALMOÇO" forState:UIControlStateNormal];
            [lblValue2 setText:@"Não registrado"];
            [lblValue3 setText:@"Não registrado"];
            [lblValue4 setText:@"Não registrado"];
            
            [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-black-icon.png"]];
            [lblSyncStatus setText:@"Não registrado"];
            
            [appDelegate updateUserInfo];
            
            return;
        }
        
        if( [[appDelegate lunchStartDateTime] isEqualToString:@""] || [appDelegate lunchStartDateTime] == nil ){
            
            NSString *lunchStartDateTime = [NSString stringWithFormat:@"%@ %@", [lblCurrentDate text], [lblCurrentTime text]];
            [lblValue2 setText:lunchStartDateTime];
            [appDelegate setLunchStartDateTime: lunchStartDateTime];
            
            UIImage *buttonImage = [UIImage imageNamed:@"lunch-stop.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"RETORNO DO ALMOÇO" forState:UIControlStateNormal];
            [lblValue3 setText:@"Não registrado"];
            [lblValue4 setText:@"Não registrado"];
            
            [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-black-icon.png"]];
            [lblSyncStatus setText:@"Não registrado"];
            
            [appDelegate updateUserInfo];
            
            return;
        }
        
        if( [[appDelegate lunchStopDateTime] isEqualToString:@""] || [appDelegate lunchStopDateTime] == nil ){
            
            NSString *lunchStopDateTime = [NSString stringWithFormat:@"%@ %@", [lblCurrentDate text], [lblCurrentTime text]];
            [lblValue3 setText:lunchStopDateTime];
            [appDelegate setLunchStopDateTime: lunchStopDateTime];
            
            UIImage *buttonImage = [UIImage imageNamed:@"exit.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"REGISTRAR SAÍDA" forState:UIControlStateNormal];
            [lblValue4 setText:@"Não registrado"];
            
            [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-black-icon.png"]];
            [lblSyncStatus setText:@"Não registrado"];
            
            [appDelegate updateUserInfo];
            
            return;
        }
        
        if( [[appDelegate exitDateTime] isEqualToString:@""] || [appDelegate exitDateTime] == nil ){
            
            NSString *exitDateTime = [NSString stringWithFormat:@"%@ %@", [lblCurrentDate text], [lblCurrentTime text]];
            [lblValue4 setText:exitDateTime];
            
            [appDelegate setExitDateTime: exitDateTime];
            
            UIImage *buttonImage = [UIImage imageNamed:@"entrance.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"REGISTRAR ENTRADA" forState:UIControlStateNormal];
            
            [self syncWithServer];
        }
    }else{
        
        if( [[appDelegate entranceDateTime] isEqualToString:@""] || [appDelegate entranceDateTime] == nil ){
            
            NSString *entranceDateTime = [NSString stringWithFormat:@"%@ %@", [lblCurrentDate text], [lblCurrentTime text]];
            [lblValue1 setText:entranceDateTime];
            [appDelegate setEntranceDateTime: entranceDateTime];
            
            UIImage *buttonImage = [UIImage imageNamed:@"exit.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"REGISTRAR SAÍDA" forState:UIControlStateNormal];
            [lblValue2 setText:@"Não registrado"];
            
            [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-black-icon.png"]];
            [lblSyncStatus setText:@"Não registrado"];
            
            [appDelegate updateUserInfo];
            
        }else if( [[appDelegate exitDateTime] isEqualToString:@""] || [appDelegate exitDateTime] == nil ){
            
            NSString *exitDateTime = [NSString stringWithFormat:@"%@ %@", [lblCurrentDate text], [lblCurrentTime text]];
            [lblValue2 setText:exitDateTime];
            
            [appDelegate setExitDateTime: exitDateTime];
            
            UIImage *buttonImage = [UIImage imageNamed:@"entrance.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"REGISTRAR ENTRADA" forState:UIControlStateNormal];
            
            [self syncWithServer];
        }
    }
    
    appDelegate.lastLocationNotification = @""; // Reseta essa variavel para que quando entrar em background considere a notificação de localização
    NSLog(@"Resetou a variável lastLocationNotification");
}

- (void)syncWithServer {
    
    NSLog(@"syncWithServer");
    
    [btnRegister setEnabled:NO];
    
    UIImage *buttonImage = [UIImage imageNamed:@"sync.png"];
    [btnRegister setImage:buttonImage forState:UIControlStateNormal];
    [btnRegister setTitle:@"SINCRONIZANDO..." forState:UIControlStateNormal];
    
    [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-yellow-icon.png"]];
    [lblSyncStatus setText:@"Sincronizando..."];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/timesheet/synchronize?appId=%i&deviceUDID=%@&entranceDateTime=%@&lunchStartDateTime=%@&lunchStopDateTime=%@&exitDateTime=%@&companyId=%i&syncCode=%@&employeeId=%i", serverAddress, kAPP_ID, appDelegate.deviceUDID, appDelegate.entranceDateTime, appDelegate.lunchStartDateTime, appDelegate.lunchStopDateTime, appDelegate.exitDateTime, appDelegate.companyId, appDelegate.syncCode, appDelegate.employeeId];
    
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSLog(@"urlString: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection: (NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [btnRegister setEnabled:YES];
    
    [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-red-icon.png"]];
    [lblSyncStatus setText:@"Falha ao sincronizar"];
    
    [appDelegate setPendingSync:YES];
    
    UIImage *buttonImage = [UIImage imageNamed:@"sync.png"];
    [btnRegister setImage:buttonImage forState:UIControlStateNormal];
    [btnRegister setTitle:@"SINCRONIZAR AGORA" forState:UIControlStateNormal];
    
    NSLog(@"%@", error);
    [appDelegate updateUserInfo];
}

- (void)connection: (NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSLog(@"didReceiveResponse");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [btnRegister setEnabled:YES];
}

- (void)connection: (NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"didReceiveData");
    
    webData = [[NSMutableData alloc] init];
    [webData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSString *result = [[NSString alloc] initWithData:webData encoding:NSASCIIStringEncoding];
    NSLog(@"result: %@", result);
    
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:webData options:0 error:nil];
    
    NSString *status       = [jsonResponse objectForKey:@"status"];
    int errorCode          = [[jsonResponse objectForKey:@"errorCode"] intValue];
    NSString *errorMessage = [jsonResponse objectForKey:@"errorMessage"];
    
    if( [status isEqualToString:@"success"] ){
        
        if( appDelegate.lunchTime ){
            
            NSArray* entranceInfo  = [lblValue1.text componentsSeparatedByString: @" "];
            NSString *entranceDate = [entranceInfo objectAtIndex:0];
            NSString *entranceTime = [entranceInfo objectAtIndex:1];
            
            NSString* lunchStartDateTime = lblValue2.text;
            NSString* lunchStopDateTime  = lblValue3.text;
            
            NSArray* exitInfo  = [lblValue4.text componentsSeparatedByString: @" "];
            NSString *exitDate = [exitInfo objectAtIndex:0];
            NSString *exitTime = [exitInfo objectAtIndex:1];
            
            Shift *shift = [[Shift alloc] init];
            [shift setEntranceDateTime: lblValue1.text];
            [shift setExitDateTime: lblValue2.text];
            [shift setEntranceDate:entranceDate];
            [shift setEntranceTime:entranceTime];
            [shift setLunchStartDateTime:lunchStartDateTime];
            [shift setLunchStopDateTime:lunchStopDateTime];
            [shift setExitDate:exitDate];
            [shift setExitTime:exitTime];
            [shift setCompanyId: appDelegate.companyId];
            [shift setEmployeeId: appDelegate.employeeId];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addShift" object:shift userInfo:nil];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [btnRegister setEnabled:YES];
            
            [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-green-icon.png"]];
            [lblSyncStatus setText:@"Sincronizado"];
            
            [appDelegate setPendingSync:NO];
            UIImage *buttonImage = [UIImage imageNamed:@"entrance.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"REGISTRAR ENTRADA" forState:UIControlStateNormal];
            
            [appDelegate setLastEntranceDateTime: lblValue1.text];
            [appDelegate setLastExitDateTime: lblValue4.text];
            
            [lblValue1 setText:@"Não registrado"];
            [lblValue2 setText:@"Não registrado"];
            [lblValue3 setText:@"Não registrado"];
            [lblValue4 setText:@"Não registrado"];
            
            [appDelegate setEntranceDateTime: @""];
            [appDelegate setLunchStartDateTime: @""];
            [appDelegate setLunchStopDateTime: @""];
            [appDelegate setExitDateTime: @""];
        }else{
            
            NSArray* entranceInfo  = [lblValue1.text componentsSeparatedByString: @" "];
            NSString *entranceDate = [entranceInfo objectAtIndex:0];
            NSString *entranceTime = [entranceInfo objectAtIndex:1];
            
            NSArray* exitInfo  = [lblValue2.text componentsSeparatedByString: @" "];
            NSString *exitDate = [exitInfo objectAtIndex:0];
            NSString *exitTime = [exitInfo objectAtIndex:1];
            
            Shift *shift = [[Shift alloc] init];
            [shift setEntranceDateTime: lblValue1.text];
            [shift setExitDateTime: lblValue2.text];
            [shift setEntranceDate:entranceDate];
            [shift setEntranceTime:entranceTime];
            [shift setExitDate:exitDate];
            [shift setExitTime:exitTime];
            [shift setCompanyId: appDelegate.companyId];
            [shift setEmployeeId: appDelegate.employeeId];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addShift" object:shift userInfo:nil];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [btnRegister setEnabled:YES];
            
            [imgSyncStatus setImage:[UIImage imageNamed:@"bullet-green-icon.png"]];
            [lblSyncStatus setText:@"Sincronizado"];
            
            [appDelegate setPendingSync:NO];
            
            UIImage *buttonImage = [UIImage imageNamed:@"entrance.png"];
            [btnRegister setImage:buttonImage forState:UIControlStateNormal];
            [btnRegister setTitle:@"REGISTRAR ENTRADA" forState:UIControlStateNormal];
            
            [lblValue3 setText: lblValue1.text];
            [lblValue4 setText: lblValue2.text];
            
            [appDelegate setLastEntranceDateTime: lblValue1.text];
            [appDelegate setLastExitDateTime: lblValue2.text];
            
            [lblValue1 setText:@"Não registrado"];
            [lblValue2 setText:@"Não registrado"];
            
            [appDelegate setEntranceDateTime: @""];
            [appDelegate setExitDateTime: @""];
        }
    }else if( [status isEqualToString:@"warning"] && ![errorMessage isEqualToString:@""] && errorMessage != nil ){
        
        if( errorCode==ERROR_LIMIT_EXCEEDED ){
            
            appUrl = [jsonResponse objectForKey:@"url"];
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                appUrl = [jsonResponse objectForKey:@"url"];
                
                [[[UIAlertView alloc] initWithTitle:@"Limite excedido" message:errorMessage delegate:self cancelButtonTitle:@"Mais tarde" otherButtonTitles:@"Baixar", nil] show];
            });
        }else{
            
            [appDelegate showAlert:@"Falha" message:errorMessage];
        }
        
        [self connection: connection didFailWithError:[NSError errorWithDomain:result code:0 userInfo:nil]];
    }else{
        
        [self connection: connection didFailWithError:[NSError errorWithDomain:result code:0 userInfo:nil]];
    }
    
    [appDelegate updateUserInfo];
    [btnRegister setEnabled:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
	if (buttonIndex == 0) {
		
        
	}else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: appUrl]];
        NSLog(@"Escolheu baixar: %@", appUrl);
	}
}

-(void)resetLabels:(NSNotification *)notice {
    
    if( [appDelegate.entranceDateTime isEqualToString:@""] ){
     
        appDelegate.lunchStartDateTime = @"";
        appDelegate.lunchStopDateTime  = @"";
        [appDelegate updateUserInfo];
    }
    
    if( appDelegate.lunchTime ){
        
        lblValue1.text = appDelegate.entranceDateTime;
        lblValue2.text = appDelegate.lunchStartDateTime;
        lblValue3.text = appDelegate.lunchStopDateTime;
        lblValue4.text = appDelegate.exitDateTime;
    }else{
        
        lblValue1.text = appDelegate.entranceDateTime;
        lblValue2.text = appDelegate.exitDateTime;
        lblValue3.text = appDelegate.lastEntranceDateTime;
        lblValue4.text = appDelegate.lastExitDateTime;
    }
    
    if( [lblValue1.text isEqualToString:@""] )
        lblValue1.text = @"Não registrado";
    if( [lblValue2.text isEqualToString:@""] )
        lblValue2.text = @"Não registrado";
    if( [lblValue3.text isEqualToString:@""] )
        lblValue3.text = @"Não registrado";
    if( [lblValue4.text isEqualToString:@""] )
        lblValue4.text = @"Não registrado";
    
    if( appDelegate.lunchTime ){
        
        lblLabel1.text = @"Entrada:";
        lblLabel2.text = @"Início almoço:";
        lblLabel3.text = @"Volta almoço:";
        lblLabel4.text = @"Saída:";
    }else{
        
        lblLabel1.text = @"Entrada:";
        lblLabel2.text = @"Saída:";
        lblLabel3.text = @"Última entrada:";
        lblLabel4.text = @"Última saída:";
    }
    
    NSLog(@"Resetou os labels");
}

@end
