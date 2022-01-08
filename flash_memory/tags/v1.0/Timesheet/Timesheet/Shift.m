//
//  Shift.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-06.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "Shift.h"
#import "XMLShiftParser.h"

@implementation Shift
@synthesize shiftId;
@synthesize companyId;
@synthesize employeeId;
@synthesize employeeName;
@synthesize entranceDateTime;
@synthesize lunchStartDateTime;
@synthesize lunchStopDateTime;
@synthesize exitDateTime;
@synthesize entranceDate;
@synthesize exitDate;
@synthesize entranceTime;
@synthesize exitTime;
@synthesize lunchStartTime;
@synthesize lunchStopTime;
@synthesize workedTime;
@synthesize lunchTime;
@synthesize totalTime;
@synthesize index;

- (id)init {
    
    self = [super init];
    
    return self;
}

- (id)initWithShiftId:(int)theShiftId {
    
    self = [self init];
    
    [self setShiftId:theShiftId];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:shiftId forKey:@"shiftId"];
    [encoder encodeInt:companyId forKey:@"companyId"];
    [encoder encodeInt:employeeId forKey:@"employeeId"];
    [encoder encodeInt:index forKey:@"index"];
    [encoder encodeObject:employeeName forKey:@"employeeName"];
    [encoder encodeObject:entranceDateTime forKey:@"entranceDateTime"];
    [encoder encodeObject:entranceDate forKey:@"entranceDate"];
    [encoder encodeObject:entranceTime forKey:@"entranceTime"];
    [encoder encodeObject:exitDateTime forKey:@"exitDateTime"];
    [encoder encodeObject:exitTime forKey:@"exitTime"];
    [encoder encodeObject:lunchStartDateTime forKey:@"lunchStartDateTime"];
    [encoder encodeObject:lunchStopDateTime forKey:@"lunchStopDateTime"];
    [encoder encodeObject:lunchStartTime forKey:@"lunchStartTime"];
    [encoder encodeObject:lunchStopTime forKey:@"lunchStopTime"];
    [encoder encodeObject:workedTime forKey:@"workedTime"];
    [encoder encodeObject:lunchTime forKey:@"lunchTime"];
    [encoder encodeObject:totalTime forKey:@"totalTime"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [self init];
    
    [self setShiftId: [decoder decodeIntForKey:@"shiftId"]];
    [self setCompanyId: [decoder decodeIntForKey:@"companyId"]];
    [self setEmployeeId: [decoder decodeIntForKey:@"employeeId"]];
    [self setIndex: [decoder decodeIntForKey:@"index"]];
    [self setEmployeeName: [decoder decodeObjectForKey:@"employeeName"]];
    [self setEntranceDateTime: [decoder decodeObjectForKey:@"entranceDateTime"]];
    [self setEntranceDate: [decoder decodeObjectForKey:@"entranceDate"]];
    [self setEntranceTime: [decoder decodeObjectForKey:@"entranceTime"]];
    [self setLunchStartTime: [decoder decodeObjectForKey:@"lunchStartTime"]];
    [self setLunchStopTime: [decoder decodeObjectForKey:@"lunchStopTime"]];
    [self setLunchStartDateTime: [decoder decodeObjectForKey:@"lunchStartDateTime"]];
    [self setLunchStopDateTime: [decoder decodeObjectForKey:@"lunchStopDateTime"]];
    [self setExitDateTime: [decoder decodeObjectForKey:@"exitDateTime"]];
    [self setExitTime: [decoder decodeObjectForKey:@"exitTime"]];
    [self setWorkedTime: [decoder decodeObjectForKey:@"workedTime"]];
    [self setLunchTime: [decoder decodeObjectForKey:@"lunchTime"]];
    [self setTotalTime: [decoder decodeObjectForKey:@"totalTime"]];
    
    return self;
}

