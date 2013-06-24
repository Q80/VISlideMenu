//
//  VICenterViewController.m
//  VISlideMenu
//
//  Created by Junior B. on 20.6.13.
//  Copyright (c) 2013 Vilea. All rights reserved.
//

#import "VICenterViewController.h"
#import "VISlideMenuViewController.h"
#import "VISideViewController.h"

@interface VICenterViewController ()

@end

@implementation VICenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"center";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (VISlideMenuViewController *)slideMenuViewController
{
    return (VISlideMenuViewController *)[[self parentViewController] parentViewController];
}

- (IBAction)removeLeftView:(id)sender
{
    [[self slideMenuViewController] setLeftViewController:nil];
}

- (IBAction)removeRightView:(id)sender
{
    [[self slideMenuViewController] setRightViewController:nil];
}

- (IBAction)replaceRightView:(id)sender
{
    VISideViewController *sideRight = [[VISideViewController alloc] initWithNibName:@"VISideViewController" bundle:nil];
    sideRight.title = @"New Right";
    [[self slideMenuViewController] setRightViewController:sideRight];
}

- (IBAction)replaceLeftView:(id)sender
{
    VISideViewController *sideLeft = [[VISideViewController alloc] initWithNibName:@"VISideViewController" bundle:nil];
    sideLeft.title = @"New Left";
    [[self slideMenuViewController] setLeftViewController:sideLeft];
}

@end
