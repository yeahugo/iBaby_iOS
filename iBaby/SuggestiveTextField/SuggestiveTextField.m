//
//  SuggestionMenu.m
//  AutoComplete
//
//  Created by Wojciech Mandrysz on 19/09/2011.
//  Copyright 2011 http://tetek.me . All rights reserved.
//

#import "SuggestiveTextField.h"

//#define DEFAULT_POPOVER_SIZE CGSizeMake(300, 300)
#define DEFAULT_POPOVER_SIZE CGSizeMake(500, 300)

@interface SuggestiveTextField ()
{
    float _cellHeight;
}

@property (strong) NSArray *stringsArray;
@property (strong) NSArray *matchedStrings;

@property (strong) UITableViewController *controller;

@end

@implementation SuggestiveTextField

#pragma mark - Setup

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame{
    
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}
- (id)init{
    
    if ((self = [super init])) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.matchedStrings = [NSArray array];
    self.controller = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.controller.view.backgroundColor = [UIColor clearColor];
    
    _controller.tableView.delegate = self;
    _controller.tableView.dataSource = self;
    _controller.view.backgroundColor = [UIColor colorWithRed:((float)0x12/0xFF) green:((float)0xB5/0xFF) blue:((float)0xF8/0xFF) alpha:1];

    self.popOver = [[UIPopoverController alloc] initWithContentViewController:_controller];
    
    // Default values
//    _popOver.popoverContentSize = DEFAULT_POPOVER_SIZE;
    _popOver.popoverContentSize = CGSizeMake(self.frame.size.width, 300);
    if ([_popOver respondsToSelector:@selector(setBackgroundColor:)]) {
        _popOver.backgroundColor = [UIColor colorWithRed:((float)0x12/0xFF) green:((float)0xB5/0xFF) blue:((float)0xF8/0xFF) alpha:1];
    }
    self.shouldHideOnSelection = NO;
    _cellHeight = 70;
}

#pragma mark - Modifiers

- (void)setSuggestions:(NSArray *)suggestionStrings{
    self.stringsArray = suggestionStrings;
}
- (void)setPopoverSize:(CGSize)size{
    self.popOver.popoverContentSize = size;
}

#pragma mark - Matching strings and Popover

- (void)matchStrings:(NSString *)letters {
    if (_stringsArray.count > 0) {
        NSLog(@"string is %@",letters);
        self.matchedStrings = [_stringsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[cd] %@",letters]];
        [_controller.tableView reloadData];
    }
}

- (void)showPopOverList{

    if (_matchedStrings.count == 0) {
        [_popOver dismissPopoverAnimated:YES];
    }
    else if (!_popOver.isPopoverVisible){
        [_popOver presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}


#pragma mark - TextField Delegate

#pragma mark - TableView Delegate & DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _matchedStrings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.backgroundColor = [UIColor colorWithRed:((float)0x12/0xFF) green:((float)0xB5/0xFF) blue:((float)0xF8/0xFF) alpha:1];
    cell.textLabel.text = [_matchedStrings objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"searchIcon"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setText:[_matchedStrings objectAtIndex:indexPath.row]];
    NSString *searchWords = [_matchedStrings objectAtIndex:indexPath.row];
    [self.searchViewController performSelector:@selector(onClickSearchWords:) withObject:searchWords];
    [_popOver dismissPopoverAnimated:_shouldHideOnSelection];
}


@end
