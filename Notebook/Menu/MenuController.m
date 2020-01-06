//
//  MenuController.m
//  Notebook
//
//  Created by teason23 on 2020/1/6.
//  Copyright © 2020 teason23. All rights reserved.
//

#import "MenuController.h"

@implementation MenuController

- (instancetype)initWithBuilder:(id<UIMenuBuilder>)builder
{
    self = [super init];
    if (self) {
        [builder removeMenuForIdentifier:UIMenuFormat] ;
        [builder removeMenuForIdentifier:UIMenuEdit] ;
                
        UICommand * fileMenuCommend = [UICommand commandWithTitle:@"继续皮" image:nil action:@selector(jixuOpenAction) propertyList:nil];
        //有快捷键
        UIKeyCommand * openMenuCommend = [UIKeyCommand commandWithTitle:@"皮一下" image:nil action:@selector(openAction) input:@"O" modifierFlags:UIKeyModifierCommand propertyList:nil];//注意两个action不能一样
        UIMenu * openMenu = [UIMenu menuWithTitle:@"" image:nil identifier:@"com.example.apple-samplecode.menus.openMenu" options:UIMenuOptionsDisplayInline children:@[openMenuCommend,fileMenuCommend]];
        [builder insertChildMenu:openMenu atStartOfMenuForIdentifier:UIMenuFile];
    //添加新的menu
        UICommand * cityCommend = [UICommand commandWithTitle:@"青岛" image:nil action:@selector(openActionP) propertyList:@"青岛"];
         UIKeyCommand * cityMenuCommend = [UIKeyCommand commandWithTitle:@"济南" image:nil action:@selector(openActionD) input:@"P" modifierFlags:UIKeyModifierCommand propertyList:@"济南"];
        UIMenu * cityMenu = [UIMenu menuWithTitle:@"城市" image:nil identifier:@"com.example.apple-samplecode.menus.cityMenu" options:@[] children:@[cityCommend,cityMenuCommend]];
        [builder insertSiblingMenu:cityMenu afterMenuForIdentifier:UIMenuFile];//添加到文件菜单之后

        
//        builder.remove(menu: .format)
            
            // Create and add "Open" menu command at the beginning of the File menu.
//            builder.insertChild(MenuController.openMenu(), atStartOfMenu: .file)
//
//            // Create and add "New" menu command at the beginning of the File menu.
//            builder.insertChild(MenuController.newMenu(), atStartOfMenu: .file)
            
            // Add the rest of the menus to the menu bar.

            // Add the Cities menu.
//            builder.insertSibling(MenuController.citiesMenu(), beforeMenu: .window)
//
//            // Add the Navigation menu.
//            builder.insertSibling(MenuController.navigationMenu(), beforeMenu: .window)
//
//            // Add the Style menu.
//            builder.insertSibling(MenuController.fontStyleMenu(), beforeMenu: .window)
            
            // Add the Tools menu.

    }
    return self;
}


@end
