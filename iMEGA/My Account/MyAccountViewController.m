#import "MyAccountViewController.h"

#import "UIImage+GKContact.h"

#import "Helper.h"
#import "MEGASdk+MNZCategory.h"
#import "MEGAReachabilityManager.h"
#import "MEGASdkManager.h"
#import "NSString+MNZCategory.h"

#import "UsageViewController.h"
#import "SettingsTableViewController.h"

@interface MyAccountViewController () <MEGARequestDelegate> {
    BOOL isAccountDetailsAvailable;
    
    NSNumber *localSize;
    NSNumber *cloudDriveSize;
    NSNumber *rubbishBinSize;
    NSNumber *incomingSharesSize;
    NSNumber *usedStorage;
    NSNumber *maxStorage;
    
    NSByteCountFormatter *byteCountFormatter;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButtonItem;

@property (weak, nonatomic) IBOutlet UIButton *usageButton;
@property (weak, nonatomic) IBOutlet UILabel *usageLabel;

@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UILabel *localLabel;
@property (weak, nonatomic) IBOutlet UILabel *localUsedSpaceLabel;

@property (weak, nonatomic) IBOutlet UILabel *usedLabel;
@property (weak, nonatomic) IBOutlet UILabel *usedSpaceLabel;

@property (weak, nonatomic) IBOutlet UILabel *availableLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableSpaceLabel;

@property (weak, nonatomic) IBOutlet UILabel *accountTypeLabel;

@property (weak, nonatomic) IBOutlet UIView *freeView;
@property (weak, nonatomic) IBOutlet UILabel *freeStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *upgradeToProButton;

@property (weak, nonatomic) IBOutlet UIView *proView;
@property (weak, nonatomic) IBOutlet UILabel *proStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *proExpiryDateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *logoutButtonTopImageView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoutButtonBottomImageView;

@property (nonatomic) MEGAAccountType megaAccountType;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usedLabelTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *accountTypeLabelTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upgradeAccountTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *proViewTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoutButtonTopLayoutConstraint;

@end

@implementation MyAccountViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = AMLocalizedString(@"profile", @"Label for any 'Profile' button, link, text, title, etc. - (String as short as possible).");
    
    self.editBarButtonItem.title = AMLocalizedString(@"edit", @"Caption of a button to edit the files that are selected");
    
    [self.usageLabel setText:AMLocalizedString(@"usage", nil)];
    [self.settingsLabel setText:AMLocalizedString(@"settingsTitle", nil)];
    
    [self.localLabel setText:AMLocalizedString(@"localLabel", @"Local")];
    [self.usedLabel setText:AMLocalizedString(@"usedSpaceLabel", @"Used")];
    [self.availableLabel setText:AMLocalizedString(@"availableLabel", @"Available")];
    
    NSString *accountTypeString = [AMLocalizedString(@"accountType", @"title of the My Account screen") stringByReplacingOccurrencesOfString:@":" withString:@""];
    self.accountTypeLabel.text = accountTypeString;
    
    [self.freeStatusLabel setText:AMLocalizedString(@"free", nil)];
    [self.upgradeToProButton setTitle:AMLocalizedString(@"upgradeAccount", nil) forState:UIControlStateNormal];
    
    [self.logoutButton setTitle:AMLocalizedString(@"logoutLabel", @"Title of the button which logs out from your account.") forState:UIControlStateNormal];
    
    byteCountFormatter = [[NSByteCountFormatter alloc] init];
    [byteCountFormatter setCountStyle:NSByteCountFormatterCountStyleMemory];
    
