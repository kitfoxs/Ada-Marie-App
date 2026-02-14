import Foundation

public enum AdaMarieChatTransportEvent: Sendable {
    case health(ok: Bool)
    case tick
    case chat(AdaMarieChatEventPayload)
    case agent(AdaMarieAgentEventPayload)
    case seqGap
}

public protocol AdaMarieChatTransport: Sendable {
    func requestHistory(sessionKey: String) async throws -> AdaMarieChatHistoryPayload
    func sendMessage(
        sessionKey: String,
        message: String,
        thinking: String,
        idempotencyKey: String,
        attachments: [AdaMarieChatAttachmentPayload]) async throws -> AdaMarieChatSendResponse

    func abortRun(sessionKey: String, runId: String) async throws
    func listSessions(limit: Int?) async throws -> AdaMarieChatSessionsListResponse

    func requestHealth(timeoutMs: Int) async throws -> Bool
    func events() -> AsyncStream<AdaMarieChatTransportEvent>

    func setActiveSessionKey(_ sessionKey: String) async throws
}

extension AdaMarieChatTransport {
    public func setActiveSessionKey(_: String) async throws {}

    public func abortRun(sessionKey _: String, runId _: String) async throws {
        throw NSError(
            domain: "AdaMarieChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "chat.abort not supported by this transport"])
    }

    public func listSessions(limit _: Int?) async throws -> AdaMarieChatSessionsListResponse {
        throw NSError(
            domain: "AdaMarieChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "sessions.list not supported by this transport"])
    }
}
