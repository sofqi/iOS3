
#import "MasterKeyViewController.h"

#import "MEGAReachabilityManager.h"
#import "MEGASdkManager.h"

#import "HelpModalViewController.h"

@interface MasterKeyViewController ()

@property (weak, nonatomic) IBOutlet UIButton *carbonCopyMasterKeyButton;
@property (weak, nonatomic) IBOutlet UIButton *saveMasterKey;
@property (weak, nonatomic) IBOutlet UILabel *whyDoINeedARecoveryKeyLabel;

@end

@implementation MasterKeyViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = AMLocalizedString(@"recoveryKey", @"Label for any 'Recovery Key' button, link, text, title, etc. Preserve uppercase - (String as short as possible). The Recovery Key is the new name for the account 'Master Key', and can unlock (recover) the account if the user forgets their password.");
    
    [self.carbonCopyMasterKeyButton setTitle:AMLocalizedString(@"copy", @"List option shown on the details of a file or folder") forState:UIControlStateNormal];
    
    [self.saveMasterKey setTitle:AMLocalizedString(@"save", @"Button title to 'Save' the selected option") forState:UIControlStateNormal];
    
    self.whyDoINeedARecoveryKeyLabel.text = AMLocalizedString(@"whyDoINeedARecoveryKey", @"Question button to present a view where it's explained what is the Recovery Key");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] iPhone4X]) {
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([[UIDevice currentDevice] iPhone4X]) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] iPhoneDevice]) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - IBActions

- (IBAction)copyMasterKeyTouchUpInside:(UIButton *)sender {
    if ([[MEGASdkManager sharedMEGASdk] isLoggedIn]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [[MEGASdkManager sharedMEGASdk] masterKey];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:AMLocalizedString(@"recoveryKeyCopiedToClipboard", @"Title of the dialog displayed when copy the user's Recovery Key to the clipboard to be saved or exported - (String as short as possible).") message:nil delegate:nil cancelButtonTitle:AMLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
        [alertView show];
        
        [[MEGASdkManager sharedMEGASdk] masterKeyExported];
    } else {
        [MEGAReachabilityManager isReachableHUDIfNot];
    }
}

- (IBAction)saveMasterKeyTouchUpInside:(UIButton *)sender {
    if ([[MEGASdkManager sharedMEGASdk] isLoggedIn]) {
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *masterKeyFilePath = [documentsDirectory stringByAppendingPathComponent:@"RecoveryKey.txt"];
        
        BOOL success = [[NSFileManager defaultManager] createFileAtPath:masterKeyFilePath contents:[[[MEGASdkManager sharedMEGASdk] masterKey] dataUsingEncoding:NSUTF8StringEncoding] attributes:@{NSFileProtectionKey:NSFileProtectionComplete}];
        if (success) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:AMLocalizedString(@"masterKeyExported", nil) message:AMLocalizedString(@"masterKeyExported_alertMessage", nil) delegate:nil cancelButtonTitle:AMLocalizedString(@"ok", nil) otherButtonTitles:nil, nil];
            [alertView show];
            
            [[MEGASdkManager sharedMEGASdk] masterKeyExported];
        }
    } else {
        [MEGAReachabilityManager isReachableHUDIfNot];
    }
}

- (IBAction)whyDoINeedARecoveryKeyTouchUpInside:(UIButton *)sender {
    HelpModalViewController *helpModalVC = [[HelpModalViewController alloc] init];
    helpModalVC.modalPresentationStyle = UIModalPresentationCustom;
    helpModalVC.viewTitle = AMLocalizedString(@"whyDoINeedARecoveryKey", @"Question button to present a view where it's explained what is the Recovery Key");
    helpModalVC.firstParagraph = AMLocalizedString(@"masterKey_firstParagraph", @"Detailed explanation of how the master encryption key (now renamed 'Recovery Key') works, and why it is important to remember your password.");
    helpModalVC.secondParagraph = AMLocalizedString(@"exportMasterKeyFooter", @"Footer shown on the Settings / Security Options section that explains what means to export the Recovery Key");
    helpModalVC.thirdParagraph = AMLocalizedString(@"masterKey_thirdParagraph", nil);
    
    [self presentViewController:helpModalVC animated:YES completion:nil];
}

@end
