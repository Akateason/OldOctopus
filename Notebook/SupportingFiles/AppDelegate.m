//
//  AppDelegate.m
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "AppDelegate.h"
#import "OctWebEditor.h"
#import "OctGuidingVC.h"
#import "MDNavVC.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "OctMBPHud.h"
#import "OctRequestUtil.h"
#import <XTIAP/XTIAP.h>
#import "OcHomeVC.h"

#ifdef ISMAC
#import <AppKit/AppKit.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)test {
    
}





- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef ISMAC
    self.window.windowScene.titlebar.titleVisibility = UITitlebarTitleVisibilityHidden;//隐藏顶栏
    self.window.windowScene.sizeRestrictions.minimumSize = CGSizeMake(1034, 808) ;
#endif
    
    // lauching events
    self.launchingEvents = [[LaunchingEvents alloc] init] ;
    [self.launchingEvents setup:application appdelegate:self] ;
    
    // set Root Controller START
    OctGuidingVC *guidVC = [OctGuidingVC getMe] ;
    if (guidVC != nil) {
        MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:guidVC] ;
        self.window.rootViewController = navVC ;
        [self.window makeKeyAndVisible] ;        
    }
    else {
        UIViewController *vc = [OcHomeVC getMe] ;
        self.window.rootViewController = vc ;
        [self.window makeKeyAndVisible] ;
    }
    // set Root Controller END
    
    
        
    [self test] ;
    
    return YES ;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {

    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    NSString *alertBody = cloudKitNotification.alertBody;
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        CKRecordID *recordID = [(CKQueryNotification *)cloudKitNotification recordID] ;
    }

    [self.launchingEvents icloudSync:^{
        completionHandler(UIBackgroundFetchResultNewData);
    }] ;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [self.launchingEvents icloudSync:^{
        completionHandler(UIBackgroundFetchResultNewData);
    }] ;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSArray *list = [Note xt_findWhere:@"isDeleted == 0"] ;
    for (Note *aNote in list) {
        @autoreleasepool {
            NSString *path = XT_DOCUMENTS_PATH_TRAIL_(XT_STR_FORMAT(@"%@.md",aNote.icRecordName)) ;
            [aNote.content writeToFile:path atomically:YES encoding:(NSUTF8StringEncoding) error:nil] ;
        }
    }
}

static NSString *const kUD_Guiding_mark = @"kUD_Guiding_mark" ;
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[OctMBPHud sharedInstance] hide] ;
    
    // clear documents
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folder = [XTArchive getDocumentsPath] ;
    [fileManager removeItemAtPath:folder error:nil];
}

//导入文件,默认导入到当前的笔记本,如果是最近或者垃圾桶,进入暂存区. 导入之后打开此笔记.
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self.launchingEvents application:app openURL:url options:options] ;
}


#pragma mark --
#pragma mark - screen rotate

