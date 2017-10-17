#import "ConfirmAccountViewController.h"

#import "SAMKeychain.h"
#import "SVProgressHUD.h"

#import "Helper.h"
#import "MEGALoginRequestDelegate.h"
#import "MEGAReachabilityManager.h"

@interface ConfirmAccountViewController () <UIAlertViewDelegate, UITextFieldDelegate, MEGARequestDelegate>

@property (weak, nonatomic) IBOutlet UILabel *confirmTextLabel;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation ConfirmAccountViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.confirmType == ConfirmTypeAccount) {
        self.confirmTextLabel.text = AMLocalizedString(@"confirmText", @"Text shown on the confirm account view to remind the user what to do");
        [self.confirmAccountButton setTitle:AMLocalizedString(@"confirmAccountButton", @"Button title that triggers the confirm account action") forState:UIControlStateNormal];
    } else if (self.confirmType == ConfirmTypeEmail) {
        self.confirmTextLabel.text = AMLocalizedString(@"verifyYourEmailAddress_description", @"Text shown on the confirm email view to remind the user what to do");
        [self.confirmAccountButton setTitle:AMLocalizedString(@"confirmEmail", @"Button text for the user to confirm their change of email address.") forState:UIControlStateNormal];
    } else if (self.confirmType == ConfirmTypeCancelAccount) {
        self.confirmTextLabel.text = AMLocalizedString(@"enterYourPasswordToConfirmThatYouWanToClose", @"Account closure, message shown when you click on the link in the email to confirm the closure of your account");
        [self.confirmAccountButton setTitle:AMLocalizedString(@"closeAccount", @"Account closure, password check dialog when user click on closure email.") forState:UIControlStateNormal];
    }
    
    [self.cancelButton setTitle:AMLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    
    [self.emailTextField setPlaceholder:AMLocalizedString(@"emailPlaceholder", @"Email")];
    [self.passwordTextField setPlaceholder:AMLocalizedString(@"passwordPlaceholder", @"Password")];
    
    [self.emailTextField setText:_emailString];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] iPhoneDevice]) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - IBActions

- (IBAction)confirmTouchUpInside:(id)sender {
    if ([MEGAReachabilityManager isReachableHUDIfNot]) {
        if ([self validateForm]) {
            [SVProgressHUD show];
            [self lockUI:YES];
            if (self.confirmType == ConfirmTypeAccount) {
                [[MEGASdkManager sharedMEGASdk] confirmAccountWithLink:self.confirmationLinkString password:[self.passwordTextField text] delegate:self];
            } else if (self.confirmType == ConfirmTypeEmail) {
                [[MEGASdkManager sharedMEGASdk] confirmChangeEmailWithLink:self.confirmationLinkString password:self.passwordTextField.text delegate:self];
            } else if (self.confirmType == ConfirmTypeCancelAccount) {
                [[MEGASdkManager sharedMEGASdk] confirmCancelAccountWithLink:self.confirmationLinkString password:self.passwordTextField.text delegate:self];
            }
        }
    }
}

