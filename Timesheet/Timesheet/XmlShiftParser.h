//
//  XMLShiftParser.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-06.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shift;

@interface XMLShiftParser : NSObject <NSXMLParserDelegate> {
    
    NSMutableString *currentElementValue;
    
    Shift *shift;
    NSMutableArray *shiftList;
    
    int index;
}

@property (nonatomic, copy) NSMutableArray *shiftList;
@property (nonatomic, retain) Shift *shift;

- (XMLShiftParser *) initXMLParser;
- (NSMutableArray *) getShiftList;
- (void) resetShiftList;
@end
