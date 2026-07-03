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
        let url = URL(fileURLWithPath: NSHomeDirectory())
        let keys: Set<URLResourceKey> = [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey]
        
        if let values = try? url.resourceValues(forKeys: keys),
           let total = values.volumeTotalCapacity,
           let free = values.volumeAvailableCapacityForImportantUsage {
            
            let marketedTotal = marketingSize(for: max(0, Int64(total)))
            return StorageSnapshot(
                totalBytes: marketedTotal,
                availableBytes: min(max(0, Int64(free)), marketedTotal)
            )
        }

        // Fallback to legacy filesystem attributes if volume API fails
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let totalAttr = int64Value(attrs[.systemSize]),
              let freeAttr = int64Value(attrs[.systemFreeSize])
        else {
            return StorageSnapshot(totalBytes: 0, availableBytes: 0)
        }

        let marketedTotalAttr = marketingSize(for: max(0, totalAttr))
        return StorageSnapshot(
            totalBytes: marketedTotalAttr,
            availableBytes: min(max(0, freeAttr), marketedTotalAttr)
        )
    }

    private static func marketingSize(for rawBytes: Int64) -> Int64 {
        let base10GB = Double(rawBytes) / 1_000_000_000.0
        let standardSizes: [Double] = [16, 32, 64, 128, 256, 512, 1024, 2048, 4096]
        
        for size in standardSizes {
            // Give a 5% margin for APFS formatting overhead differences
            if base10GB <= size * 1.05 {
                return Int64(size * 1_000_000_000.0)
            }
        }
        
        return rawBytes
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
