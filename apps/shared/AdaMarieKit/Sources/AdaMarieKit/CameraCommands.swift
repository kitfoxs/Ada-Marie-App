import Foundation

public enum AdaMarieCameraCommand: String, Codable, Sendable {
    case list = "camera.list"
    case snap = "camera.snap"
    case clip = "camera.clip"
}

public enum AdaMarieCameraFacing: String, Codable, Sendable {
    case back
    case front
}

public enum AdaMarieCameraImageFormat: String, Codable, Sendable {
    case jpg
    case jpeg
}

public enum AdaMarieCameraVideoFormat: String, Codable, Sendable {
    case mp4
}

public struct AdaMarieCameraSnapParams: Codable, Sendable, Equatable {
    public var facing: AdaMarieCameraFacing?
    public var maxWidth: Int?
    public var quality: Double?
    public var format: AdaMarieCameraImageFormat?
    public var deviceId: String?
    public var delayMs: Int?

    public init(
        facing: AdaMarieCameraFacing? = nil,
        maxWidth: Int? = nil,
        quality: Double? = nil,
        format: AdaMarieCameraImageFormat? = nil,
        deviceId: String? = nil,
        delayMs: Int? = nil)
    {
        self.facing = facing
        self.maxWidth = maxWidth
        self.quality = quality
        self.format = format
        self.deviceId = deviceId
        self.delayMs = delayMs
    }
}

public struct AdaMarieCameraClipParams: Codable, Sendable, Equatable {
    public var facing: AdaMarieCameraFacing?
    public var durationMs: Int?
    public var includeAudio: Bool?
    public var format: AdaMarieCameraVideoFormat?
    public var deviceId: String?

    public init(
        facing: AdaMarieCameraFacing? = nil,
        durationMs: Int? = nil,
        includeAudio: Bool? = nil,
        format: AdaMarieCameraVideoFormat? = nil,
        deviceId: String? = nil)
    {
        self.facing = facing
        self.durationMs = durationMs
        self.includeAudio = includeAudio
        self.format = format
        self.deviceId = deviceId
    }
}
