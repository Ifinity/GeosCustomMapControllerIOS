//
//  IFDataProvider.h
//  ifinitySDK
//
//  Created by GetIfinity on 09.10.2014.
//  Copyright (c) 2014 GetIfinity. All rights reserved.
//



/**
 *  Base class for all DataProviders
 */
@class IFDataManager;
@class IFDataProvider;

/**
 *  Base delegate for all Provider Delegates.
 */
@protocol IFDataProviderDelegate <NSObject>
@optional

/**
 *  Invoked only when we reach some API error
 *
 *  @param provider Data provider
 *  @param areas   New Areas
 */
- (void) dataProvider:(IFDataProvider *)provider queryError:(NSError *)error;
@end


/**
 *  Base class for all data providers.
 *  
 *  Data provider uses `IFDataManager` to fetch from API a specific data models.
 */
@interface IFDataProvider : NSObject

@property (nonatomic, strong, readonly) IFDataManager *dataManager;

/**
 *  All data providers share the same constructor.
 *
 *  @param dataManager An instance of shared manager
 *
 *  @return new instance
 */
- (instancetype)initWithDataManager:(IFDataManager *)dataManager;
@end
