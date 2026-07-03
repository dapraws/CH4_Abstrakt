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
            let total = int64Value(attrs[.systemSize]),
            let free = int64Value(attrs[.systemFreeSize])
        else {
            return StorageSnapshot(totalBytes: 0, availableBytes: 0)
        }

        return StorageSnapshot(
            totalBytes: max(0, total),
            availableBytes: min(max(0, free), max(0, total))
        )
    }

    private static func int64Value(_ value: Any?) -> Int64? {
        switch value {
        case let value as Int64:
            value
        case let value as Int:
            Int64(value)
        case let value as UInt64:
            value > UInt64(Int64.max) ? Int64.max : Int64(value)
        case let value as UInt:
            value > UInt(Int64.max) ? Int64.max : Int64(value)
        case let value as NSNumber:
            value.int64Value
        default:
            nil
        }
    }
}
