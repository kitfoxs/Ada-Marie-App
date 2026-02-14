import Foundation

// Stable identifier used for both the macOS LaunchAgent label and Nix-managed defaults suite.
// nix-adamarie writes app defaults into this suite to survive app bundle identifier churn.
let launchdLabel = "ai.adamarie.mac"
let gatewayLaunchdLabel = "ai.adamarie.gateway"
let onboardingVersionKey = "adamarie.onboardingVersion"
let onboardingSeenKey = "adamarie.onboardingSeen"
let currentOnboardingVersion = 7
let pauseDefaultsKey = "adamarie.pauseEnabled"
let iconAnimationsEnabledKey = "adamarie.iconAnimationsEnabled"
let swabbleEnabledKey = "adamarie.swabbleEnabled"
let swabbleTriggersKey = "adamarie.swabbleTriggers"
let voiceWakeTriggerChimeKey = "adamarie.voiceWakeTriggerChime"
let voiceWakeSendChimeKey = "adamarie.voiceWakeSendChime"
let showDockIconKey = "adamarie.showDockIcon"
let defaultVoiceWakeTriggers = ["adamarie"]
let voiceWakeMaxWords = 32
let voiceWakeMaxWordLength = 64
let voiceWakeMicKey = "adamarie.voiceWakeMicID"
let voiceWakeMicNameKey = "adamarie.voiceWakeMicName"
let voiceWakeLocaleKey = "adamarie.voiceWakeLocaleID"
let voiceWakeAdditionalLocalesKey = "adamarie.voiceWakeAdditionalLocaleIDs"
let voicePushToTalkEnabledKey = "adamarie.voicePushToTalkEnabled"
let talkEnabledKey = "adamarie.talkEnabled"
let iconOverrideKey = "adamarie.iconOverride"
let connectionModeKey = "adamarie.connectionMode"
let remoteTargetKey = "adamarie.remoteTarget"
let remoteIdentityKey = "adamarie.remoteIdentity"
let remoteProjectRootKey = "adamarie.remoteProjectRoot"
let remoteCliPathKey = "adamarie.remoteCliPath"
let canvasEnabledKey = "adamarie.canvasEnabled"
let cameraEnabledKey = "adamarie.cameraEnabled"
let systemRunPolicyKey = "adamarie.systemRunPolicy"
let systemRunAllowlistKey = "adamarie.systemRunAllowlist"
let systemRunEnabledKey = "adamarie.systemRunEnabled"
let locationModeKey = "adamarie.locationMode"
let locationPreciseKey = "adamarie.locationPreciseEnabled"
let peekabooBridgeEnabledKey = "adamarie.peekabooBridgeEnabled"
let deepLinkKeyKey = "adamarie.deepLinkKey"
let modelCatalogPathKey = "adamarie.modelCatalogPath"
let modelCatalogReloadKey = "adamarie.modelCatalogReload"
let cliInstallPromptedVersionKey = "adamarie.cliInstallPromptedVersion"
let heartbeatsEnabledKey = "adamarie.heartbeatsEnabled"
let debugPaneEnabledKey = "adamarie.debugPaneEnabled"
let debugFileLogEnabledKey = "adamarie.debug.fileLogEnabled"
let appLogLevelKey = "adamarie.debug.appLogLevel"
let voiceWakeSupported: Bool = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