-(NSString *)employeeName {
    
    return [employeeName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)entranceDateTime {
    
    return [entranceDateTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)entranceDate {
    
    return [entranceDate stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)entranceTime {
    
    return [entranceTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)exitTime {
    
    return [exitTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)exitDateTime {
    
    return [exitDateTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)lunchStartDateTime {
    
    return [lunchStartDateTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)lunchStopDateTime {
    
    return [lunchStopDateTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)lunchStartTime {
    
    return [lunchStartTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)lunchStopTime {
    
    return [lunchStopTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)workedTime {
    
    return [workedTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)lunchTime {
    
    return [lunchTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSString *)totalTime {
    
    return [totalTime stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)shiftArrayPath:(int)employeeId {
    
    NSArray*	documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*	path = nil;
	
    if (documentDir)
        path = [documentDir objectAtIndex:0];
	
    return [NSString stringWithFormat:@"%@/Shift-%i.data", path, employeeId];
    
//    return (@"Shift.data");
}

+ (NSMutableArray *)loadList:(int)employeeId limit:(int)limit {
    
    return [Shift loadList:employeeId limit:limit force:NO];
}

+ (NSMutableArray *)loadList:(int)employeeId limit:(int)limit force:(BOOL)force {
    
    NSMutableArray *shiftList;
    
    NSLog(@"force: %i", force);
    
    if( force == NO )
        shiftList = [Shift loadArchivedList: employeeId];
    
    if( force == YES || shiftList == nil ){
        
        TimesheetAppDelegate *appDelegate = (TimesheetAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/timesheet/getXml/model/shift/employeeId/%i/limit/%i/deviceUDID/%@", serverAddress, employeeId, limit, appDelegate.deviceUDID]];
        
        XMLShiftParser *shiftParser = [[XMLShiftParser alloc] initXMLParser];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:45];
        NSError *requestError = nil;
        NSData *response      = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&requestError];
        BOOL success;
        
        NSLog(@"url: %@", url);
        
        if( requestError == nil) {
            
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:response];
            
            [parser setDelegate:shiftParser];
            [parser setShouldProcessNamespaces:YES];
            [parser setShouldReportNamespacePrefixes:YES];
            [parser setShouldResolveExternalEntities:NO];
            success = [parser parse];
            
            shiftList = [shiftParser getShiftList];
            
//            NSLog(@"filePath: %@", [Shift shiftArrayPath]);
            
            [NSKeyedArchiver archiveRootObject:shiftList toFile:[Shift shiftArrayPath: employeeId]];
        }
    }
    
//    shiftList = [Shift sort:shiftList];

    return shiftList;
}

+ (NSMutableArray *)loadArchivedList:(int)employeeId {
    
    NSMutableArray *shiftList;
    NSString *shiftPath = [Shift shiftArrayPath: employeeId];
    
    shiftList = [NSKeyedUnarchiver unarchiveObjectWithFile:shiftPath];
    
    if( !shiftList )
        shiftList = [NSMutableArray array];
    
    return shiftList;
}

+ (void)removeCache:(int)employeeId {
    
    [[NSFileManager defaultManager] removeItemAtPath:[Shift shiftArrayPath: employeeId] error:nil];
}

+(NSMutableArray *)sort:(NSMutableArray *)aShiftList {
    
    NSArray *sorted = [aShiftList sortedArrayUsingComparator:^(id obj1, id obj2){
        
        if ([obj1 isKindOfClass:[Shift class]] && [obj2 isKindOfClass:[Shift class]]) {
            Shift *s1 = (Shift*)obj1;
            Shift *s2 = (Shift*)obj2;

            if (s1.index > s2.index) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (s1.index < s2.index) {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }
        
        // TODO: default is the same?
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return [[NSMutableArray alloc] initWithArray:sorted];
}

-(NSString *)description {
    
    return [NSString stringWithFormat:@"id: %i, employeeName: %@, entranceDateTime: %@, lunchStartDateTime: %@, lunchStopDateTime: %@, exitDateTime: %@", employeeId, employeeName, entranceDateTime, lunchStartDateTime, lunchStopDateTime, exitDate];
}

@end