    if ([[UIDevice currentDevice] iPhone4X]) {
        self.usedLabelTopLayoutConstraint.constant = 8.0f;
        self.accountTypeLabelTopLayoutConstraint.constant = 9.0f;
        self.freeViewTopLayoutConstraint.constant = 8.0f;
        self.upgradeAccountTopLayoutConstraint.constant = 8.0f;
        self.proViewTopLayoutConstraint.constant = 8.0f;
        self.logoutButtonTopLayoutConstraint.constant = 0.0f;
        self.logoutButtonTopImageView.backgroundColor = nil;
        self.logoutButtonBottomImageView.backgroundColor = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    long long thumbsSize = [Helper sizeOfFolderAtPath:[Helper pathForSharedSandboxCacheDirectory:@"thumbnailsV3"]];
    long long previewsSize = [Helper sizeOfFolderAtPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"previewsV3"]];
    long long offlineSize = [Helper sizeOfFolderAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    localSize = [NSNumber numberWithLongLong:(thumbsSize + previewsSize + offlineSize)];
    
    NSString *stringFromByteCount = [byteCountFormatter stringFromByteCount:[localSize longLongValue]];
    self.localUsedSpaceLabel.attributedText = [self textForSizeLabels:stringFromByteCount];
    
    [self setupWithAccountDetails];
    [[MEGASdkManager sharedMEGASdk] getAccountDetails];
    
    self.emailLabel.text = [[MEGASdkManager sharedMEGASdk] myEmail];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Private

- (NSMutableAttributedString *)textForSizeLabels:(NSString *)stringFromByteCount {
    
    NSMutableAttributedString *firstPartMutableAttributedString;
    NSMutableAttributedString *secondPartMutableAttributedString;
    
    NSArray *componentsSeparatedByStringArray = [stringFromByteCount componentsSeparatedByString:@" "];
    NSString *firstPartString = [NSString mnz_stringWithoutUnitOfComponents:componentsSeparatedByStringArray];
    NSRange firstPartRange;
    
    NSArray *stringComponentsArray = [firstPartString componentsSeparatedByString:@","];
    NSString *secondPartString;
    if ([stringComponentsArray count] > 1) {
        NSString *integerPartString = [stringComponentsArray objectAtIndex:0];
        NSString *fractionalPartString = [stringComponentsArray objectAtIndex:1];
        firstPartMutableAttributedString = [[NSMutableAttributedString alloc] initWithString:integerPartString];
        firstPartRange = [integerPartString rangeOfString:integerPartString];
        secondPartString = [NSString stringWithFormat:@".%@ %@", fractionalPartString, [NSString mnz_stringWithoutCountOfComponents:componentsSeparatedByStringArray]];
    } else {
        firstPartMutableAttributedString = [[NSMutableAttributedString alloc] initWithString:firstPartString];
        firstPartRange = [firstPartString rangeOfString:firstPartString];
        secondPartString = [NSString stringWithFormat:@" %@", [NSString mnz_stringWithoutCountOfComponents:componentsSeparatedByStringArray]];
    }
    NSRange secondPartRange = [secondPartString rangeOfString:secondPartString];
    secondPartMutableAttributedString = [[NSMutableAttributedString alloc] initWithString:secondPartString];
    
    [firstPartMutableAttributedString addAttribute:NSFontAttributeName
                                             value:[UIFont mnz_SFUIRegularWithSize:20.0f]
                                             range:firstPartRange];
    
    [secondPartMutableAttributedString addAttribute:NSFontAttributeName
                                              value:[UIFont mnz_SFUIRegularWithSize:12.0f]
                                              range:secondPartRange];
    
    [firstPartMutableAttributedString appendAttributedString:secondPartMutableAttributedString];
    
    return firstPartMutableAttributedString;
}

- (void)setupWithAccountDetails {
    if ([[MEGASdkManager sharedMEGASdk] mnz_accountDetails]) {
        MEGAAccountDetails *accountDetails = [[MEGASdkManager sharedMEGASdk] mnz_accountDetails];
        
        self.megaAccountType = accountDetails.type;
        cloudDriveSize = [accountDetails storageUsedForHandle:[[[MEGASdkManager sharedMEGASdk] rootNode] handle]];
        rubbishBinSize = [accountDetails storageUsedForHandle:[[[MEGASdkManager sharedMEGASdk] rubbishNode] handle]];
        
        MEGANodeList *incomingShares = [[MEGASdkManager sharedMEGASdk] inShares];
        NSUInteger count = incomingShares.size.unsignedIntegerValue;
        long long incomingSharesSizeLongLong = 0;
        for (NSUInteger i = 0; i < count; i++) {
            MEGANode *node = [incomingShares nodeAtIndex:i];
            incomingSharesSizeLongLong += [[[MEGASdkManager sharedMEGASdk] sizeForNode:node] longLongValue];
        }
        incomingSharesSize = [NSNumber numberWithLongLong:incomingSharesSizeLongLong];
        
        usedStorage = accountDetails.storageUsed;
        maxStorage = accountDetails.storageMax;
        
        NSString *usedStorageString = [byteCountFormatter stringFromByteCount:[usedStorage longLongValue]];
        long long availableStorage = maxStorage.longLongValue - usedStorage.longLongValue;
        NSString *availableStorageString = [byteCountFormatter stringFromByteCount:(availableStorage < 0) ? 0 : availableStorage];
        
        self.usedSpaceLabel.attributedText = [self textForSizeLabels:usedStorageString];
        self.availableSpaceLabel.attributedText = [self textForSizeLabels:availableStorageString];
        
        NSString *expiresString;
        if (accountDetails.type) {
            self.freeView.hidden = YES;
            self.proView.hidden = NO;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
            NSString *currentLanguageID = [[LocalizationSystem sharedLocalSystem] getLanguage];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:currentLanguageID];
            
            NSDate *expireDate = [[NSDate alloc] initWithTimeIntervalSince1970:accountDetails.proExpiration];
            expiresString = [NSString stringWithFormat:AMLocalizedString(@"expiresOn", @"Text that shows the expiry date of the account PRO level"), [dateFormatter stringFromDate:expireDate]];
        } else {
            self.proView.hidden = YES;
            self.freeView.hidden = NO;
        }
        
        switch (accountDetails.type) {
            case MEGAAccountTypeFree: {
                break;
            }
                
            case MEGAAccountTypeLite: {
                self.proStatusLabel.text = [NSString stringWithFormat:@"PRO LITE"];
                self.proExpiryDateLabel.text = [NSString stringWithFormat:@"%@", expiresString];
                break;
            }
                
            case MEGAAccountTypeProI: {
                self.proStatusLabel.text = [NSString stringWithFormat:@"PRO I"];
                self.proExpiryDateLabel.text = [NSString stringWithFormat:@"%@", expiresString];
                break;
            }
                
            case MEGAAccountTypeProII: {
                self.proStatusLabel.text = [NSString stringWithFormat:@"PRO II"];
                self.proExpiryDateLabel.text = [NSString stringWithFormat:@"%@", expiresString];
                break;
            }
                
            case MEGAAccountTypeProIII: {
                self.proStatusLabel.text = [NSString stringWithFormat:@"PRO III"];
                self.proExpiryDateLabel.text = [NSString stringWithFormat:@"%@", expiresString];
                break;
            }
                
            default:
                break;
        }
    } else {
        MEGALogError(@"Account details unavailable");
    }
}

#pragma mark - IBActions

- (IBAction)editTouchUpInside:(UIBarButtonItem *)sender {
    [super presentEditProfileAlertController];
}

- (IBAction)logoutTouchUpInside:(UIButton *)sender {
    if ([MEGAReachabilityManager isReachableHUDIfNot]) {
        NSError *error;
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] error:&error];
        if (error) {
            MEGALogError(@"Contents of directory at path failed with error: %@", error);
        }
        
