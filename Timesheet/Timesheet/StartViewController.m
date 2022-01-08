//
//  StartViewController.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-03.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "StartViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

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
    [btnEmployeeMode setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [btnEmployeeMode setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    
    [btnCompanyMode setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [btnCompanyMode setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
