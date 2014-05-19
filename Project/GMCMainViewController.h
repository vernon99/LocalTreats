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
    NSArray*                            _venueArray;
    GMCVenueCard*                       _currentCard;
}

@end
