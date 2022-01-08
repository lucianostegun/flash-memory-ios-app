//
//  Shift.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-06.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shift : NSObject <NSCoding> {

}

@property (nonatomic, readwrite) int companyId;
@property (nonatomic, readwrite) int shiftId;
@property (nonatomic, readwrite) int employeeId;
@property (nonatomic, readwrite) int index;
@property (nonatomic, retain) NSString *employeeName;
@property (nonatomic, retain) NSString *entranceDateTime;
@property (nonatomic, retain) NSString *lunchStartDateTime;
@property (nonatomic, retain) NSString *lunchStopDateTime;
@property (nonatomic, retain) NSString *exitDateTime;
@property (nonatomic, retain) NSString *entranceDate;
@property (nonatomic, retain) NSString *exitDate;
@property (nonatomic, retain) NSString *entranceTime;
@property (nonatomic, retain) NSString *exitTime;
@property (nonatomic, retain) NSString *lunchStartTime;
@property (nonatomic, retain) NSString *lunchStopTime;
@property (nonatomic, retain) NSString *workedTime;
@property (nonatomic, retain) NSString *lunchTime;
@property (nonatomic, retain) NSString *totalTime;

- (id)initWithShiftId:(int)theShiftId;
-(NSString *)employeeName;
-(NSString *)entranceDate;
-(NSString *)entranceTime;
-(NSString *)exitTime;
-(NSString *)lunchStartTime;
-(NSString *)lunchStopTime;
-(NSString *)workedTime;

+ (NSMutableArray *)loadList:(int)employeeId limit:(int)limit;
+ (NSMutableArray *)loadList:(int)employeeId limit:(int)limit force:(BOOL)force;
+ (NSMutableArray *)sort:(NSMutableArray *)aShiftList;
+ (NSString *)shiftArrayPath:(int)employeeId;
+ (NSMutableArray *)loadArchivedList:(int)employeeId;
+ (void)removeCache:(int)employeeId;

@end
