//
//  LoadingViewController.m
//  meh.com
//
//  Created by Kirin Patel on 5/4/19.
//  Copyright © 2019 Kirin Patel. All rights reserved.
//

#import "LoadingViewController.h"
#import "meh_com-Swift.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    UILabel * titleLabel = [UILabel new];
    titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    titleLabel.text = @"eh for meh";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setFont: [UIFont preferredFontForTextStyle:UIFontTextStyleLargeTitle]];
    [self.view addSubview:titleLabel];
    [[titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor constant:0] setActive:true];
    [[titleLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:0] setActive:true];
    [self loadCurrentTheme];
}

- (void)loadCurrentTheme {
    [ThemeLoader.shared loadThemeWithCompletion: ^(Theme * theme) {
        MainViewController *view = [[MainViewController alloc] init];
        view.theme = theme;
        view.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:view animated:true completion:NULL];
    }];
}

@end
