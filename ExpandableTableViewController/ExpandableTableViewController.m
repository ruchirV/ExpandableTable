//
//  ExpandableTableViewController.m
//
//  Created by Ruchir on 29/10/14.
//

#import "ExpandableTableViewController.h"

#define SECTION_TAG_START 101
#define HEADER_SELECTALLBUTTON_TAG 1001
#define HEADER_LABEL_TAG 1002

#define LABEL_SELECTION_COLOR [UIColor colorWithRed:(60.0/255.0) green:(153.0/255.0) blue:(5.0/255.0) alpha:1.0]
#define LABEL_UNSELECTION_COLOR [UIColor darkGrayColor]


@implementation ExpandableTableDataNode

@end

@interface ExpandableTableViewController()

@property (nonatomic, strong)   UITableView*            tableView;
@property (nonatomic, strong)   NSArray*                expandableTableData;
@property (nonatomic, strong)   NSMutableArray*         headerViewArray;
@property (nonatomic, assign)   NSInteger               sectionExpanded;
@property (nonatomic, strong)   NSMutableDictionary*    selectionData;
@property (nonatomic, strong)   NSMutableArray*         selectedIndexPaths;
@property (nonatomic, strong)   UIToolbar*              topToolBar;
@property (nonatomic, strong)   NSLayoutConstraint*     topConstraint;
@end

@implementation ExpandableTableViewController

-(id) init
{
    if (self = [super init])
    {
        [self finishInit];
    }
    
    return self;
}

-(void) finishInit
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    // set the top edge offset properly
    self.automaticallyAdjustsScrollViewInsets = FALSE;
    [self.tableView setContentInset:UIEdgeInsetsMake(22, 0, 0, 0)];
    
    [self.view addSubview:self.tableView];
    
    self.selectedIndexPaths = [NSMutableArray new];
    
    self.topToolBar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.topToolBar setTranslatesAutoresizingMaskIntoConstraints:FALSE];
    
    [self.view addSubview:self.topToolBar];
    
    NSDictionary* viewDictionary = NSDictionaryOfVariableBindings(_tableView, _topToolBar);
    NSArray* constraints = nil;
    
    self.topConstraint = [NSLayoutConstraint constraintWithItem:_tableView
                                                      attribute:NSLayoutAttributeTop
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:self.view
                                                      attribute:NSLayoutAttributeTop
                                                     multiplier:1.0 constant:44.0];
    [self.view addConstraint:self.topConstraint];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_tableView]-0-|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewDictionary];
    [self.view addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewDictionary];
    [self.view addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_topToolBar(44)]"
                                                          options:0
                                                          metrics:nil
                                                            views:viewDictionary];
    [self.view addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_topToolBar]-0-|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewDictionary];
    [self.view addConstraints:constraints];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.hideToolbar)
    {
        [self.topToolBar removeFromSuperview];
        [self.topConstraint setConstant:0];
    }
}

#pragma mark - local files

-(UIView*) HeaderViewForSection:(NSInteger) sectionIndex
{
    if (sectionIndex >= [self.headerViewArray count]) {
        return nil;
    }
    
    id obj = [self.headerViewArray objectAtIndex:sectionIndex];
    if ([obj isKindOfClass:[UIView class]]) {
        return obj;
    }
    
    return nil;
}

-(BOOL) IsSectionItemSelected:(NSInteger) section
{
    return FALSE;
}

-(void) selectSection:(int) sectionIndex
{
    NSMutableArray* rowsSelected = [self.selectionData objectForKey:[@(sectionIndex) stringValue]];
    
    if ([rowsSelected count] == 0) {
        
        NSMutableArray* selectionRows = [NSMutableArray new];
        [self.selectionData setObject:selectionRows forKey:[@(sectionIndex) stringValue]];
        
        NSInteger rows = [self.tableView numberOfRowsInSection:sectionIndex];
        
        if (rows == 0)
        {
            // the section is not expanded yet
            ExpandableTableDataNode* node = [self.expandableTableData objectAtIndex:sectionIndex];
            rows = [node.items count];
            
            for (int iter = 0; iter < rows; iter++) {
                [selectionRows addObject:@(iter)];
            }
        }
        else {
            for (int iter = 0; iter < rows; iter++)
            {
                [selectionRows addObject:@(iter)];
            }
        }
    }
    else {
        [rowsSelected removeAllObjects];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                  withRowAnimation:UITableViewRowAnimationNone];
}

