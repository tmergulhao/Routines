//
//  CloudKitEncodable.swift
//  CloudKitCodable
//
//  Created by Guilherme Rambo on 11/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import CloudKit

internal let _CKSystemFieldsKeyName = "cloudKitSystemFields"
internal let _CKIdentifierKeyName = "cloudKitIdentifier"

public protocol CKRecordRepresentable {

    /**
     This property should return the Cloud Kit record type name.
     It returns the name of the type automatically,
     but can be implemented to return a custom record type name.
     */
    var recordTypeName : String { get }

    /**
     Overridable Cloud Kit record name.
     Automatically implemented UUID string.
     */
    var recordName : String { get }
}

typealias CKEncodable = CKRecordRepresentable & Encodable
typealias CKDecodable = CKRecordRepresentable & Decodable
typealias CKCodable = CKEncodable & CKDecodable

fileprivate struct KeyValues {

    static var cloudKitSystemFields = "cloudKitSystemFields"
}

extension CKRecordRepresentable {

    /**
     This is used to store the system fields when decoding.
     It contains metadata such as the record's unique
     identifier and is very important when syncing.
     */
    public var cloudKitSystemFields : Data? {
        get {
            return objc_getAssociatedObject(self, &KeyValues.cloudKitSystemFields) as? Data
        }
        set {
            objc_setAssociatedObject(self, &KeyValues.cloudKitSystemFields, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension CKRecordRepresentable {
    public var recordTypeName: String { return String(describing: type(of: self)) }
    public var recordName: String { return UUID().uuidString }
}
