//
//  CloudKitRecordEncoder.swift
//  CloudKitCodable
//
//  Created by Guilherme Rambo on 11/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation
import CloudKit

public enum CloudKitRecordEncodingError : Error {

    case unsupportedValueForKey(String)
    case systemFieldsDecode(String)
    case referencesNotSupported(String)

    public var localizedDescription: String {
        switch self {
        case .unsupportedValueForKey(let key):
            return """
                   The value of key \(key) is not supported. Only values that can be converted to
                   CKRecordValue are supported. Check the CloudKit documentation to see which types
                   can be used.
                   """
        case .systemFieldsDecode(let info):
            return "Failed to process \(_CKSystemFieldsKeyName): \(info)"
        case .referencesNotSupported(let key):
            return "References are not supported by CloudKitRecordEncoder yet. Key: \(key)."
        }
    }
}

public class CloudKitRecordEncoder {

    public var zoneID: CKRecordZoneID?

    public func encode(_ value: Encodable) throws -> CKRecord {
        let type = recordTypeName(for: value)
        let name = recordName(for: value)

        let encoder = _CloudKitRecordEncoder(recordTypeName: type, zoneID: zoneID, recordName: name)

        try value.encode(to: encoder)

        return encoder.record
    }

    private func recordTypeName(for value: Encodable) -> String {

        let customValue = value as? CKEncodable

        return customValue?.recordTypeName ?? String(describing: type(of: value))
    }

    private func recordName(for value: Encodable) -> String {

        let customValue = value as? CKEncodable

        return customValue?.recordName ?? UUID().uuidString
    }

    public init(zoneID: CKRecordZoneID? = nil) {
        self.zoneID = zoneID
    }
}

final class _CloudKitRecordEncoder {
    let zoneID: CKRecordZoneID?
    let recordTypeName: String
    let recordName: String

    init(recordTypeName: String, zoneID: CKRecordZoneID?, recordName: String) {
        self.recordTypeName = recordTypeName
        self.zoneID = zoneID
        self.recordName = recordName
    }

    var codingPath: [CodingKey] = []

    var userInfo: [CodingUserInfoKey : Any] = [:]

    fileprivate var container: CloudKitRecordEncodingContainer?
}

extension CodingUserInfoKey {
    static let targetRecord = CodingUserInfoKey(rawValue: "TargetRecord")!
}

extension _CloudKitRecordEncoder: Encoder {
    var record: CKRecord {
        if let existingRecord = container?.record { return existingRecord }

        let zoneID = self.zoneID ?? CKRecordZoneID(zoneName: CKRecordZoneDefaultName, ownerName: CKCurrentUserDefaultName)
        let recordID = CKRecordID(recordName: recordName, zoneID: zoneID)

        return CKRecord(recordType: recordTypeName, recordID: recordID)
    }

    fileprivate func assertCanCreateContainer() {
        precondition(self.container == nil)
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        assertCanCreateContainer()

        let container = KeyedContainer<Key>(recordTypeName: self.recordTypeName,
                                            zoneID: self.zoneID,
                                            recordName: self.recordName,
                                            codingPath: self.codingPath,
                                            userInfo: self.userInfo)
        self.container = container

        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Not implemented")
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Not implemented")
    }
}

protocol CloudKitRecordEncodingContainer: class {
    var record: CKRecord? { get }
}

extension _CloudKitRecordEncoder {
    final class KeyedContainer<Key> where Key: CodingKey {
        let recordTypeName: String
        let zoneID: CKRecordZoneID?
        let recordName: String
        var metaRecord: CKRecord?
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]

        fileprivate var storage: [String: CKRecordValue] = [:]

        init(recordTypeName: String,
             zoneID: CKRecordZoneID?,
             recordName: String,
             codingPath: [CodingKey],
             userInfo: [CodingUserInfoKey : Any])
        {
            self.recordTypeName = recordTypeName
            self.zoneID = zoneID
            self.recordName = recordName
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension _CloudKitRecordEncoder.KeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
        storage[key.stringValue] = nil
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        guard key.stringValue != _CKSystemFieldsKeyName else {
            guard let systemFields = value as? Data else {
                throw CloudKitRecordEncodingError.systemFieldsDecode("\(_CKSystemFieldsKeyName) property must be of type Data")
            }

            prepareMetaRecord(with: systemFields)

            return
        }

        do {
            let recordValue = try produceCloudKitValue(for: value, withKey: key)
            storage[key.stringValue] = recordValue
        } catch {
            print(error)
        }
    }

    private func produceCloudKitValue<T>(for value: T, withKey key: Key) throws -> CKRecordValue where T : Encodable {

        switch value {

        case is URL:
            return produceRecordValue(for: value as! URL)

        case is CKRecordValue:
            return value as! CKRecordValue

        case is UUID:
            return (value as! UUID).uuidString as CKRecordValue

        case is CKEncodable, is Array<CKEncodable>, is Dictionary<AnyHashable, CKEncodable>:
            throw CloudKitRecordEncodingError.referencesNotSupported(key.stringValue)

        default: throw CloudKitRecordEncodingError.unsupportedValueForKey(key.stringValue)
        }
    }

    private func produceReference(for value: CKEncodable) throws -> CKReference {

        let childRecord = try CloudKitRecordEncoder().encode(value)

        return CKReference(record: childRecord, action: .deleteSelf)
    }

    private func prepareMetaRecord(with systemFields: Data) {
        let coder = NSKeyedUnarchiver(forReadingWith: systemFields)
        coder.requiresSecureCoding = true
        metaRecord = CKRecord(coder: coder)
        coder.finishDecoding()
    }

    private func produceRecordValue(for url: URL) -> CKRecordValue {
        if url.isFileURL {
            return CKAsset(fileURL: url)
        } else {
            return url.absoluteString as CKRecordValue
        }
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError("Not implemented")
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Not implemented")
    }

    func superEncoder() -> Encoder {
        fatalError("Not implemented")
    }

    func superEncoder(forKey key: Key) -> Encoder {
        fatalError("Not implemented")
    }
}

extension _CloudKitRecordEncoder.KeyedContainer: CloudKitRecordEncodingContainer {

    var recordID: CKRecordID {
        let zoneID = self.zoneID ?? CKRecordZoneID(zoneName: CKRecordZoneDefaultName, ownerName: CKCurrentUserDefaultName)
        return CKRecordID(recordName: recordName, zoneID: zoneID)
    }

    var record: CKRecord? {

        let output : CKRecord = metaRecord ?? CKRecord(recordType: recordTypeName, recordID: recordID)

        guard output.recordType == recordTypeName else {
            fatalError(
                """
                CloudKit record type mismatch: the record should be of type \(recordTypeName)
                but it was of type \(output.recordType). This is probably a result of corrupted
                cloudKitSystemData or a change in record/type name that must be corrected in
                your type by adopting CustomCloudKitEncodable.
                """
            )
        }

        for (key, value) in storage {
            output[key] = value
        }

        return output
    }

}
