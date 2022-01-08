//
//  HistoryViewController.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-05.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "HistoryViewController.h"
#import "Shift.h"
#import "ShiftDetailsViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

@synthesize shiftList;
@synthesize employeeId;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    appDelegate = (TimesheetAppDelegate *)[[UIApplication sharedApplication] delegate];
    employeeId = [appDelegate employeeId];
    
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
    
    if( !employeeId ){
        
        employeeId = [appDelegate employeeId];
        self.title = @"Meu histórico";
    }
    
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
		view.delegate = self;
		[self.view addSubview:view];
		_refreshHeaderView = view;	
	}
    
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addShift:) name:@"addShift" object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ShiftCell" bundle:nil] forCellReuseIdentifier:@"ShiftCell"];
    
    [self performSelector:@selector(updateShiftList) withObject:nil afterDelay:0.1];
}

- (void)addShift:(NSNotification *)notification {
    
    [self updateShiftList];
//    Shift *shift = (Shift *)notification.object;
//    
//    shiftList = [[NSMutableArray alloc] initWithArray: shiftList];
//    
//    [shift setIndex:[shiftList count]];
//    [shiftList addObject:shift];
//    
//    shiftList = [Shift sort:shiftList];
//    
//    [[self tableView] reloadData];
//    
}

- (void)updateShiftList {
    
    [self updateShiftList:NO];
}

- (void)updateShiftList:(BOOL)force {
    
    if( shiftList == nil )
        shiftList = [Shift loadList:employeeId limit:0];
    else if( shiftList != nil || force == YES )
        shiftList = [Shift loadList:employeeId limit:0 force:YES];
    
    [self.tableView reloadData];
    
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
    return [shiftList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShiftCell";
    ShiftCell *cell = (ShiftCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( !cell )
        cell = [[ShiftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    Shift *shift = [shiftList objectAtIndex:indexPath.row];
    
    cell.lblEntranceDate.text   = shift.entranceDate;
//    cell.lblEntranceTime.text   = shift.entranceTime;
//    cell.lblLunchStartTime.text = shift.lunchStartTime;
//    cell.lblLunchStopTime.text  = shift.lunchStopTime;
//    cell.lblExitTime.text       = shift.exitTime;
    cell.lblPeriod.text       = [NSString stringWithFormat:@"%@ - %@", shift.entranceTime, shift.exitTime];
    cell.lblWorkedTime.text   = [NSString stringWithFormat:@"(%@)", shift.workedTime];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
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
//     TimesheetDetailsViewController *detailViewController = [[TimesheetDetailsViewController alloc] initWithNibName:nil bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    NSString *footer = @"";
    
    if( [shiftList count]==0 )
        footer = @"Nenhum registro de horas";
    
    return footer;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    currentShift = [shiftList objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"showShiftDetails" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if( [[segue identifier] isEqualToString:@"showShiftDetails"] ){
        
        ShiftDetailsViewController *destination = [segue destinationViewController];
        
        destination.shift = currentShift;
    }
}

#pragma mark - Table view delegate

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    
	_reloading = YES;
    
    [self performSelector:@selector(updateShiftList) withObject:nil afterDelay:0.1];
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

@end
