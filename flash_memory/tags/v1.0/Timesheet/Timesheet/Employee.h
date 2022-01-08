//
//  Employee.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-10.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Employee : NSObject <NSCoding> {
    
    
}

@property (nonatomic, readwrite) int companyId;
@property (nonatomic, readwrite) int employeeId;
@property (nonatomic, retain) NSString *employeeName;
@property (nonatomic, retain) NSString *emailAddress;

- (id)initWithEmployeeId:(int)theEmployeeId;
- (NSString *)employeeName;
- (NSString *)emailAddress;
- (BOOL)deleteRemote;

+ (NSMutableArray *)loadList:(int)companyId limit:(int)limit;
+ (NSMutableArray *)loadList:(int)companyId limit:(int)limit force:(BOOL)force;
+ (NSString *)employeeArrayPath:(int)companyId;
+ (NSMutableArray *)loadArchivedList:(int)companyId;
+ (void)removeCache:(int)companyId;

@end
