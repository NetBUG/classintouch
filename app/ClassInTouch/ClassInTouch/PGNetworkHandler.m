//
//  PGNetworkHandler.m
//  PlotGuru
//
//  Created by Justin Jia on 7/23/15.
//  Copyright (c) 2015 Plot Guru. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "PGNetworkHandler.h"
#import "NSObject+PGPropertyList.h"

@interface PGNetworkHandler ()

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic, readonly, nonnull) AFHTTPSessionManager *sessionManager;

@end

@implementation PGNetworkHandler

#pragma mark - Dealloc Methods

#pragma mark - Init Methods

- (instancetype)init
{
    return [self initWithBaseURL:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        self.baseURL = baseURL;
    }
    return self;
}

#pragma mark - POST

- (NSMutableDictionary *)dataFromObject:(id)object mapping:(PGNetworkMapping *)mapping
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];

    NSDictionary *properties = [NSObject propertiesOfObject:object];
    for (NSString *propertyName in properties.allKeys) {
        id anObject = [object valueForKey:propertyName];
        NSString *key = [mapping keyForMapping:propertyName];
        if (anObject && key) {
            data[key] = anObject;
        } else if (key) {
            [data removeObjectForKey:key];
        }
    }

    return data;
}

- (void)POST:(NSString *)URLString from:(id)object mapping:(PGNetworkMapping *)mapping success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure finish:(void (^)())finish
{
    [self POST:URLString from:[self dataFromObject:object mapping:mapping] success:success failure:failure finish:finish];
}

- (void)POST:(NSString *)URLString from:(NSDictionary *)data success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure finish:(void (^)())finish
{
    [self.sessionManager POST:URLString parameters:data success:^(NSURLSessionDataTask *task, id responseObject) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (success) {
                success(responseObject);
            }

            if (finish) {
                finish();
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (failure) {
                failure(error);
            }

            if (finish) {
                finish();
            }
        }];
    }];
}

#pragma mark - PUT

- (void)PUT:(NSString *)URLString from:(id)object mapping:(PGNetworkMapping *)mapping success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure finish:(void (^)())finish
{
    [self PUT:URLString from:[self dataFromObject:object mapping:mapping] success:success failure:failure finish:finish];
}

- (void)PUT:(NSString *)URLString from:(NSDictionary *)data success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure finish:(void (^)())finish
{
    [self.sessionManager PUT:URLString parameters:data success:^(NSURLSessionDataTask *task, id responseObject) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (success) {
                success(responseObject);
            }

            if (finish) {
                finish();
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (failure) {
                failure(error);
            }

            if (finish) {
                finish();
            }
        }];
    }];
}

#pragma mark - GET

- (void)GET:(NSString *)URLString parameters:(NSDictionary *)parameters to:(NSManagedObjectContext *)context mapping:(PGNetworkMapping *)mapping success:(void (^)(NSArray *results))success failure:(void (^)(NSError *error))failure finish:(void (^)())finish
{
    [self.sessionManager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (self.isCanceled) {
            return;
        }

        NSArray *responseArray = [responseObject isKindOfClass:[NSArray class]] ? responseObject : (responseObject ? @[responseObject] : nil);

        NSMutableArray *results = [NSMutableArray array];

        NSError *error = nil;
        for (id responseArrayItem in responseArray) {
            if ([responseArrayItem isKindOfClass:[NSDictionary class]]) {
                [results addObject:[context save:mapping.entityName with:responseArrayItem mapping:mapping error:&error]];
            }
        }

        [context save:&error];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (!error) {
                if (success) {
                    success(results.copy);
                }
            } else {
                if (failure) {
                    failure(error);
                }
            }

            if (finish) {
                finish();
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (self.isCanceled) {
            return;
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (failure) {
                failure(error);
            }

            if (finish) {
                finish();
            }
        }];
    }];
}

- (void)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(void (^)(id results))success failure:(void (^)(NSError *error))failure finish:(void (^)())finish
{
    [self.sessionManager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (self.isCanceled) {
            return;
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (success) {
                success(responseObject);
            }

            if (finish) {
                finish();
            }
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (self.isCanceled) {
            return;
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (failure) {
                failure(error);
            }

            if (finish) {
                finish();
            }
        }];
    }];
}

#pragma mark - Authorization Header Methods

- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password
{
    [self.sessionManager.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
}

- (void)clearAuthorizationHeader
{
    [self.sessionManager.requestSerializer clearAuthorizationHeader];
}

#pragma mark - Setter & Getter Methods

@synthesize sessionManager = _sessionManager;

- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }

    return _sessionManager;
}

@end
