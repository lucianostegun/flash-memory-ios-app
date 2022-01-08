//
//  XMLEmployeeParser.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-10.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Employee;

@interface XMLEmployeeParser : NSObject <NSXMLParserDelegate> {
    
    NSMutableString *currentElementValue;
    
    Employee *employee;
    NSMutableArray *employeeList;
}

@property (nonatomic, copy) NSMutableArray *employeeList;
@property (nonatomic, retain) Employee *employee;

- (XMLEmployeeParser *) initXMLParser;
- (NSMutableArray *) getEmployeeList;
- (void) resetEmployeeList;
@end
