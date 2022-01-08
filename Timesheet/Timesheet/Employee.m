//
//  Employee.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-10.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "Employee.h"
#import "XMLEmployeeParser.h"

@implementation Employee
@synthesize employeeId;
@synthesize companyId;
@synthesize employeeName;
@synthesize emailAddress;

- (id)init {
    
    self = [super init];
    
    return self;
}

- (id)initWithEmployeeId:(int)theEmployeeId {
    
    self = [self init];
    
    [self setEmployeeId:theEmployeeId];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:employeeId forKey:@"employeeId"];
    [encoder encodeInt:companyId forKey:@"companyId"];
    [encoder encodeObject:employeeName forKey:@"employeeName"];
    [encoder encodeObject:emailAddress forKey:@"emailAddress"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [self init];
    
    [self setEmployeeId: [decoder decodeIntForKey:@"employeeId"]];
    [self setCompanyId: [decoder decodeIntForKey:@"companyId"]];
    [self setEmployeeName: [decoder decodeObjectForKey:@"employeeName"]];
    [self setEmailAddress: [decoder decodeObjectForKey:@"emailAddress"]];
    
    return self;
}

-(NSString *)employeeName {
    
    return [employeeName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)emailAddress {
    
    return [emailAddress stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)deleteRemote {
    
    TimesheetAppDelegate *appDelegate = (TimesheetAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/timesheet/deleteEmployee/companyId/%i/employeeId/%i/syncCode/%@/deviceUDID/%@", serverAddress, companyId, self.employeeId, appDelegate.syncCode, appDelegate.deviceUDID]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:45];
    NSError *requestError = nil;
    NSData *response      = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
    
    NSLog(@"url: %@", url);
    
    if( requestError == nil) {
        
        NSString *result = [[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding];
        
        NSLog(@"result: %@", result);
        
        if( [result isEqualToString:@"success"] )
            return YES;
    }
    
    return NO;
}

+ (NSString *)employeeArrayPath:(int)companyId {
    
    NSArray*	documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*	path = nil;
	
    if (documentDir)
        path = [documentDir objectAtIndex:0];
	
    return [NSString stringWithFormat:@"%@/Employee-%i.data", path, companyId];
    
    //    return (@"Employee.data");
}

+ (NSMutableArray *)loadList:(int)employeeId limit:(int)limit {
    
    return [Employee loadList:employeeId limit:limit force:NO];
}

+ (NSMutableArray *)loadList:(int)companyId limit:(int)limit force:(BOOL)force {
    
    NSMutableArray *employeeList;
    
    NSLog(@"force: %i", force);
    
    if( force == NO )
        employeeList = [Employee loadArchivedList: companyId];
    
    if( force == YES || employeeList == nil || [employeeList count] == 0 ){
        
        TimesheetAppDelegate *appDelegate = (TimesheetAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/timesheet/getXml/model/employee/companyId/%i/limit/%i/deviceUDID/%@", serverAddress, companyId, limit, appDelegate.deviceUDID]];
        
        XMLEmployeeParser *employeeParser = [[XMLEmployeeParser alloc] initXMLParser];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:45];
        NSError *requestError = nil;
        NSData *response      = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
        BOOL success;
        
        NSLog(@"url: %@", url);
        
        if( requestError == nil) {
            
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:response];
            
            [parser setDelegate:employeeParser];
            [parser setShouldProcessNamespaces:YES];
            [parser setShouldReportNamespacePrefixes:YES];
            [parser setShouldResolveExternalEntities:NO];
            success = [parser parse];
            
            employeeList = [employeeParser getEmployeeList];
            
            [NSKeyedArchiver archiveRootObject:employeeList toFile:[Employee employeeArrayPath: companyId]];
        }
    }
    
    return employeeList;
}

+ (NSMutableArray *)loadArchivedList:(int)companyId {
    
    NSMutableArray *employeeList;
    NSString *employeePath = [Employee employeeArrayPath: companyId];
    
    employeeList = [NSKeyedUnarchiver unarchiveObjectWithFile:employeePath];
    
    if( !employeeList )
        employeeList = [NSMutableArray array];
    
    return employeeList;
}

+ (void)removeCache:(int)companyId {
    
    [[NSFileManager defaultManager] removeItemAtPath:[Employee employeeArrayPath: companyId] error:nil];
}

@end