- (BOOL)shouldAutorotate {
#ifdef ISMAC
    return NO ;
#endif
        
    if (IS_IPAD) {
        return YES ;
    }
    return NO ;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
#ifdef ISMAC
    return UIInterfaceOrientationMaskPortrait ;
#endif
    
    
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskAll ;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)nowWindow {
#ifdef ISMAC
    return UIInterfaceOrientationMaskPortrait ;
#endif

    
    if (IS_IPAD) {
        return UIInterfaceOrientationMaskAll ;
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark --
#pragma mark - Mac Menu

- (void)buildMenuWithBuilder:(id<UIMenuBuilder>)builder {
    [super buildMenuWithBuilder:builder];
    
    if (builder.system == UIMenuSystem.mainSystem) {
        [builder removeMenuForIdentifier:UIMenuFormat] ;
        [builder removeMenuForIdentifier:UIMenuEdit] ;
                
        // 文件
        UIKeyCommand *newNote = [UIKeyCommand commandWithTitle:@"新建笔记" image:nil action:@selector(actonNewNote) input:@"N" modifierFlags:UIKeyModifierCommand | UIKeyModifierShift propertyList:nil];
        UIKeyCommand *newBook = [UIKeyCommand commandWithTitle:@"新建笔记本" image:nil action:@selector(actonNewBook) input:@"N" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIMenu *openMenu = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.file" options:UIMenuOptionsDisplayInline children:@[newNote,newBook]];
        [builder insertChildMenu:openMenu atStartOfMenuForIdentifier:UIMenuFile];
        
        // 编辑
        UIKeyCommand *allSelect = [UIKeyCommand commandWithTitle:@"全选" image:nil action:@selector(actionAllSelect) input:@"A" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *undo = [UIKeyCommand commandWithTitle:@"撤销" image:nil action:@selector(actionUndo) input:@"Z" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *redo = [UIKeyCommand commandWithTitle:@"重做" image:nil action:@selector(actionRedo) input:@"Z" modifierFlags:UIKeyModifierCommand | UIKeyModifierShift propertyList:nil];
        UIMenu *editMenuGroup1 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.edit.g1" options:UIMenuOptionsDisplayInline children:@[allSelect,undo,redo]];
        
        UIKeyCommand *paraRepeat = [UIKeyCommand commandWithTitle:@"重复段落" image:nil action:@selector(actionParaRepeat) input:@"P" modifierFlags:UIKeyModifierCommand | UIKeyModifierShift propertyList:nil] ;
        UIKeyCommand *paraNew = [UIKeyCommand commandWithTitle:@"新建段落" image:nil action:@selector(actionParaNew) input:@"B" modifierFlags:UIKeyModifierCommand | UIKeyModifierShift propertyList:nil] ;
        UIKeyCommand *paraDelete = [UIKeyCommand commandWithTitle:@"删除段落" image:nil action:@selector(actionParaDelete) input:@"D" modifierFlags:UIKeyModifierCommand | UIKeyModifierShift propertyList:nil] ;
        UIMenu *editMenuGroup2 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.edit.g2" options:UIMenuOptionsDisplayInline children:@[paraRepeat,paraNew,paraDelete]] ;
                
        UIMenu *editMenu = [UIMenu menuWithTitle:@"编辑" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.edit" options:nil children:@[editMenuGroup1, editMenuGroup2]] ;
        [builder insertSiblingMenu:editMenu afterMenuForIdentifier:UIMenuFile];
        
        // 段落
        UIKeyCommand *title1 = [UIKeyCommand commandWithTitle:@"标题1" image:nil action:@selector(actionTitle1) input:@"1" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *title2 = [UIKeyCommand commandWithTitle:@"标题2" image:nil action:@selector(actionTitle2) input:@"2" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *title3 = [UIKeyCommand commandWithTitle:@"标题3" image:nil action:@selector(actionTitle3) input:@"3" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *title4 = [UIKeyCommand commandWithTitle:@"标题4" image:nil action:@selector(actionTitle4) input:@"4" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *title5 = [UIKeyCommand commandWithTitle:@"标题5" image:nil action:@selector(actionTitle5) input:@"5" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *title6 = [UIKeyCommand commandWithTitle:@"标题6" image:nil action:@selector(actionTitle6) input:@"6" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIMenu *paraMenuGroup1 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.para.group1" options:UIMenuOptionsDisplayInline children:@[title1,title2,title3,title4,title5,title6]] ;

        UIKeyCommand *upTitle = [UIKeyCommand commandWithTitle:@"升级标题" image:nil action:@selector(actionUpTitle) input:@"+" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *downTitle = [UIKeyCommand commandWithTitle:@"升级标题" image:nil action:@selector(actionDownTitle) input:@"-" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIMenu *paraMenuGroup2 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.para.group2" options:UIMenuOptionsDisplayInline children:@[upTitle,downTitle]] ;

        UIKeyCommand *form = [UIKeyCommand commandWithTitle:@"表格" image:nil action:@selector(actionForm) input:@"T" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *codeBlock = [UIKeyCommand commandWithTitle:@"代码块" image:nil action:@selector(actionCodeBlock) input:@"C" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate propertyList:nil];
        UIKeyCommand *quote = [UIKeyCommand commandWithTitle:@"引用块" image:nil action:@selector(actionQuote) input:@"Q" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate propertyList:nil];
        UIKeyCommand *math = [UIKeyCommand commandWithTitle:@"数学公式块" image:nil action:@selector(actionMath) input:@"M" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate propertyList:nil];
        UIKeyCommand *html = [UIKeyCommand commandWithTitle:@"HTML块" image:nil action:@selector(actionHtml) input:@"J" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate propertyList:nil];
        UIMenu *paraMenuGroup3 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.para.group3" options:UIMenuOptionsDisplayInline children:@[form,codeBlock,quote,math,html]] ;

        UIKeyCommand *oList = [UIKeyCommand commandWithTitle:@"有序列表" image:nil action:@selector(actionOList) input:@"O" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate propertyList:nil];
        UIKeyCommand *uList = [UIKeyCommand commandWithTitle:@"无序列表" image:nil action:@selector(actionUList) input:@"U" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate propertyList:nil];
        UIKeyCommand *tList = [UIKeyCommand commandWithTitle:@"任务列表" image:nil action:@selector(actionTList) input:@"X" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate propertyList:nil];
        UIMenu *paraMenuGroup4 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.para.group4" options:UIMenuOptionsDisplayInline children:@[oList,uList,tList]] ;
        
        UIKeyCommand *switchList = [UIKeyCommand commandWithTitle:@"切换loose/tight列表" image:nil action:@selector(actionSwitchList) input:@"L" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate propertyList:nil];
        UIMenu *paraMenuGroup5 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.para.group5" options:UIMenuOptionsDisplayInline children:@[switchList]] ;

        UIKeyCommand *para = [UIKeyCommand commandWithTitle:@"段落" image:nil action:@selector(actionOpenPara) input:@"O" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *sepline = [UIKeyCommand commandWithTitle:@"水平分割线" image:nil action:@selector(actionSepline) input:@"-" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate propertyList:nil];
        UIMenu *paraMenuGroup6 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.para.group6" options:UIMenuOptionsDisplayInline children:@[para,sepline]] ;

        UIMenu *paraMenu = [UIMenu menuWithTitle:@"段落" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.para" options:nil children:@[paraMenuGroup1, paraMenuGroup2,paraMenuGroup3,paraMenuGroup4,paraMenuGroup5,paraMenuGroup6]] ;
        [builder insertSiblingMenu:paraMenu afterMenuForIdentifier:@"im.shimo.chuxin.octupus.Notebook.menu.edit"];

        // 样式
        UIKeyCommand *bold = [UIKeyCommand commandWithTitle:@"重点" image:nil action:@selector(actionBold) input:@"B" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *italic = [UIKeyCommand commandWithTitle:@"强调" image:nil action:@selector(actionItalic) input:@"I" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *inlineCode = [UIKeyCommand commandWithTitle:@"行内代码" image:nil action:@selector(actionInlineCode) input:@"`" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *delLine = [UIKeyCommand commandWithTitle:@"删除线" image:nil action:@selector(actionDeleteLine) input:@"D" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *link = [UIKeyCommand commandWithTitle:@"链接" image:nil action:@selector(actionLink) input:@"L" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *picture = [UIKeyCommand commandWithTitle:@"图片" image:nil action:@selector(actionPicture) input:@"I" modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate  propertyList:nil];
        UIMenu *styleMenuGroup1 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.style.group1" options:UIMenuOptionsDisplayInline children:@[bold,italic,inlineCode,delLine,link,picture]] ;
        
        UIKeyCommand *clearStyle = [UIKeyCommand commandWithTitle:@"清除样式" image:nil action:@selector(actionClearStyle) input:@"R" modifierFlags:UIKeyModifierCommand | UIKeyModifierShift  propertyList:nil];
        UIMenu *styleMenuGroup2 = [UIMenu menuWithTitle:@"" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.style.group2" options:UIMenuOptionsDisplayInline children:@[clearStyle]] ;
        UIMenu *styleMenu = [UIMenu menuWithTitle:@"样式" image:nil identifier:@"im.shimo.chuxin.octupus.Notebook.menu.style" options:nil children:@[styleMenuGroup1, styleMenuGroup2]] ;
        [builder insertSiblingMenu:styleMenu afterMenuForIdentifier:@"im.shimo.chuxin.octupus.Notebook.menu.para"];

        
    }
}

- (void)actonNewNote {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_addNote object:nil] ;
}

- (void)actonNewBook {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_addBook object:nil] ;
}

- (void)actionAllSelect {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionUndo {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionRedo {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionParaRepeat {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionParaNew {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionParaDelete {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionTitle1 {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionTitle2 {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionTitle3 {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionTitle4 {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionTitle5 {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionTitle6 {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionUpTitle {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionDownTitle {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionForm {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionCodeBlock {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionQuote {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionMath {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionHtml {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionOList {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionUList {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionTList {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionSwitchList {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionOpenPara {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}
- (void)actionSepline {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionBold {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionItalic {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;

}

- (void)actionInlineCode {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionDeleteLine {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionLink {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionPicture {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

- (void)actionClearStyle {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Menu_Edit_Group object:NSStringFromSelector(_cmd)] ;
}

@end

