//
//  GMCParams.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 3/01/14.
//
//

// Unused for now
static NSUInteger const GMCVenueMaxDistanceKm = 50;
static NSUInteger const GMCVenueMaxCount = 10;

typedef enum QueryType
{
    GMC_QUERY_NONE      = -1,
    GMC_QUERY_COFFEE    = 0,
    GMC_QUERY_LUNCH     = 1,
    GMC_QUERY_DRINKS    = 2,
    GMC_QUERY_TREATS    = 3,
    
    GMC_QUERIES_COUNT   = 4,
    
} GMCQueryType;

static NSString* GMCTreatsOnlyCategories[] = {/*@"Bubble Tea Shop", */@"Cupcake Shop", @"Dessert Shop", @"Donut Shop", @"Ice Cream Shop", /*@"Juice Bar", */@"Frozen Yogurt", @"Bakery", @"Creperie", @"Pie Shop"};
static const NSInteger GMCTreatsOnlyCategoriesCount = sizeof(GMCTreatsOnlyCategories)/sizeof(NSString*);

//static NSString* GMCTreatsAndFoodCategories[] = {@"Bakery", @"Creperie", @"Fondue Restaurant", @"Pie Shop", @"Blini House", @"Varenyky restaurant"};