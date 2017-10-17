
#include <sys/utsname.h>

#import "UIDevice+MNZCategory.h"

static NSString *machine;
static NSString *deviceName;

@implementation UIDevice (MNZCategory)

#pragma mark - Class methods

+ (NSDictionary *)devicesDictionary {
    static NSDictionary *devicesDictionary;
    
    if (devicesDictionary == nil) {
        devicesDictionary = @{@"i386":@"Simulator",
                              @"x86_64":@"Simulator",
                              @"iPod1,1":@"iPod touch",           //iPod touch (Original/1st Gen)
                              @"iPod2,1":@"iPod touch",           //iPod touch (2th Generation)
                              @"iPod3,1":@"iPod touch",           //iPod touch (3th Generation)
                              @"iPod4,1":@"iPod touch",           //iPod touch (4th Generation) (FaceTime)
                              @"iPod5,1":@"iPod touch",           //iPod touch (5th Generation) (No iSight)
                              @"iPod7,1":@"iPod touch",           //iPod touch (6th Generation)
                              @"iPhone1,1":@"iPhone",             //iPhone (Original/1st Generation) (EDGE)
                              @"iPhone1,2":@"iPhone 3G",          //iPhone 3G
                              @"iPhone1,2*":@"iPhone 3G",         //iPhone 3G (China/No Wi-Fi)
                              @"iPhone2,1":@"iPhone 3GS",         //iPhone 3GS
                              @"iPhone2,1*":@"iPhone 3GS",        //iPhone 3GS (China/No Wi-Fi)
                              @"iPhone3,1":@"iPhone 4",           //iPhone 4 (GSM)
                              @"iPhone3,2":@"iPhone 4",           //iPhone 4 (GSM)
                              @"iPhone3,3":@"iPhone 4",           //iPhone 4 (CDMA/Verizon/Sprint)
                              @"iPhone4,1":@"iPhone 4S",          //iPhone 4S
                              @"iPhone4,1*":@"iPhone 4S",         //iPhone 4S (GSM China/WAPI)
                              @"iPhone5,1":@"iPhone 5",           //iPhone 5 (GSM/LTE 4, 17/North America) (GSM/LTE 1, 3, 5/International) (GSM/LTE/AWS/North America)
                              @"iPhone5,2":@"iPhone 5",           //iPhone 5 (CDMA/LTE, Sprint/Verizon/KDDI) (CDMA China/UIM/WAPI)
                              @"iPhone5,3":@"iPhone 5C",          //iPhone 5C (GSM/North America/A1532) (CDMA/Verizon/A1532) (CDMA/China Telecom/A1532) (CDMA/US/Japan/A1456)
                              @"iPhone5,4":@"iPhone 5C",          //iPhone 5C (UK/Europe/Middle East/A1507) (China Unicom/A1526) (Asia Pacific/A1529) (China Mobile/A1516)
                              @"iPhone6,1":@"iPhone 5S",          //iPhone 5S (GSM/North America/A1533) (CDMA/Verizon/A1533) (CDMA/China Telecom/A1533) (CDMA/US/Japan/A1453)
                              @"iPhone6,2":@"iPhone 5S",          //iPhone 5S (UK/Europe/Middle East/A1457) (China Unicom/A1528) (Asia Pacific/A1530) (China Mobile/A1518)
                              @"iPhone7,1":@"iPhone 6 Plus",      //iPhone 6 Plus (GSM/North America/A1522) (CDMA/Verizon/A1522) (Global/Sprint/A1524) (China Mobile/A1593)
                              @"iPhone7,2":@"iPhone 6",           //iPhone 6 (GSM/North America/A1549) (CDMA/Verizon/A1549) (Global/Sprint/A1586) (China Mobile/A1589)
                              @"iPhone8,1":@"iPhone 6S",          //iPhone 6S (AT&T/SIM Free/A1633) (Global/A1688) (Mainland China/A1700)
                              @"iPhone8,2":@"iPhone 6S Plus",     //iPhone 6S Plus (AT&T/SIM Free/A1634) (Global/A1687) (Mainland China/A1699)
                              @"iPhone8,4":@"iPhone SE",          //iPhone SE (United States/A1662) (Global/Sprint/A1723) (China Mobile/A1724)
                              @"iPhone9,1":@"iPhone 7",           //iPhone 7
                              @"iPhone9,2":@"iPhone 7 Plus",      //iPhone 7 Plus
                              @"iPhone9,3":@"iPhone 7",           //iPhone 7
                              @"iPhone9,4":@"iPhone 7 Plus",      //iPhone 7 Plus
                              @"iPhone10,1":@"iPhone 8",          //iPhone 8
                              @"iPhone10,2":@"iPhone 8 Plus",     //iPhone 8 Plus
                              @"iPhone10,3":@"iPhone X",          //iPhone X
                              @"iPhone10,4":@"iPhone 8",          //iPhone 8
                              @"iPhone10,5":@"iPhone 8 Plus",     //iPhone 8 Plus
                              @"iPhone10,6":@"iPhone X",          //iPhone X
                              @"iPad1,1":@"iPad",                 //iPad (Original/1st Gen) (Wi-Fi/3G/GPS)
                              @"iPad2,1":@"iPad",                 //iPad 2 (Wi-Fi Only)
                              @"iPad2,2":@"iPad",                 //iPad 2 (Wi-Fi/GSM/GPS)
                              @"iPad2,3":@"iPad",                 //iPad 2 (Wi-Fi/CDMA/GPS)
                              @"iPad2,4":@"iPad",                 //iPad 2 (Wi-Fi Only)
                              @"iPad3,1":@"iPad",                 //iPad (3rd Generation)
                              @"iPad3,2":@"iPad",                 //iPad (3rd Generation)
                              @"iPad3,3":@"iPad",                 //iPad (3rd Generation)
                              @"iPad3,4":@"iPad",                 //iPad (4th Generation)
                              @"iPad3,5":@"iPad",                 //iPad (4th Generation) (Wi-Fi/AT&T/GPS)
                              @"iPad3,6":@"iPad",                 //iPad (4th Generation) (Wi-Fi/Verizon & Sprint/GPS)
                              @"iPad6,11":@"iPad",                //iPad (5th Generation) (Wi-Fi)
                              @"iPad6,12":@"iPad",                //iPad (5th Generation) (Cellular)
                              @"iPad4,1":@"iPad Air",             //iPad Air (5th Generation) (Wi-Fi)
                              @"iPad4,2":@"iPad Air",             //iPad Air (5th Generation) (Cellular)
                              @"iPad4,3":@"iPad Air",             //iPad Air (5th Generation) (Wi-Fi/TD-LTE - China)
                              @"iPad5,3":@"iPad Air",             //iPad Air 2 (Wi-Fi Only)
                              @"iPad5,4":@"iPad Air",             //iPad Air 2 (Wi-Fi/Cellular)
                              @"iPad2,5":@"iPad mini",            //iPad mini (1st Generation) (Wi-Fi Only)
                              @"iPad2,6":@"iPad mini",            //iPad mini (1st Generation) (Wi-Fi/AT&T/GPS)
                              @"iPad2,7":@"iPad mini",            //iPad mini (1st Generation) (Wi-Fi/VZ & Sprint/GPS)
                              @"iPad4,4":@"iPad mini",            //iPad mini (2nd Generation) (Retina, Wi-Fi Only)
                              @"iPad4,5":@"iPad mini",            //iPad mini (2nd Generation) (Retina, Wi-Fi/Cellular)
                              @"iPad4,6":@"iPad mini",            //iPad mini (2nd Generation) (Retina, China)
                              @"iPad4,7":@"iPad mini",            //iPad mini 3 (Wi-Fi Only)
                              @"iPad4,8":@"iPad mini",            //iPad mini 3 (Wi-Fi/Cellular)
                              @"iPad4,9":@"iPad mini",            //iPad mini 3 (Wi-Fi/Cellular, China)
                              @"iPad5,1":@"iPad mini",            //iPad mini 4 (Wi-Fi Only)
                              @"iPad5,2":@"iPad mini",            //iPad mini 4 (Wi-Fi/Cellular)
                              @"iPad6,7":@"iPad Pro (12.9-inch)", //iPad Pro 12.9-inch (Wi-Fi Only)
                              @"iPad6,8":@"iPad Pro (12.9-inch)", //iPad Pro 12.9-inch (Wi-Fi/Cellular)
                              @"iPad6,3":@"iPad Pro (9.7-inch)",  //iPad Pro 9.7-inch (Wi-Fi Only)
                              @"iPad6,4":@"iPad Pro (9.7-inch)",  //iPad Pro 9.7-inch (Wi-Fi/Cellular)
                              @"iPad7,1":@"iPad Pro (12.9-inch)", //iPad Pro 12.9-inch (Wi-Fi)
                              @"iPad7,2":@"iPad Pro (12.9-inch)", //iPad Pro 12.9-inch (Wi-Fi/Cellular)
                              @"iPad7,3":@"iPad Pro (10.5-inch)", //iPad Pro 10.5-inch (Wi-Fi)
                              @"iPad7,4":@"iPad Pro (10.5-inch)"};//iPad Pro 10.5-inch (Wi-Fi/Cellular)
    }
    
    return devicesDictionary;
}