-(void) collapseSection:(NSInteger) sectionNumber showSameSection:(BOOL) showSameHeader
{
    UIView* headerView = [self HeaderViewForSection:sectionNumber];
    UIButton* expandButton = (UIButton*)[headerView viewWithTag:HEADER_SELECTALLBUTTON_TAG];
    [expandButton setImage:[UIImage imageNamed:@"plusIcon.png"] forState:UIControlStateNormal];
    
    self.sectionExpanded = -1;
    
    ExpandableTableDataNode* node = [self.expandableTableData objectAtIndex:sectionNumber];
    NSInteger numRows = [node.items count];
    
    NSMutableArray* rowIndexArray = [[NSMutableArray alloc] initWithCapacity:numRows];
    
    for (int iter = 0; iter < numRows; iter++) {
        [rowIndexArray addObject:[NSIndexPath indexPathForRow:iter inSection:sectionNumber]];
    }
    
    [self.tableView deleteRowsAtIndexPaths:rowIndexArray  withRowAnimation:UITableViewRowAnimationFade];
    
    if (showSameHeader) {
        [self performSelector:@selector(scrollToHeader:) withObject:@(sectionNumber) afterDelay:0.1];
    }
}

-(void) expandSection:(id) sectionNumber
{
    NSInteger secIndex = [(NSNumber*)sectionNumber integerValue];
    
    if(secIndex >= [self.expandableTableData count])
    {
        return;
    }
    
    ExpandableTableDataNode* node = [self.expandableTableData objectAtIndex:secIndex];
    NSInteger numRows = [node.items count];
    
    NSMutableArray* rowIndexArray = [[NSMutableArray alloc] initWithCapacity:numRows];
    
    for (int iter = 0; iter < numRows; iter++) {
        [rowIndexArray addObject:[NSIndexPath indexPathForRow:iter inSection:secIndex]];
    }
    
    if (![rowIndexArray count]) {
        return;
    }
    
    self.sectionExpanded = secIndex;
    [self.tableView insertRowsAtIndexPaths:rowIndexArray withRowAnimation:UITableViewRowAnimationTop];
    [self performSelector:@selector(scrollToHeader:) withObject:sectionNumber afterDelay:0.1];
    
    UIView* headerView = [self HeaderViewForSection:secIndex];
    UIButton* expandable = (UIButton*)[headerView viewWithTag:HEADER_SELECTALLBUTTON_TAG];
    [expandable setImage:[UIImage imageNamed:@"minusIcon.png"] forState:UIControlStateNormal];
}

-(void) scrollToHeader:(NSNumber*) sectionNumber
{
    CGRect rect = CGRectMake(0, 0, 320, 50);
    rect.origin.y = 50 * [sectionNumber integerValue];
    
    NSInteger numRows = [self tableView:self.tableView numberOfRowsInSection:[sectionNumber integerValue]];
    
    if (numRows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:[sectionNumber integerValue]]
                              atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
    else {
        [self.tableView scrollRectToVisible:rect animated:YES];
    }
}

-(NSArray*) SelectedItems
{
    return self.selectedIndexPaths;
}

-(void) ConfigureForData:(NSArray*) expandableData
{
    self.expandableTableData = expandableData;
    
    self.headerViewArray = [NSMutableArray new];
    NSInteger numSections = [self.expandableTableData count];
    
    for (int iter = 0; iter < numSections; iter++)
    {
        [self.headerViewArray addObject:[NSNull null]];
    }
}

