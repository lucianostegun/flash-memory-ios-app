//
//  XMLShiftParser.m
//  iRank
//
//  Created by Luciano Stegun on 2013-07-06.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "XMLShiftParser.h"
#import "Shift.h"

@implementation XMLShiftParser

@synthesize shift;
@synthesize shiftList;

- (XMLShiftParser *) initXMLParser{
    
//    [super init];
    
    [self resetShiftList];
    
    index = 0;
    
    return self;
}

- (void)parsingDidTimeout {
    
    [[[UIAlertView alloc] initWithTitle:@"Erro" message:@"Não foi possível carregar as informações de controle de horas." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
//    NSLog(@"didStartElement");
    
    if([elementName isEqualToString:@"shift"]){
        
        int shiftId = [[attributeDict objectForKey:@"id"] integerValue];
        int companyId = [[attributeDict objectForKey:@"companyId"] integerValue];
        
        shift = [[Shift alloc] initWithShiftId:shiftId];
        [shift setCompanyId:companyId];
        [shift setIndex:index++];
        
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
    
    if([elementName isEqualToString:@"shifts"])
        return;
    
    if([elementName isEqualToString:@"shift"]) {
        [shiftList addObject:shift];
        
        shift = nil;
    }else{
        
//        NSString *elementValue = [currentElementValue stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
//        if( [elementName isEqualToString:@"buyin"] )
//            [shift setBuyin:[elementValue floatValue]];
//        else
            [shift setValue:currentElementValue forKey:elementName];
    }
    
    currentElementValue = nil;
}

- (NSMutableArray *) getShiftList {
    
    return shiftList;
}

- (void) resetShiftList {
    
    if( shiftList )
        shiftList = nil;
    
    shiftList = [[NSMutableArray alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
}

@end
