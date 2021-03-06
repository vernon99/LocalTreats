//
//  GMCMainViewController.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import <UIKit/UIKit.h>
#import "GMCVenueCard.h"

@interface GMCMainViewController : UIViewController
{
    BOOL                                _locationUpdated;
    IBOutlet UIActivityIndicatorView*   _activityIndicator;
    IBOutlet UILabel*                   _statusLabel;
    IBOutlet UILabel*                   _adviceLabel;
    NSUInteger                          _currentCardNumber;
    
    NSMutableDictionary*                _venueArrays;
    NSArray*                            _selectedTypeArray;
    
    GMCVenueCard*                       _currentCard;
    
    IBOutlet UIView *_buttonsView;
    IBOutlet UIButton *_buttonCoffee;
    IBOutlet UIButton *_buttonLunch;
    IBOutlet UIButton *_buttonDrinks;
    IBOutlet UIButton *_buttonTreats;
    
    GMCQueryType    _currentQuery;
    GMCQueryType    _nowLoading;
    GMCQueryType    _nextLoading;
}

- (IBAction)buttonTap:(id)sender;

- (BOOL) showingCard;
- (void) reloadData;


@end
