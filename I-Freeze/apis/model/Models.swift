import Foundation
import UIKit
import Foundation

struct DeviceResponse: Codable {
    let data: DeviceData
    let status: Int
    let message: String
}

struct DeviceData: Codable {
    let device: Device
    let blockedApps: [String]?
    let blockedIps: [String]?
    let blockedWebsites: [String]?
    let exceptionIps: [String]?
    let exceptionWebsites: [String]?
    let exceptionApps: [String]?
    let exceptionWifi: [String]?
    let deviceKioskApps: [String]?
    let websiteCategories: [String]?
}

struct Device: Codable {
    let id: String
    let licenseId: String
    let isActive: Bool
    let deviceName: String
    let time: String
    let isAdminDevice: Bool
    let operatingSystemVersion: String
    let deviceIp: String
    let macAddress: String
    let serialNumber: String
    let versionNumber: Double
    let disableUSB: Bool
    let disableTethering: Bool
    let activateProactiveScan: Bool
    let activateNetworkScan: Bool
    let enableUSBScan: Bool
    let muteMicrophone: Bool
    let disableCamera: Bool
    let isolateDevice: Bool
    let blockPowerShell: Bool
    let blockUntrustedIPs: Bool
    let activateWhitelist: Bool
    let tamperProtection: Bool
    let activateWhitelistWebsite: Bool
    let dlp: Bool
    let automatedPatchManagement: Bool
    let autoScan: Bool
    let scanTime: String
    let devicePassword: String
    let flag: Bool
    let blockWiFi: Bool
    let whiteListWiFi: Bool
    let blockListURLs: Bool
    let whiteListURLs: Bool
    let blockListApps: Bool
    let whiteListApps: Bool
    let browsers: Bool
    let kiosk: Bool
    let locationTracker: Bool
    let license: String?
    let createdOn: String
    let createdBy: String
    let updatedOn: String
    let updatedBy: String
}
//The model will contain all the fields needed for the device information, aligning with the structure expected by the server.
// DeviceInfo.swift activate license
struct DeviceInfo: Codable {
    let deviceName: String
    let operatingSystemVersion: String
    let deviceIp: String
    let macAddress: String
    let serialNumber: String
    let typeOfLicense: String
    
    // Factory initializer to create DeviceInfo from the device properties
    static func create() -> DeviceInfo {
        return DeviceInfo(
            deviceName: UIDevice.current.name,
            operatingSystemVersion: "iOS \(UIDevice.current.systemVersion)",
            deviceIp: DeviceInfoManager.shared.getIPAddress(),
            macAddress: DeviceInfoManager.shared.getOrGenerateMACAddress(),
            serialNumber: DeviceInfoManager.shared.getOrGenerateMACAddress(),
            typeOfLicense: "Premium"
        )
    }
}
struct LocationData: Codable {
    let location: String
    let address: String
    let deviceId: String
    
    enum CodingKeys: String, CodingKey {
        case location = "Location"
        case address = "Address"
        case deviceId = "DeviceId"
    }
}