- (IBAction)cancelTouchUpInside:(UIButton *)sender {
    [self.passwordTextField resignFirstResponder];
    
    if (self.confirmType == ConfirmTypeAccount) {
        NSString *message = AMLocalizedString(@"areYouSureYouWantToAbortTheRegistration", @"Asking whether the user really wants to abort/stop the registration process or continue on.");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:AMLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:AMLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[MEGASdkManager sharedMEGASdk] logout];
            [SAMKeychain deletePasswordForService:@"MEGA" account:@"sessionId"];
            [SAMKeychain deletePasswordForService:@"MEGA" account:@"email"];
            [SAMKeychain deletePasswordForService:@"MEGA" account:@"name"];
            [SAMKeychain deletePasswordForService:@"MEGA" account:@"base64pwkey"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private

- (BOOL)validateForm {
    if (self.passwordTextField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:AMLocalizedString(@"passwordInvalidFormat", @"Enter a valid password")];
        [self.passwordTextField becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)lockUI:(BOOL)boolValue {
    [self.passwordTextField setEnabled:!boolValue];
    [self.confirmAccountButton setEnabled:!boolValue];
    [self.cancelButton setEnabled:!boolValue];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 0) {
        if (buttonIndex == 0) {
            [self lockUI:NO];
        } else if (buttonIndex == 1) {
            [self lockUI:YES];
            [SVProgressHUD show];
            [[MEGASdkManager sharedMEGASdk] logoutWithDelegate:self];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_passwordTextField resignFirstResponder];
    return YES;
}


#pragma mark - MEGARequestDelegate

- (void)onRequestFinish:(MEGASdk *)api request:(MEGARequest *)request error:(MEGAError *)error {
    if ([error type]) {
        switch ([error type]) {
            case MEGAErrorTypeApiENoent: { //MEGARequestTypeConfirmAccount, MEGARequestTypeConfirmChangeEmailLink, MEGARequestTypeConfirmCancelLink
                [self lockUI:NO];
                [SVProgressHUD showErrorWithStatus:AMLocalizedString(@"passwordWrong", @"Wrong password")];
                break;
            }
                
            case MEGAErrorTypeApiEAccess: {
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
                [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:AMLocalizedString(@"alreadyLoggedInAlertTitle", @"You are logged with another account")
                                                                    message:AMLocalizedString(@"alreadyLoggedInAlertMessage", @"If you agree, the current account will be logged out and all Offline data will be erased. Do you want to continue?")
                                                                   delegate:self
                                                          cancelButtonTitle:AMLocalizedString(@"cancel", nil)
                                                          otherButtonTitles:AMLocalizedString(@"ok", nil), nil];
                [alertView setTag:0];
                [alertView show];
                break;
            }

            default:
                [self lockUI:NO];
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@ (%ld)", error.name, (long)error.type]];
                break;
        }
        
        return;
    }
    
    switch ([request type]) {
            
        case MEGARequestTypeConfirmAccount: {
            if ([MEGASdkManager sharedMEGAChatSdk] == nil) {
                [MEGASdkManager createSharedMEGAChatSdk];
            }
            
            MEGAChatInit chatInit = [[MEGASdkManager sharedMEGAChatSdk] initKarereWithSid:nil];
            if (chatInit != MEGAChatInitWaitingNewSession) {
                MEGALogError(@"Init Karere without sesion must return waiting for a new sesion");
                [[MEGASdkManager sharedMEGAChatSdk] logout];
            }
            
            if (![api isLoggedIn] || [api isLoggedIn] <= 1) {
                MEGALoginRequestDelegate *loginRequestDelegate = [[MEGALoginRequestDelegate alloc] init];
                [api loginWithEmail:[self.emailTextField text] password:[self.passwordTextField text] delegate:loginRequestDelegate];
                
                [SAMKeychain deletePasswordForService:@"MEGA" account:@"sessionId"];
                [SAMKeychain deletePasswordForService:@"MEGA" account:@"email"];
                [SAMKeychain deletePasswordForService:@"MEGA" account:@"name"];
                [SAMKeychain deletePasswordForService:@"MEGA" account:@"base64pwkey"];
            }
            break;
        }
            
        case MEGARequestTypeLogout: {
            [Helper logoutFromConfirmAccount];
            [[MEGASdkManager sharedMEGASdk] confirmAccountWithLink:self.confirmationLinkString password:[self.passwordTextField text] delegate:self];
            break;
        }
            
        case MEGARequestTypeConfirmChangeEmailLink: {
            [SVProgressHUD dismiss];
            [self.passwordTextField resignFirstResponder];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"emailHasChanged" object:nil];
            
            NSString *alertMessage = [AMLocalizedString(@"congratulationsNewEmailAddress", @"The [X] will be replaced with the e-mail address.") stringByReplacingOccurrencesOfString:@"[X]" withString:request.email];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:AMLocalizedString(@"newEmail", @"Hint text to suggest that the user have to write the new email on it")
                                                                message:alertMessage
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:AMLocalizedString(@"ok", nil), nil];
            [alertView show];
            break;
        }
            
        default:
            break;
    }
}

@end
