//
//  ExpandableTableViewController.h
//
//  Created by Ruchir on 29/10/14.
//

#import <UIKit/UIKit.h>

@class ExpandableTableViewController;

@interface ExpandableTableDataNode : NSObject

@property (nonatomic, strong) NSString* mainHeader;
@property (nonatomic, strong) NSArray* items; // should be array of strings

@end

@protocol ExpandableTableViewControllerDelegate <NSObject>

-(void)ExpandableTableViewController:(ExpandableTableViewController*) controller
           DidSelectItemsAtIndexPath:(NSArray*) indexPaths
                        WithUserInfo:(id) userInfo;
@end

@interface ExpandableTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id userInfo;
@property (nonatomic, weak) id<ExpandableTableViewControllerDelegate> delegate;
@property (nonatomic, assign)   BOOL        hideToolbar;

-(void) ConfigureForData:(NSArray*) expandableData;

-(NSArray*) SelectedItems;

@end
