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
    
    GMC_QUERIES_COUNT   = 3
} GMCQueryType;