        BOOL isInboxDirectory = NO;
        for (NSString *directoryElement in directoryContent) {
            if ([directoryElement isEqualToString:@"Inbox"]) {
                NSString *inboxPath = [[Helper pathForOffline] stringByAppendingPathComponent:@"Inbox"];
                [[NSFileManager defaultManager] fileExistsAtPath:inboxPath isDirectory:&isInboxDirectory];
                break;
            }
        }
        
        if (directoryContent.count > 0) {
            if (directoryContent.count == 1 && isInboxDirectory) {
                [[MEGASdkManager sharedMEGASdk] logout];
                return;
            }
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AMLocalizedString(@"warning", nil) message:AMLocalizedString(@"allFilesSavedForOfflineWillBeDeletedFromYourDevice", @"Alert message shown when the user perform logout and has files in the Offline directory") preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:AMLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:AMLocalizedString(@"logoutLabel", @"Title of the button which logs out from your account.") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[MEGASdkManager sharedMEGASdk] logout];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            [[MEGASdkManager sharedMEGASdk] logout];
        }
    }
}

- (IBAction)usageTouchUpInside:(UIButton *)sender {
    
    if ([[MEGASdkManager sharedMEGASdk] mnz_accountDetails]) {
        NSArray *sizesArray = @[cloudDriveSize, rubbishBinSize, incomingSharesSize, usedStorage, maxStorage];
        
        UsageViewController *usageVC = [[UIStoryboard storyboardWithName:@"MyAccount" bundle:nil] instantiateViewControllerWithIdentifier:@"UsageViewControllerID"];
        [self.navigationController pushViewController:usageVC animated:YES];
        
        [usageVC setSizesArray:sizesArray];
    }
}

- (IBAction)settingsTouchUpInside:(UIButton *)sender {
    SettingsTableViewController *settingsTVC = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsTableViewControllerID"];
    [self.navigationController pushViewController:settingsTVC animated:YES];
}

#pragma mark - MEGARequestDelegate

- (void)onRequestFinish:(MEGASdk *)api request:(MEGARequest *)request error:(MEGAError *)error {
    [super onRequestFinish:api request:request error:error];
    
    if ([error type]) {
        return;
    }
    
    switch ([request type]) {
        case MEGARequestTypeAccountDetails: {
            [self setupWithAccountDetails];
            break;
        }
            
        default:
            break;
    }
}

@end
