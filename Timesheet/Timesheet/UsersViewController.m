//
//  UsersViewController.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-10.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "UsersViewController.h"
#import "Employee.h"
#import "HistoryViewController.h"

@interface UsersViewController ()

@end

@implementation UsersViewController

@synthesize employeeList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
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
    
    self.title = @"Usuários";
    
    appDelegate = (TimesheetAppDelegate *)[[UIApplication sharedApplication] delegate];
    
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
		view.delegate = self;
		[self.view addSubview:view];
		_refreshHeaderView = view;
	}
    
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self performSelector:@selector(updateEmployeeList) withObject:nil afterDelay:0.1];
}

- (void)updateEmployeeList {
    
    int companyId = [appDelegate companyId];
    
    if( employeeList == nil )
        employeeList = [Employee loadList:companyId limit:0];
    else
        employeeList = [Employee loadList:companyId limit:0 force:YES];
    
    [[self tableView] reloadData];
    
    [self doneLoadingTableViewData];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [employeeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( !cell )
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    employee = [employeeList objectAtIndex:indexPath.row];
    
    cell.textLabel.text       = employee.employeeName;
    cell.detailTextLabel.text = employee.emailAddress;
    
    return cell;
}

 // Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.

    return [[employeeList objectAtIndex:indexPath.row] employeeId] != [appDelegate employeeId];
}

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         
         Employee *employee = [employeeList objectAtIndex:indexPath.row];
         
         BOOL result = [employee deleteRemote];
         
         if( result == YES ){
             
             [employeeList removeObjectAtIndex:indexPath.row];
             [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
             
             [NSKeyedArchiver archiveRootObject:employeeList toFile:[Employee employeeArrayPath: appDelegate.companyId]];
         }else{
             
             [appDelegate showAlert:@"Falha" message:@"Não foi possível remover este usuário.\nPor favor, tente novamente."];
         }
     }else if (editingStyle == UITableViewCellEditingStyleInsert) {

         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
 }

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
    
//    HistoryViewController *historyViewController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
//    
    employee = [employeeList objectAtIndex:indexPath.row];
//
//    [historyViewController setEmployeeId: employee.employeeId];
//    
//    [self.navigationController pushViewController:historyViewController animated:YES];
//    historyViewController.title = employee.employeeName;
    
    [self performSegueWithIdentifier:@"showUserHistory" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if( [[segue identifier] isEqualToString:@"showUserHistory"] ){
        
        HistoryViewController *destination = [segue destinationViewController];
      
        NSLog(@"employee: %i", employee.employeeId);
        [destination setEmployeeId: employee.employeeId];
        destination.title = employee.employeeName;
    }else{
        

    }
}


#pragma mark - Table view delegate

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    
	_reloading = YES;
    
    [self performSelector:@selector(updateEmployeeList) withObject:nil afterDelay:0.1];
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

- (IBAction)btnEditClick:(id)sender {
    
    if( [btnEdit style] == UIBarButtonItemStyleDone ){
        
        [btnEdit setStyle:UIBarButtonItemStylePlain];
        [btnEdit setTitle:@"Editar"];
        [self setEditing:NO animated:YES];
    }else{
        
        [btnEdit setStyle:UIBarButtonItemStyleDone];
        [btnEdit setTitle:@"Ok"];
        [self setEditing:YES animated:YES];
    }
}

@end
