
#import "MEGACreateFolderRequestDelegate.h"

#import "SVProgressHUD.h"

@interface MEGACreateFolderRequestDelegate ()

@property (nonatomic, copy) void (^completion)(void);

@end

@implementation MEGACreateFolderRequestDelegate

#pragma mark - Initialization

- (instancetype)initWithCompletion:(void (^)(void))completion {
    self = [super init];
    if (self) {
        _completion = completion;
    }
    
    return self;
}

#pragma mark - MEGARequestDelegate

- (void)onRequestStart:(MEGASdk *)api request:(MEGARequest *)request {
    [super onRequestStart:api request:request];
}

- (void)onRequestFinish:(MEGASdk *)api request:(MEGARequest *)request error:(MEGAError *)error {
    [super onRequestFinish:api request:request error:error];
    
    if (error.type) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ %@", request.requestString, error.name]];
        return;
    }
    
    if (self.completion) {
        self.completion();
    }
}

@end
