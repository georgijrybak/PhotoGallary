//
//  NetworkCheckManager.swift
//  PhotoGallary
//
//  Created by Георгий Рыбак on 18.05.22.
//

import Foundation
import Network

protocol NetworkCheckManagerDelegate: AnyObject {
    func connectionStatus(isConnected: Bool)
}

class NetworkCheckManager {
    static var shared = NetworkCheckManager()

    private let monitor = NWPathMonitor()

    private let queue = DispatchQueue.global()

    weak var delegate: NetworkCheckManagerDelegate?

    var isConnetned: Bool = false

    private init() {}

    func appBecomeActive() {
        delegate?.connectionStatus(isConnected: isConnetned)
    }

    func startChecking() {
        monitor.start(queue: queue)

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status == .satisfied {
                self.isConnetned = true
            } else {
                self.isConnetned = false
                self.delegate?.connectionStatus(isConnected: self.isConnetned)
            }
        }
    }
}
