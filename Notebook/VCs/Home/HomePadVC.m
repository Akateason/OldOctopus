//
//  HomePadVC.m
//  Notebook
//
//  Created by teason23 on 2019/6/20.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomePadVC.h"
#import "HomeVC.h"
#import "MarkdownVC.h"

@interface HomePadVC ()
@property (strong, nonatomic) UIView        *leftContainer ;
@property (strong, nonatomic) UIView        *rightContainer ;
@property (strong, nonatomic) HomeVC        *homeVC ;
@property (strong, nonatomic) MarkdownVC    *editorVC ;
@end

@implementation HomePadVC

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    _homeVC = [HomeVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"HomeVC"] ;
    _editorVC = [MarkdownVC newWithNote:[Note new] bookID:@"1" fromCtrller:_homeVC] ;
    //[MarkdownVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"MarddownVC"] ;
//    _editorVC.aNote = [Note new] ;
//    _editorVC.delegate = _homeVC ;
//    _editorVC.myBookID = @"0" ;
    
    _leftContainer = [UIView new] ;
    _leftContainer.width = 400 ;
    _leftContainer.height = self.view.height ;
    _leftContainer.left = self.view.left ;
    _leftContainer.top = self.view.top ;
    _leftContainer.bottom = self.view.bottom ;
    [self.view addSubview:_leftContainer] ;
    
    _rightContainer = [UIView new] ;
    _rightContainer.width = APP_WIDTH - 400 ;
    _rightContainer.height = self.view.height ;
    _rightContainer.left = 400 ;
    _rightContainer.top = self.view.top ;
    _rightContainer.bottom = self.view.bottom ;
    [self.view addSubview:_rightContainer] ;
    
    _homeVC.view.frame = _leftContainer.bounds ;
    [_leftContainer addSubview:_homeVC.view] ;
    _editorVC.view.frame = _rightContainer.bounds ;
    [_rightContainer addSubview:_editorVC.view] ;
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