#pragma mark - Instance methods

- (NSString *)hardwareType {
    if (machine == nil) {
        struct utsname systemInfo;
        uname(&systemInfo);
        machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    }
    
    return machine;
}

- (NSString *)unknownDevice {
    NSString *unknownDeviceName;
    if ([self iPhoneDevice]) {
        unknownDeviceName = @"iPhone";
    } else if ([self iPadDevice]) {
        unknownDeviceName = @"iPad";
    } else {
        unknownDeviceName = machine;
    }
    MEGALogInfo(@"Unknown device: %@", machine);
    
    return unknownDeviceName;
}

- (BOOL)iPhoneDevice {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? YES : NO;
}


- (BOOL)iPhone4X {
    if ([[self deviceName] hasPrefix:@"iPhone 4"] || [machine isEqualToString:@"iPod4,1"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)iPhone5X {
    if ([[self deviceName] hasPrefix:@"iPhone 5"] || [[self deviceName] isEqualToString:@"iPhone SE"] || [machine isEqualToString:@"iPod5,1"] || [machine isEqualToString:@"iPod7,1"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)iPhone6X {
    if ([[self deviceName] isEqualToString:@"iPhone 6"] || [[self deviceName] isEqualToString:@"iPhone 6S"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)iPhone6XPlus {
    if ([[self deviceName] isEqualToString:@"iPhone 6 Plus"] || [[self deviceName] isEqualToString:@"iPhone 6S Plus"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)iPadDevice {
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? YES : NO;
}

- (BOOL)iPad {
    if ([[self deviceName] isEqualToString:@"iPad"] || [[self deviceName] isEqualToString:@"iPad Air"] || [[self deviceName] isEqualToString:@"iPad Pro (9.7-inch)"] || [machine hasPrefix:@"iPad4"] || [machine hasPrefix:@"iPad5"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)iPadMini {
    if ([[self deviceName] hasPrefix:@"iPad mini"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)iPadPro {
    if ([[self deviceName] isEqualToString:@"iPad Pro (12.9-inch)"]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)deviceName {
    if (deviceName == nil) {
        NSString *deviceNameTemp = [[UIDevice devicesDictionary] objectForKey:[[UIDevice currentDevice] hardwareType]];
        deviceName = (deviceNameTemp == nil) ? [self unknownDevice] : deviceNameTemp;
    }
    return deviceName;
}

- (BOOL)systemVersionLessThanVersion:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending;
}

- (BOOL)systemVersionGreaterThanOrEqualVersion:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending;
}

@end
