//
//  XMLEmployeeParser.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-10.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "XMLEmployeeParser.h"
#import "Employee.h"

@implementation XMLEmployeeParser

@synthesize employee;
@synthesize employeeList;

- (XMLEmployeeParser *) initXMLParser{
    
    //    [super init];
    
    [self resetEmployeeList];
    
    return self;
}

- (void)parsingDidTimeout {
    
    [[[UIAlertView alloc] initWithTitle:@"Erro" message:@"Não foi possível carregar as informações de controle de horas." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    //    NSLog(@"didStartElement");
    
    if([elementName isEqualToString:@"employee"]){
        
        int employeeId = [[attributeDict objectForKey:@"id"] integerValue];
        int companyId = [[attributeDict objectForKey:@"companyId"] integerValue];
        
        employee = [[Employee alloc] initWithEmployeeId:employeeId];
        [employee setCompanyId:companyId];
        
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    //    NSLog(@"foundCharacters");
    
    if(!currentElementValue)
        currentElementValue = [[NSMutableString alloc] initWithString:string];
    else
        [currentElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    //    NSLog(@"didEndElement");
    
    if([elementName isEqualToString:@"employees"])
        return;
    
    if([elementName isEqualToString:@"employee"]) {
        [employeeList addObject:employee];
        
        employee = nil;
    }else{
        
        //        NSString *elementValue = [currentElementValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //        if( [elementName isEqualToString:@"buyin"] )
        //            [employee setBuyin:[elementValue floatValue]];
        //        else
        [employee setValue:currentElementValue forKey:elementName];
    }
    
    currentElementValue = nil;
}

- (NSMutableArray *) getEmployeeList {
    
    return employeeList;
}

- (void) resetEmployeeList {
    
    if( employeeList )
        employeeList = nil;
    
    employeeList = [[NSMutableArray alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
}

@end
