import Foundation

struct DeviceInfoManager {
    static let shared = DeviceInfoManager()
    
    private init() {}
    //This code will ensure that the MAC address is generated only once and persists across app reinstalls, staying unique to the device.
    // Retrieve or generate a unique MAC address
    func getOrGenerateMACAddress() -> String {
        // Check Keychain for existing MAC address
        if let savedMacAddress = KeychainHelper.shared.load(key: "macAddress") {
            return savedMacAddress
        }
        
        // Generate a new MAC address if none exists
        let newMacAddress = generateRandomMACAddress()
        
        // Save the new MAC address to Keychain
        KeychainHelper.shared.save(key: "macAddress", value: newMacAddress)
        
        return newMacAddress
    }
    
    // Function to generate a random MAC address format
    private func generateRandomMACAddress() -> String {
        let macAddressCharacters = "0123456789ABCDEF"
        var macAddress = ""
        
        for i in 0..<6 {
            if i > 0 { macAddress += ":" }
            for _ in 0..<2 {
                let randomIndex = Int(arc4random_uniform(UInt32(macAddressCharacters.count)))
                let stringIndex = macAddressCharacters.index(macAddressCharacters.startIndex, offsetBy: randomIndex)
                let randomCharacter = macAddressCharacters[stringIndex]
                macAddress += String(randomCharacter)
            }
        }
        
        return macAddress
    }
    // Function to get the device IP address
    func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                
                // Check for IPv4 addresses
                if addrFamily == AF_INET || addrFamily == AF_INET6 {
                    if let name = String(cString: interface.ifa_name, encoding: .utf8), name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                       &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                            address = String(cString: hostname)
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address ?? "Not Available"
    }
    
  
    
    // Function to generate a random serial number
    func generateRandomSerialNumber() -> String {
        let serialNumberCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var serialNumber = ""
        
        for _ in 0..<16 { // 16 characters long serial number
            let randomIndex = Int(arc4random_uniform(UInt32(serialNumberCharacters.count)))
            let stringIndex = serialNumberCharacters.index(serialNumberCharacters.startIndex, offsetBy: randomIndex)
            let randomCharacter = serialNumberCharacters[stringIndex]
            serialNumber += String(randomCharacter)
        }
        
        return serialNumber
    }
    
}