#pragma mark - table callbacks

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.expandableTableData count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNum = 0;
    
    if (self.sectionExpanded == section)
    {
        ExpandableTableDataNode* node = [self.expandableTableData objectAtIndex:section];
        rowNum = [node.items count];
    }
    
    return rowNum;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60.0;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerViewFromArray = nil;
    
    headerViewFromArray = [self HeaderViewForSection:section];
    UILabel* label = nil;
    UIButton* expandImage = nil;
    
    if (headerViewFromArray)
    {
        label = (UILabel*)[headerViewFromArray viewWithTag:HEADER_LABEL_TAG];
        expandImage = (UIButton*)[headerViewFromArray viewWithTag:HEADER_SELECTALLBUTTON_TAG];
    }
    else
    {
        UIButton* view = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [view addTarget:self action:@selector(sectionTapHandler:) forControlEvents:UIControlEventTouchUpInside];
        [view setTag:(SECTION_TAG_START + section)];
        int height = [self tableView:tableView heightForHeaderInSection:section];
        [view setFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        CAGradientLayer* layer = [[CAGradientLayer alloc] init];
        layer.frame = view.bounds;
        [layer setColors:@[(id)[[UIColor colorWithWhite:0.97 alpha:1.0] CGColor],(id)[[UIColor colorWithWhite:0.95 alpha:1.0] CGColor]]];
        [view.layer insertSublayer:layer atIndex:0];
        
        expandImage = [UIButton buttonWithType:UIButtonTypeCustom];
        expandImage.tag = HEADER_SELECTALLBUTTON_TAG;
        [view addSubview:expandImage];
        
        CGRect selectAllRect = CGRectMake(0, 0, 24, 24);
        selectAllRect.origin.x = 10;
        selectAllRect.origin.y = (view.frame.size.height - selectAllRect.size.height)/2;
        [expandImage setFrame:selectAllRect];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(selectAllRect.origin.x + selectAllRect.size.width + 10, // x
                                                          5, // y
                                                          (view.frame.size.width - (selectAllRect.origin.x + selectAllRect.size.width + 20)), // width
                                                          50)];
        label.tag = HEADER_LABEL_TAG;
        label.numberOfLines = 0;
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont boldSystemFontOfSize:17.0]];
        
        [view addSubview:label];
        
        CALayer* line = [[CALayer alloc] init];
        [line setFrame:CGRectMake(0, view.frame.size.height - 2, view.frame.size.width, 1)];
        [line setBackgroundColor:[[UIColor lightGrayColor] CGColor]];
        [view.layer insertSublayer:line atIndex:0];
        
        if ([self.headerViewArray count] && section < [self.headerViewArray count]) {
            [self.headerViewArray replaceObjectAtIndex:section withObject:view];
        }
        
        headerViewFromArray = view;
    }
    
    if (section == self.sectionExpanded) {
        [expandImage setImage:[UIImage imageNamed:@"minusIcon.png"] forState:UIControlStateNormal];
    }
    else {
        [expandImage setImage:[UIImage imageNamed:@"plusIcon.png"] forState:UIControlStateNormal];
    }
    
    ExpandableTableDataNode* node = [self.expandableTableData objectAtIndex:section];
    label.text = node.mainHeader;
    
    return headerViewFromArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExpandableTableDataNode* node = [self.expandableTableData objectAtIndex:[indexPath section]];
    NSString* title = [node.items objectAtIndex:[indexPath row]];
    static NSString* cellId = @"cellId";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    [cell.textLabel setText:title];
    
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    }
    else {
        [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        [self.selectedIndexPaths removeObject:indexPath];
    }
    else {
        [self.selectedIndexPaths addObject:indexPath];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - button handler

-(void) sectionTapHandler:(id) sender
{
    UIButton* sectionButton = (UIButton*) sender;
    NSInteger sectionIndex = sectionButton.tag - SECTION_TAG_START;
    
    NSInteger sectionToCollapse = self.sectionExpanded;
    
    if (self.sectionExpanded == sectionIndex) {
        [self collapseSection:sectionToCollapse showSameSection:TRUE];
    }
    else {
        if (self.sectionExpanded >= 0) {
            [self collapseSection:sectionToCollapse showSameSection:FALSE];
        }
        
        // can't perform below immediately, as it crashes in the table updates due to the sectionExpanded param.
        [self performSelector:@selector(expandSection:)
                   withObject:[NSNumber numberWithInteger:sectionIndex]
                   afterDelay:0.1];
    }
}

-(void) backHandler
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void) doneHandler
{
    [self.delegate ExpandableTableViewController:self
                       DidSelectItemsAtIndexPath:self.selectedIndexPaths
                                    WithUserInfo:self.userInfo];
}

@end
