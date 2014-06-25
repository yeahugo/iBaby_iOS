//
//  SuggestionMenu.h
//  AutoComplete
//
//  Created by Wojciech Mandrysz on 19/09/2011.
//  Copyright 2011 http://tetek.me . All rights reserved.
//

#import <UIKit/UIKit.h>

@class AiSearchViewController;

@interface SuggestiveTextField : UITextField <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id  searchViewController;

@property (strong) UIPopoverController *popOver;

// Set suggestions list of NSString's.
- (void)setSuggestions:(NSArray*)suggestionStrings;

// Set Custom popover size.
- (void)setPopoverSize:(CGSize)size;

- (void)matchStrings:(NSString *)letters;

- (void)showPopOverList;
// Define if popover should hide after user selects a suggestion.
@property BOOL shouldHideOnSelection;

@end
