
#import "MyAccountHallViewController.h"

#import "AchievementsViewController.h"
#import "ContactsViewController.h"
#import "OfflineTableViewController.h"
#import "MEGAUser+MNZCategory.h"
#import "MEGASdkManager.h"
#import "MyAccountHallTableViewCell.h"
#import "MyAccountViewController.h"
#import "SettingsTableViewController.h"
#import "TransfersViewController.h"

@interface MyAccountHallViewController () <UITableViewDataSource, UITableViewDelegate, MEGAGlobalDelegate>

@property (weak, nonatomic) IBOutlet UIView *profileView;

@property (weak, nonatomic) IBOutlet UILabel *viewAndEditProfileLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyAccountHallViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = AMLocalizedString(@"myAccount", @"Title of the app section where you can see your account details");
    
    self.viewAndEditProfileLabel.text = AMLocalizedString(@"viewAndEditProfile", @"Title show on the hall of My Account section that describes a place where you can view, edit and upgrade your account and profile");
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewAndEditProfileTouchUpInside:)];
    self.profileView.gestureRecognizers = @[tapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[MEGASdkManager sharedMEGASdk] addMEGAGlobalDelegate:self];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[MEGASdkManager sharedMEGASdk] removeMEGAGlobalDelegate:self];
}

#pragma mark - IBActions

- (IBAction)viewAndEditProfileTouchUpInside:(UIButton *)sender {
    MyAccountViewController *myAccountVC = [[UIStoryboard storyboardWithName:@"MyAccount" bundle:nil] instantiateViewControllerWithIdentifier:@"MyAccountViewControllerID"];
    [self.navigationController pushViewController:myAccountVC animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = (indexPath.row == 1) ? @"MyAccountHallWithSubtitleTableViewCellID" : @"MyAccountHallTableViewCellID";
    MyAccountHallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MyAccountHallTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    switch (indexPath.row) {
        case 0: { //Contacts
            cell.sectionLabel.text = AMLocalizedString(@"contactsTitle", @"Title of the Contacts section");
            cell.iconImageView.image = [UIImage imageNamed:@"myAccountContactsIcon"];
            MEGAContactRequestList *incomingContactsLists = [[MEGASdkManager sharedMEGASdk] incomingContactRequests];
            NSUInteger incomingContacts = incomingContactsLists.size.unsignedIntegerValue;
            if (incomingContacts == 0) {
                cell.pendingView.hidden = YES;
                cell.pendingLabel.text = nil;
            } else {
                if (cell.pendingView.hidden) {
                    cell.pendingView.hidden = NO;
                    cell.pendingView.clipsToBounds = YES;
                }
                
                cell.pendingLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)incomingContacts];
            }
            break;
        }
            
        case 1: { //Achievements
            cell.sectionLabel.text = AMLocalizedString(@"achievementsTitle", @"Title of the Achievements section");
            cell.subtitleLabel.text = AMLocalizedString(@"inviteFriendsAndGetRewards", @"Subtitle show under the Achievements label to explain what is this section");
            cell.iconImageView.image = [UIImage imageNamed:@"myAccountAchievementsIcon"];
            cell.pendingView.hidden = YES;
            cell.pendingLabel.text = nil;
            break;
        }
            
        case 2: { //Transfers
            cell.sectionLabel.text = AMLocalizedString(@"transfers", @"Title of the Transfers section");
            cell.iconImageView.image = [UIImage imageNamed:@"myAccountTransfersIcon"];
            cell.pendingView.hidden = YES;
            cell.pendingLabel.text = nil;
            break;
        }
            
        case 3: { //Offline
            cell.sectionLabel.text = AMLocalizedString(@"offline", @"Title of the Offline section");
            cell.iconImageView.image = [UIImage imageNamed:@"myAccountOfflineIcon"];
            cell.pendingView.hidden = YES;
            cell.pendingLabel.text = nil;
            break;
        }
            
        case 4: { //Settings
            cell.sectionLabel.text = AMLocalizedString(@"settingsTitle", @"Title of the Settings section");
            cell.iconImageView.image = [UIImage imageNamed:@"myAccountSettingsIcon"];
            cell.pendingView.hidden = YES;
            cell.pendingLabel.text = nil;
            break;
        }
    }
    
    [cell.sectionLabel sizeToFit];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat heightForRow;
    if (indexPath.row == 1 && ![[MEGASdkManager sharedMEGASdk] isAchievementsEnabled]) {
        heightForRow = 0.0f;
    } else {
        heightForRow = 60.0f;
    }
    
    return heightForRow;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: { //Contacts
            ContactsViewController *contactsVC = [[UIStoryboard storyboardWithName:@"Contacts" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactsViewControllerID"];
            [self.navigationController pushViewController:contactsVC animated:YES];
            break;
        }
            
        case 1: { //Achievements
            AchievementsViewController *achievementsVC = [[UIStoryboard storyboardWithName:@"MyAccount" bundle:nil] instantiateViewControllerWithIdentifier:@"AchievementsViewControllerID"];
            [self.navigationController pushViewController:achievementsVC animated:YES];
            break;
        }
            
        case 2: { //Transfers
            TransfersViewController *transferVC = [[UIStoryboard storyboardWithName:@"Transfers" bundle:nil] instantiateViewControllerWithIdentifier:@"TransfersViewControllerID"];
            [self.navigationController pushViewController:transferVC animated:YES];
            break;
        }
            
        case 3: { //Offline
            OfflineTableViewController *offlineTVC = [[UIStoryboard storyboardWithName:@"Offline" bundle:nil] instantiateViewControllerWithIdentifier:@"OfflineTableViewControllerID"];
            [self.navigationController pushViewController:offlineTVC animated:YES];
            break;
        }
            
        case 4: { //Settings
            SettingsTableViewController *settingsTVC = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsTableViewControllerID"];
            [self.navigationController pushViewController:settingsTVC animated:YES];
            break;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MEGAGlobalDelegate

- (void)onContactRequestsUpdate:(MEGASdk *)api contactRequestList:(MEGAContactRequestList *)contactRequestList {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
