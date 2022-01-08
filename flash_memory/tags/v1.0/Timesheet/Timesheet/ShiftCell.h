//
//  ShiftCell.h
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-07.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShiftCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UILabel *lblEntranceDate;
@property (weak, nonatomic) IBOutlet UILabel *lblPeriod;
@property (weak, nonatomic) IBOutlet UILabel *lblWorkedTime;


@end
