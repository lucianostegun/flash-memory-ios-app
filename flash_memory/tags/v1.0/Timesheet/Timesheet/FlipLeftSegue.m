//
//  FlipLeftSegue.m
//  Timesheet
//
//  Created by Luciano Stegun on 2013-07-04.
//  Copyright (c) 2013 Stegun.com. All rights reserved.
//

#import "FlipLeftSegue.h"

@implementation FlipLeftSegue

- (void)perform
{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    
    [UIView beginAnimations:@"LeftFlip" context:nil];
    [UIView setAnimationDuration:0.8];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:src.view.superview cache:YES];
    [UIView commitAnimations];
    
    [src presentViewController:dst animated:NO completion:nil];
}
@end

@end
