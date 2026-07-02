//
//  StorageProvider.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 30/06/26.
//
import Foundation

struct StorageSnapshot: Codable, Hashable {
    let totalBytes: Int64
    let availableBytes: Int64

    var usedBytes: Int64 { totalBytes - availableBytes }
}

enum StorageProvider {
    static func currentSnapshot() -> StorageSnapshot {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()
        ),
            let total = attrs[.systemSize] as? Int64,
            let free = attrs[.systemFreeSize] as? Int64
        else {
            return StorageSnapshot(totalBytes: 0, availableBytes: 0)
        }
        return StorageSnapshot(totalBytes: total, availableBytes: free)
    }
}
