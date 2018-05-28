//
//  CloudKitRecordEncoder.swift
//  CloudKitCodable
//
//  Created by Guilherme Rambo on 11/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import CloudKit

public enum CKRecordEncodingError : Error {

    case unsupportedValue(for: String)
    case systemFieldsDecode(String)
    case unsupportedReferences(for: String)

    public var localizedDescription : String {
        switch self {
        case .unsupportedValue(let key):
            return """
                   The value of key \(key) is not supported. Only values that can be converted to
                   CKRecordValue are supported. Check the CloudKit documentation to see which types
                   can be used.
                   """
        case .systemFieldsDecode(let info):
            return "Failed to process \(_CKSystemFieldsKeyName): \(info)"
        case .unsupportedReferences(let key):
            return "References are not supported by CloudKitRecordEncoder yet. Key: \(key)."
        }
    }
}

public class CKRecordEncoder {

    public var zoneID : CKRecordZoneID?

    private var recordType : String!
    private var recordName : String!

    public var codingPath : Array<CodingKey> = []
    public var userInfo : Dictionary<CodingUserInfoKey, Any> = [:]

    fileprivate var container : CKRecordEncodingContainer?

    public func encode(_ value: Encodable) throws -> CKRecord {
        recordType = recordType(for: value)
        recordName = recordName(for: value)

        try value.encode(to: self)

        return record
    }

    private func recordType(for value: Encodable) -> String {
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

extension CodingUserInfoKey {
    static let targetRecord = CodingUserInfoKey(rawValue: "TargetRecord")!
}

extension CKRecordEncoder : Encoder {

    var record : CKRecord {

        if let existingRecord = container?.record { return existingRecord }

        let zoneID = self.zoneID ?? CKRecordZoneID(zoneName: CKRecordZoneDefaultName, ownerName: CKCurrentUserDefaultName)
        let recordID = CKRecordID(recordName: recordName, zoneID: zoneID)

        return CKRecord(recordType: recordType, recordID: recordID)
    }

    fileprivate func assertCanCreateContainer() {
        precondition(self.container == nil)
    }

    public func container<Key : CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        assertCanCreateContainer()

        let container = KeyedContainer<Key>(
            recordType: recordType,
            zoneID: zoneID,
            recordName: recordName,
            codingPath: codingPath,
            userInfo: userInfo)

        self.container = container

        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Not implemented")
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Not implemented")
    }
}

protocol CKRecordEncodingContainer: class {
    var record: CKRecord? { get }
}

extension CKRecordEncoder {

    final class KeyedContainer<Key> where Key : CodingKey {

        let recordType: String
        let zoneID: CKRecordZoneID?
        let recordName: String
        var metaRecord: CKRecord?
        var codingPath : Array<CodingKey>
        var userInfo : Dictionary<CodingUserInfoKey, Any>

        fileprivate var storage : Dictionary<String, CKRecordValue> = [:]

        init(recordType: String, zoneID: CKRecordZoneID?, recordName: String, codingPath: Array<CodingKey>, userInfo: Dictionary<CodingUserInfoKey, Any>)
        {
            self.recordType = recordType
            self.zoneID = zoneID
            self.recordName = recordName
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
    }
}

extension CKRecordEncoder.KeyedContainer : KeyedEncodingContainerProtocol {

    func encodeNil(forKey key: Key) throws {
        storage[key.stringValue] = nil
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        guard key.stringValue != _CKSystemFieldsKeyName else {
            guard let systemFields = value as? Data else {
                throw CKRecordEncodingError.systemFieldsDecode("\(_CKSystemFieldsKeyName) property must be of type Data")
            }

            prepareMetaRecord(with: systemFields)

            return
        }

        do {
            let recordValue = try produceValue(for: value, withKey: key)
            storage[key.stringValue] = recordValue
        } catch {
            print(error)
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

extension CKRecordEncoder.KeyedContainer {

    private func produceValue<T : Encodable>(for value: T, withKey key: Key) throws -> CKRecordValue {
        switch value {
        case is Array<Any>, is Dictionary<AnyHashable, Any>:
            throw CKRecordEncodingError.unsupportedReferences(for: key.stringValue)
        case is URL:
            return produceValue(for: value as! URL)
        case is CKRecordValue:
            return value as! CKRecordValue
        case is UUID:
            return (value as! UUID).uuidString as CKRecordValue
        case is CKEncodable, is Array<CKEncodable>, is Dictionary<AnyHashable, CKEncodable>:
            throw CKRecordEncodingError.unsupportedReferences(for: key.stringValue)
        default:
            throw CKRecordEncodingError.unsupportedValue(for: key.stringValue)
        }
    }

    private func produceValue(for url: URL) -> CKRecordValue {
        return url.isFileURL ?
            CKAsset(fileURL: url) :
            url.absoluteString as CKRecordValue
    }

    private func produceReference(for value: CKEncodable) throws -> CKReference {

        let childRecord = try CKRecordEncoder().encode(value)
        return CKReference(record: childRecord, action: .deleteSelf)
    }

    private func prepareMetaRecord(with systemFields: Data) {
        let coder = NSKeyedUnarchiver(forReadingWith: systemFields)
        coder.requiresSecureCoding = true
        metaRecord = CKRecord(coder: coder)
        coder.finishDecoding()
    }
}

extension CKRecordEncoder.KeyedContainer: CKRecordEncodingContainer {

    var recordID: CKRecordID {
        let zoneID = self.zoneID ?? CKRecordZoneID(zoneName: CKRecordZoneDefaultName, ownerName: CKCurrentUserDefaultName)
        return CKRecordID(recordName: recordName, zoneID: zoneID)
    }

    var record: CKRecord? {

        let output : CKRecord = metaRecord ?? CKRecord(recordType: recordType, recordID: recordID)

        guard output.recordType == recordType else {
            fatalError(
                """
                CloudKit record type mismatch: the record should be of type \(recordType)
                but it was of type \(output.recordType). This is probably a result of corrupted
                cloudKitSystemData or a change in record/type name that must be corrected in
                your type by adopting CustomCloudKitEncodable.
                """
            )
        }

        for (key, value) in storage { output[key] = value }

        return output
    }

}
