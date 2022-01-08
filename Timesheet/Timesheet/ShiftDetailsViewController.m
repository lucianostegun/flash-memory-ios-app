//
//  ShiftDetailsViewController.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-15.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "ShiftDetailsViewController.h"

@interface ShiftDetailsViewController ()

@end

@implementation ShiftDetailsViewController
@synthesize shift;

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
    
    appDelegate = (TimesheetAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ShiftDetailsCell" bundle:nil] forCellReuseIdentifier:@"ShiftDetailsCell"];
    
        NSLog(@"shift: %@", shift);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 5;
        case 1:
            return 3;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShiftDetailsCell";
    ShiftDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( !cell )
        cell = [[ShiftDetailsCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    switch ( indexPath.section ) {
        case 0:
            switch ( indexPath.row ) {
                case 0:
                    cell.lblLabel.text   = @"Usuário";
                    cell.lblDetails.text = shift.employeeName;
                    break;
                case 1:
                    cell.lblLabel.text   = @"Entrada";
                    cell.lblDetails.text = shift.entranceDateTime;
                    cell.icon.image      = [UIImage imageNamed:@"entrance.png"];
                    break;
                case 2:
                    cell.lblLabel.text   = @"Almoço";
                    cell.lblDetails.text = shift.lunchStartDateTime;
                    cell.icon.image      = [UIImage imageNamed:@"lunch-start.png"];
                    break;
                case 3:
                    cell.lblLabel.text   = @"Retorno";
                    cell.lblDetails.text = shift.lunchStopDateTime;
                    cell.icon.image      = [UIImage imageNamed:@"lunch-stop.png"];
                    break;
                case 4:
                    cell.lblLabel.text   = @"Saída";
                    cell.lblDetails.text = shift.exitDateTime;
                    cell.icon.image      = [UIImage imageNamed:@"exit.png"];
                    break;
            }
            break;
        case 1:
            switch ( indexPath.row ) {
                case 0:
                    cell.lblLabel.text   = @"Trabalho";
                    cell.lblDetails.text = shift.workedTime;
                    break;
                case 1:
                    cell.lblLabel.text   = @"Almoço";
                    cell.lblDetails.text = shift.lunchTime;
                    break;
                case 2:
                    cell.lblLabel.text   = @"Total";
                    cell.lblDetails.text = shift.totalTime;
                    break;
            }
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( appDelegate.lunchTime == NO )
        if( (indexPath.section == 0 && (indexPath.row==2 || indexPath.row==3)) || (indexPath.section == 1 && indexPath.row==1) )
            cell.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( appDelegate.lunchTime == NO )
        if( (indexPath.section == 0 && (indexPath.row==2 || indexPath.row==3)) || (indexPath.section == 1 && indexPath.row==1) )
            return 0;
    
    return 44;
}

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
}

@end
