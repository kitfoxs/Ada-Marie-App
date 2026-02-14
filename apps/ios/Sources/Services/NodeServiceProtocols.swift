import CoreLocation
import Foundation
import AdaMarieKit
import UIKit

protocol CameraServicing: Sendable {
    func listDevices() async -> [CameraController.CameraDeviceInfo]
    func snap(params: AdaMarieCameraSnapParams) async throws -> (format: String, base64: String, width: Int, height: Int)
    func clip(params: AdaMarieCameraClipParams) async throws -> (format: String, base64: String, durationMs: Int, hasAudio: Bool)
}

protocol ScreenRecordingServicing: Sendable {
    func record(
        screenIndex: Int?,
        durationMs: Int?,
        fps: Double?,
        includeAudio: Bool?,
        outPath: String?) async throws -> String
}

@MainActor
protocol LocationServicing: Sendable {
    func authorizationStatus() -> CLAuthorizationStatus
    func accuracyAuthorization() -> CLAccuracyAuthorization
    func ensureAuthorization(mode: AdaMarieLocationMode) async -> CLAuthorizationStatus
    func currentLocation(
        params: AdaMarieLocationGetParams,
        desiredAccuracy: AdaMarieLocationAccuracy,
        maxAgeMs: Int?,
        timeoutMs: Int?) async throws -> CLLocation
}

protocol DeviceStatusServicing: Sendable {
    func status() async throws -> AdaMarieDeviceStatusPayload
    func info() -> AdaMarieDeviceInfoPayload
}

protocol PhotosServicing: Sendable {
    func latest(params: AdaMariePhotosLatestParams) async throws -> AdaMariePhotosLatestPayload
}

protocol ContactsServicing: Sendable {
    func search(params: AdaMarieContactsSearchParams) async throws -> AdaMarieContactsSearchPayload
    func add(params: AdaMarieContactsAddParams) async throws -> AdaMarieContactsAddPayload
}

protocol CalendarServicing: Sendable {
    func events(params: AdaMarieCalendarEventsParams) async throws -> AdaMarieCalendarEventsPayload
    func add(params: AdaMarieCalendarAddParams) async throws -> AdaMarieCalendarAddPayload
}

protocol RemindersServicing: Sendable {
    func list(params: AdaMarieRemindersListParams) async throws -> AdaMarieRemindersListPayload
    func add(params: AdaMarieRemindersAddParams) async throws -> AdaMarieRemindersAddPayload
}

protocol MotionServicing: Sendable {
    func activities(params: AdaMarieMotionActivityParams) async throws -> AdaMarieMotionActivityPayload
    func pedometer(params: AdaMariePedometerParams) async throws -> AdaMariePedometerPayload
}

extension CameraController: CameraServicing {}
extension ScreenRecordService: ScreenRecordingServicing {}
extension LocationService: LocationServicing {}
