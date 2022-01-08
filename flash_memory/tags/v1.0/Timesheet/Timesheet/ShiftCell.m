//
//  ShiftCell.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-07.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "ShiftCell.h"

@implementation ShiftCell
@synthesize lblEntranceDate;
@synthesize lblPeriod;
@synthesize lblWorkedTime;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
