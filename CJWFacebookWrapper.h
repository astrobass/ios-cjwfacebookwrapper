//
//  CJWFacebook.h
//
//  Created by Corey Wendling on 6/13/13.
//  Copyright (c) 2013
//  See the file LICENSE for copying permission.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@class CJWFacebookWrapper;
@protocol CJWFacebookLoginDelegate <NSObject>

- (void)facebookUpdate;

@end

@protocol CJWFacebookFetchUserDataDelegate <NSObject>

- (void)receiveFacebookUser:(NSMutableDictionary *)dictionary;

@end

@protocol CJWFacebookFetchFriendsDelegate <NSObject>

- (void)receiveFacebookFriends:(NSArray *)array;

@end
@interface CJWFacebookWrapper : NSObject

@property (nonatomic) id<CJWFacebookLoginDelegate> loginDelegate;
@property (nonatomic) id<CJWFacebookFetchUserDataDelegate> fetchUserDataDelegate;
@property (nonatomic) id<CJWFacebookFetchFriendsDelegate> fetchFriendsDelegate;

- (BOOL)openURL:(NSString *)sourceApplication url:(NSURL *)url;
- (void)viewDidLoad;
- (void)applicationDidBecomeActive;
- (void)applicationWillTerminate;
- (void)loginFacebook;
- (void)requestNewReadPermission;
- (void)requestNewPublishPermission;
- (void)fetchUserData;
- (void)fetchFriends;
- (BOOL)isOpen;

@end
