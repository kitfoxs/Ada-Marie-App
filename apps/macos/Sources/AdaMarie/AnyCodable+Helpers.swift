import AdaMarieKit
import AdaMarieProtocol
import Foundation

// Prefer the AdaMarieKit wrapper to keep gateway request payloads consistent.
typealias AnyCodable = AdaMarieKit.AnyCodable
typealias InstanceIdentity = AdaMarieKit.InstanceIdentity

extension AnyCodable {
    var stringValue: String? { self.value as? String }
    var boolValue: Bool? { self.value as? Bool }
    var intValue: Int? { self.value as? Int }
    var doubleValue: Double? { self.value as? Double }
    var dictionaryValue: [String: AnyCodable]? { self.value as? [String: AnyCodable] }
    var arrayValue: [AnyCodable]? { self.value as? [AnyCodable] }

    var foundationValue: Any {
        switch self.value {
        case let dict as [String: AnyCodable]:
            dict.mapValues { $0.foundationValue }
        case let array as [AnyCodable]:
            array.map(\.foundationValue)
        default:
            self.value
        }
    }
}

extension AdaMarieProtocol.AnyCodable {
    var stringValue: String? { self.value as? String }
    var boolValue: Bool? { self.value as? Bool }
    var intValue: Int? { self.value as? Int }
    var doubleValue: Double? { self.value as? Double }
    var dictionaryValue: [String: AdaMarieProtocol.AnyCodable]? { self.value as? [String: AdaMarieProtocol.AnyCodable] }
    var arrayValue: [AdaMarieProtocol.AnyCodable]? { self.value as? [AdaMarieProtocol.AnyCodable] }

    var foundationValue: Any {
        switch self.value {
        case let dict as [String: AdaMarieProtocol.AnyCodable]:
            dict.mapValues { $0.foundationValue }
        case let array as [AdaMarieProtocol.AnyCodable]:
            array.map(\.foundationValue)
        default:
            self.value
        }
    }
}
