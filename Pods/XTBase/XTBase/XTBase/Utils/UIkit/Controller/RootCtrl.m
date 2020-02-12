//
//  RootCtrl.m
//  Teason
//
//  Created by ; on 14-8-21.
//  Copyright (c) 2014年 TEASON. All rights reserved.
//

#import "RootCtrl.h"
#import "XTlibConfig.h"

@interface RootCtrl ()

@end


@implementation RootCtrl

- (void)prepare {
    // prepare when initial
}

- (void)prepareUI {
    // prepare UI
}

#pragma mark--
#pragma mark - Life

- (void)dealloc {
    NSLog(@"xt : dealloc --- %@\n -----", NSStringFromClass(self.class));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"xt WARN : didReceiveMemoryWarning --- %@\n -----", NSStringFromClass(self.class));
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self prepare];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customTitle];
    [self prepareUI];
    NSLog(@"xt : viewDidLoad --- %@", NSStringFromClass(self.class)) ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([XTlibConfig sharedInstance].isShowControllerLifeCycle) {NSLog(@"xt : viewWillAppear --- %@", NSStringFromClass(self.class))};
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([XTlibConfig sharedInstance].isShowControllerLifeCycle) {NSLog(@"xt : viewWillDisappear --- %@", NSStringFromClass(self.class))};
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([XTlibConfig sharedInstance].isShowControllerLifeCycle) {NSLog(@"xt : viewDidAppear --- %@", NSStringFromClass(self.class))};
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([XTlibConfig sharedInstance].isShowControllerLifeCycle) {NSLog(@"xt : viewDidDisappear --- %@", NSStringFromClass(self.class))};
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if ([XTlibConfig sharedInstance].isShowControllerLifeCycle) {NSLog(@"xt : viewWillLayoutSubviews --- %@", NSStringFromClass(self.class))};
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([XTlibConfig sharedInstance].isShowControllerLifeCycle) {NSLog(@"xt : viewDidLayoutSubviews --- %@", NSStringFromClass(self.class))};
}

#pragma mark--
#pragma mark - prop

- (NSString *)customTitle {
    if (!_customTitle) _customTitle = self.title;
    return _customTitle;
}

@end
