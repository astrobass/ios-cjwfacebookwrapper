//
//  CJWFacebook.m
//
//  Created by Corey Wendling on 6/13/13.
//  Copyright (c) 2013
//  See the file LICENSE for copying permission.
//

#import "CJWFacebookWrapper.h"

@interface CJWFacebookWrapper()

@property (strong, nonatomic) FBSession *session;
@property (nonatomic) NSString *userID;
@end

@implementation CJWFacebookWrapper

#pragma mark - AppDelgate

- (BOOL)openURL:(NSString *)sourceApplication url:(NSURL *)url {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        if (call.accessTokenData) {
            if ([FBSession activeSession].isOpen) {
                // Ignoring app link because current session is open.
            }
            else {
                [self handleAppLink:call.accessTokenData];
            }
        }
    }];
}

- (void)applicationDidBecomeActive {
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}

- (void)applicationWillTerminate {
    [self.session close];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.loginDelegate facebookUpdate];
    if (self.session.isOpen) {
        // Session is open
    } else {
        // Session is NOT open
    }
    if (!self.session.isOpen) {
        self.session = [[FBSession alloc] init];
        if (self.session.state == FBSessionStateCreatedTokenLoaded) {
            // Already logged in
            [self.session openWithCompletionHandler:^(FBSession *session, FBSessionState status,
                                                            NSError *error) {
                // Call callback facebookUpdate
                [self.loginDelegate facebookUpdate];
            }];
        } else {
            // Not logged in
        }
    }
}

#pragma mark - Requests

- (void)loginFacebook {
    if (self.session.isOpen) {
        // Session is open
        [self.loginDelegate facebookUpdate];
    } else {
        // Session is NOT open
        if (!self.session || (self.session.state != FBSessionStateCreated)) {
            // Session state is NOT created
            self.session = [[FBSession alloc] init];
        }
        // Open Facebook login page
        [self.session openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            // Call callback facebookUpdate
            [self.loginDelegate facebookUpdate];
        }];
    }
}

- (void)requestNewReadPermission {
    NSArray *readPermissions = [NSArray arrayWithObjects:@"read_friendlists", nil];
    [FBSession.activeSession requestNewReadPermissions:readPermissions completionHandler:^(FBSession *session, NSError *error) {
        if (error) {
            // requestReadPermission error");
        }
        // Call callback facebookUpdate
        [self.loginDelegate facebookUpdate];
    }];
}

- (void)requestNewPublishPermission {
    NSArray *publishPermissions = [NSArray arrayWithObjects:@"publish_actions", nil];
    [FBSession.activeSession requestNewPublishPermissions:publishPermissions defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
        if (error) {
            if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                // requestPublishPermission error");
            }
        }
        [self.loginDelegate facebookUpdate];
    }];
}

#pragma mark - Fetches

- (void)fetchUserData {
    if (!self.session) {
        // No session so need to log in
        [self loginFacebook];
        return;
    }
    [FBSession setActiveSession:self.session];
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
        if (error) {
            // fetchUserData error
            return;
        }

        self.userID = user.id;
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:user.id forKey:@"id"];
        [dictionary setObject:user.id forKey:@"username"];
        [dictionary setObject:user.name forKey:@"name"];
        [self.fetchUserDataDelegate receiveFacebookUser:dictionary];
     }];
}

- (void)fetchFriends {
    if (!self.session) {
        // No session so need to log in
        [self loginFacebook];
        return;
    }
    [FBSession setActiveSession:self.session];
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/friends", self.userID] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            // fetchFriends error
            return;
        }
        NSArray *friends = (NSArray *)[(NSDictionary *)result objectForKey:@"data"];
        [self.fetchFriendsDelegate receiveFacebookFriends:friends];
    }];
}

- (BOOL)isOpen {
    return self.session.isOpen;
}

- (void)handleAppLink:(FBAccessTokenData *)appLinkToken {
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil permissions:nil
            defaultAudience:FBSessionDefaultAudienceNone urlSchemeSuffix:nil
            tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];
    [FBSession setActiveSession:appLinkSession];
    [appLinkSession openFromAccessTokenData:appLinkToken
        completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        if (error) {
            // handleAppLink error
        }
    }];
}

@end
