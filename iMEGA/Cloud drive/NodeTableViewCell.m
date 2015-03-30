/**
 * @file NodeTableViewCell.m
 * @brief Custom node table view cell of the app.
 *
 * (c) 2013-2014 by Mega Limited, Auckland, New Zealand
 *
 * This file is part of the MEGA SDK - Client Access Engine.
 *
 * Applications using the MEGA API must present a valid application key
 * and comply with the the rules set forth in the Terms of Service.
 *
 * The MEGA SDK is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * @copyright Simplified (2-clause) BSD License.
 *
 * You should have received a copy of the license along with this
 * program.
 */

#import "NodeTableViewCell.h"
#import "MEGASdkManager.h"
#import "Helper.h"

@implementation NodeTableViewCell

- (IBAction)cancelTransfer:(id)sender {
    NSNumber *transferTag = [[Helper downloadingNodes] objectForKey:[MEGASdk base64HandleForHandle:self.nodeHandle]];
    if (transferTag != nil) {
        [[MEGASdkManager sharedMEGASdk] cancelTransferByTag:transferTag.integerValue];
    }
}

@end
