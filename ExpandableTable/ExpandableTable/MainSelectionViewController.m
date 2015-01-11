//
//  MainSelectionViewController.m
//  ExpandableTable
//
//  Created by Ruchir on 11/01/15.
//  Copyright (c) 2015 RYV. All rights reserved.
//

#import "MainSelectionViewController.h"
#import "ExpandableTableViewController.h"

@interface MainSelectionViewController ()

@end

@implementation MainSelectionViewController

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExpandableTableViewController* expTable = [ExpandableTableViewController new];
    
    if ([indexPath row] == 0)
    {
        NSMutableArray* tableDataNodes = [NSMutableArray new];
        
        for (int iter = 0; iter < 10; iter++)
        {
            ExpandableTableDataNode* dataNode = [ExpandableTableDataNode new];
            dataNode.mainHeader = [NSString stringWithFormat:@"Section %d", (iter + 1)];
            
            NSMutableArray* itemTitles = [NSMutableArray new];
            dataNode.items = itemTitles;
            
            for (int innerIter = 0 ; innerIter < 10; innerIter++)
            {
                [itemTitles addObject:[NSString stringWithFormat:@"Item %d", (innerIter + 1)]];
            }
            
            [tableDataNodes addObject:dataNode];
        }
        
        [expTable ConfigureForData:tableDataNodes];
    }
    
    
    [self.navigationController pushViewController:expTable animated:YES];
}

@end
