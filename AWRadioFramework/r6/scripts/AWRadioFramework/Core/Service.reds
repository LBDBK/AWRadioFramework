module AWRadioFramework

import Audioware.*
import Codeware.*

public class AWRadioTrackEndCallback extends DelayCallback {
  private let m_service: wref<AWRadioService>;
  private let m_generation: Int32;

  public static func Create(
    service: wref<AWRadioService>,
    generation: Int32
  ) -> ref<AWRadioTrackEndCallback> {
    let callback = new AWRadioTrackEndCallback();

    callback.m_service = service;
    callback.m_generation = generation;

    return callback;
  }

  public func Call() -> Void {
    if IsDefined(this.m_service) {
      this.m_service.OnTrackElapsed(this.m_generation);
    }
  }
}

public class AWRadioVolumeFadeCallback extends DelayCallback {
  private let m_service: wref<AWRadioService>;
  private let m_generation: Int32;
  private let m_step: Int32;
  private let m_steps: Int32;
  private let m_startVolume: Float;
  private let m_targetVolume: Float;
  private let m_source: CName;

  public static func Create(
    service: wref<AWRadioService>,
    generation: Int32,
    step: Int32,
    steps: Int32,
    startVolume: Float,
    targetVolume: Float,
    source: CName
  ) -> ref<AWRadioVolumeFadeCallback> {
    let callback = new AWRadioVolumeFadeCallback();

    callback.m_service = service;
    callback.m_generation = generation;
    callback.m_step = step;
    callback.m_steps = steps;
    callback.m_startVolume = startVolume;
    callback.m_targetVolume = targetVolume;
    callback.m_source = source;

    return callback;
  }

  public func Call() -> Void {
    if IsDefined(this.m_service) {
      this.m_service.ApplySafeVolumeFadeStep(
        this.m_generation,
        this.m_step,
        this.m_steps,
        this.m_startVolume,
        this.m_targetVolume,
        this.m_source
      );
    }
  }
}

public class AWRadioMenuPauseReassertCallback extends DelayCallback {
  private let m_service: wref<AWRadioService>;
  private let m_pauseGeneration: Int32;
  private let m_source: CName;

  public static func Create(
    service: wref<AWRadioService>,
    pauseGeneration: Int32,
    source: CName
  ) -> ref<AWRadioMenuPauseReassertCallback> {
    let callback = new AWRadioMenuPauseReassertCallback();

    callback.m_service = service;
    callback.m_pauseGeneration = pauseGeneration;
    callback.m_source = source;

    return callback;
  }

  public func Call() -> Void {
    if IsDefined(this.m_service) {
      this.m_service.ReassertManualPauseAfterMenu(
        this.m_pauseGeneration,
        this.m_source
      );
    }
  }
}

public class AWRadioService extends ScriptableService {
  private let m_callbackSystem: wref<CallbackSystem>;
  private let m_player: wref<PlayerPuppet>;

  private let m_stations: array<ref<AWRadioStationDefinition>>;
  private let m_stationValidationIssues: array<String>;
  private let m_stationValidationWarningShown: Bool;
  private let m_stationValidationMenuController: wref<SingleplayerMenuGameController>;
  private let m_activeStation: ref<AWRadioStationDefinition>;
  private let m_trackIndex: Int32;
  private let m_trackOrder: array<Int32>;
  private let m_trackOrderPosition: Int32;
  private let m_currentEvent: CName;
  private let m_currentSound: ref<DynamicSoundEvent>;
  private let m_generation: Int32;
  private let m_repeatCurrentTrack: Bool;
  private let m_isPaused: Bool;
  private let m_manualPauseGeneration: Int32;
  private let m_timeSkipMenuActive: Bool;
  private let m_timeSkipMenuAutoPaused: Bool;
  private let m_photoModeActive: Bool;
  private let m_photoModeAutoPaused: Bool;
  private let m_pausedPosition: Float;
  private let m_playbackAnchor: Float;
  private let m_playbackStartedAt: Float;
  private let m_sessionReady: Bool;
  private let m_loadingScreenMuted: Bool;
  private let m_loadingScreenGeneration: Int32;
  private let m_loadingScreenPosition: Float;
  private let m_loadingScreenSeekPrepared: Bool;
  private let m_fastTravelSoundDetached: Bool;
  private let m_conversationPhoneCallRestricted: Bool;
  private let m_conversationSceneTierRestricted: Bool;
  private let m_nativePocketRadioRestricted: Bool;
  private let m_autodriveEnabled: Bool;
  private let m_cinematicCameraActive: Bool;
  private let m_delamainTaxiActive: Bool;
  private let m_autodriveReleasePending: Bool;
  private let m_restrictionSceneTier: Bool;
  private let m_restrictionUpperBodyState: Bool;
  private let m_restrictionQuestContentLock: Bool;
  private let m_restrictionInDaClub: Bool;
  private let m_restrictionBlockFastTravel: Bool;
  private let m_restrictionVehicleScene: Bool;
  private let m_restrictionVehicleBlockPocketRadio: Bool;
  private let m_restrictionPhoneCall: Bool;
  private let m_restrictionPhoneNoTexting: Bool;
  private let m_restrictionPhoneNoCalling: Bool;
  private let m_restrictionFastForward: Bool;
  private let m_restrictionFastForwardHintActive: Bool;
  private let m_conversationReleasePending: Bool;
  private let m_conversationMuted: Bool;
  private let m_audioCombatMixActive: Bool;
  private let m_preventionHeatStage: Int32;
  private let m_preventionCombatMusicLatched: Bool;
  private let m_combatMusicSuppressed: Bool;
  private let m_volumeFadeGeneration: Int32;
  private let m_outputVolume: Float;
  private let m_onFootPlaybackEnabled: Bool;
  private let m_vehiclePlaybackEnabled: Bool;
  private let m_vehiclePlaybackInitialized: Bool;

  private let m_sharedRadioVolume: Float = 1.0;

  public static func Get() -> ref<AWRadioService> {
    return GameInstance
      .GetScriptableServiceContainer()
      .GetService(n"AWRadioFramework.AWRadioService") as AWRadioService;
  }

  private cb func OnLoad() -> Void {

    this.m_callbackSystem = GameInstance.GetCallbackSystem();

    this.m_callbackSystem.RegisterCallback(
      n"Session/Ready",
      this,
      n"OnSessionReady"
    );

    this.m_callbackSystem.RegisterCallback(
      n"Session/BeforeEnd",
      this,
      n"OnSessionBeforeEnd"
    );
  }

  private cb func OnSessionReady(event: ref<GameSessionEvent>) -> Void {
    this.m_player = GetPlayer(GetGameInstance());
    this.m_sessionReady = IsDefined(this.m_player);

    this.ResetConversationState();
    this.ResetCombatState();
    this.ResetPlaybackState();
    this.ResetContextPlaybackState();
    this.ResetTrackControlState();
    this.SyncVolumeSettings();
  }

  private cb func OnSessionBeforeEnd(event: ref<GameSessionEvent>) -> Void {
    this.Stop();
    this.ResetConversationState();
    this.ResetCombatState();
    this.ResetTrackControlState();

    this.m_sessionReady = false;
    this.m_player = null;
  }

  private func GetStationValidationLabel(
    station: ref<AWRadioStationDefinition>
  ) -> String {
    if !IsDefined(station) {
      return "<unknown station>";
    }

    return "'" + NameToString(station.displayName) + "' ["
      + TDBID.ToStringDEBUG(station.recordID) + "]";
  }

  public func RegisterStation(
    station: ref<AWRadioStationDefinition>
  ) -> Bool {
    let existing: ref<AWRadioStationDefinition>;
    let existingLabel: String;
    let stationLabel: String;
    let recordLabel: String;

    if !IsDefined(station) {
      return false;
    }

    if station.index < 0 || Equals(ArraySize(station.tracks), 0) {
      return false;
    }

    existing = this.FindStationByIndex(station.index);

    if IsDefined(existing) {
      if Equals(existing.recordID, station.recordID) {
        return true;
      }

      existingLabel = this.GetStationValidationLabel(existing);
      stationLabel = this.GetStationValidationLabel(station);

      this.RecordStationValidationIssue(
        s"Duplicate station index \(station.index): \(existingLabel) and \(stationLabel)"
      );

      return false;
    }

    existing = this.FindStationByRecord(station.recordID);

    if IsDefined(existing) {
      existingLabel = this.GetStationValidationLabel(existing);
      stationLabel = this.GetStationValidationLabel(station);
      recordLabel = TDBID.ToStringDEBUG(station.recordID);

      this.RecordStationValidationIssue(
        s"Duplicate TweakDB record \(recordLabel): \(existingLabel) and \(stationLabel)"
      );

      return false;
    }

    ArrayPush(this.m_stations, station);

    return true;
  }

  private func RecordStationValidationIssue(issue: String) -> Void {
    let i = 0;

    while i < ArraySize(this.m_stationValidationIssues) {
      if Equals(this.m_stationValidationIssues[i], issue) {
        return;
      }

      i += 1;
    }

    ArrayPush(this.m_stationValidationIssues, issue);

    this.TryDispatchStationValidationWarning();
  }

  public func SetStationValidationMenuController(
    controller: wref<SingleplayerMenuGameController>
  ) -> Void {
    this.m_stationValidationMenuController = controller;
    this.TryDispatchStationValidationWarning();
  }

  private func TryDispatchStationValidationWarning() -> Void {
    if !this.HasPendingStationValidationWarning()
      || !IsDefined(this.m_stationValidationMenuController) {
      return;
    }

    this.m_stationValidationMenuController
      .AWRadioShowPendingValidationPopup();
  }

  public func HasPendingStationValidationWarning() -> Bool {
    return !this.m_stationValidationWarningShown
      && ArraySize(this.m_stationValidationIssues) > 0;
  }

  public func GetStationValidationWarningMessage() -> String {
    let count = ArraySize(this.m_stationValidationIssues);
    let i = 0;
    let message = "AW Radio Framework found conflicting station definitions.";

    while i < count {
      message += "\n\n- " + this.m_stationValidationIssues[i];
      i += 1;
    }

    if count > 1 {
      return message
        + "\n\nThe conflicting station definitions were rejected."
        + "\nChange the duplicate indexes or TweakDB records, then restart the game.";
    }

    return message
      + "\n\nThe conflicting station definition was rejected."
      + "\nChange the duplicate index or TweakDB record, then restart the game.";
  }

  public func MarkStationValidationWarningShown() -> Void {
    this.m_stationValidationWarningShown = true;
  }

  public func GetStations() -> array<ref<AWRadioStationDefinition>> {
    return this.m_stations;
  }

  public func FindStationByIndex(
    index: Int32
  ) -> ref<AWRadioStationDefinition> {
    let station: ref<AWRadioStationDefinition>;
    let i = 0;

    while i < ArraySize(this.m_stations) {
      station = this.m_stations[i];

      if IsDefined(station) && Equals(station.index, index) {
        return station;
      }

      i += 1;
    }

    return null;
  }

  public func FindStationByRecord(
    recordID: TweakDBID
  ) -> ref<AWRadioStationDefinition> {
    let station: ref<AWRadioStationDefinition>;
    let i = 0;

    while i < ArraySize(this.m_stations) {
      station = this.m_stations[i];

      if IsDefined(station) && Equals(station.recordID, recordID) {
        return station;
      }

      i += 1;
    }

    return null;
  }

  public func IsCustomStation(index: Int32) -> Bool {
    return IsDefined(this.FindStationByIndex(index));
  }

  public func HandleRadioEvent(
    toggle: Bool,
    setStation: Bool,
    stationIndex: Int32
  ) -> Bool {
    let mounted = this.IsPlayerMounted();
    let station = this.FindStationByIndex(stationIndex);

    if !IsDefined(station) {
      return false;
    }

    if !this.EnsureSession() {
      return true;
    }

    if this.IsSyncToVehicleEnabled() {
      if !toggle {
        this.Stop();
        return true;
      }

      this.SetContextPlaybackEnabled(
        mounted,
        true,
        n"radio-event-sync-enabled"
      );

      if IsDefined(this.m_activeStation)
        && Equals(this.m_activeStation.index, station.index)
        && NotEquals(this.m_currentEvent, n"") {
        if this.m_isPaused {
          this.ResumePlayback(n"radio-event");
        }

        return true;
      }

      this.StartStation(station);
      return true;
    }

    this.SetContextPlaybackEnabled(
      mounted,
      toggle,
      n"radio-event-intent"
    );

    if !toggle {
      if IsDefined(this.m_activeStation)
        && Equals(this.m_activeStation.index, station.index)
        && NotEquals(this.m_currentEvent, n"") {
        this.ApplyPlaybackStateForContext(
          mounted,
          n"radio-event-off"
        );
      }

      return true;
    }

    if IsDefined(this.m_activeStation)
      && Equals(this.m_activeStation.index, station.index)
      && NotEquals(this.m_currentEvent, n"") {
      this.ApplyPlaybackStateForContext(
        mounted,
        n"radio-event-on"
      );

      return true;
    }

    this.StartStation(station);

    return true;
  }

  private func IsPlayerMounted() -> Bool {
    let player = GetPlayer(GetGameInstance());

    return IsDefined(player)
      && IsDefined(GetMountedVehicle(player));
  }

  public func IsSyncToVehicleEnabled() -> Bool {
    let setting = GameInstance
      .GetSettingsSystem(GetGameInstance())
      .GetVar(
        n"/gameplay/radioport",
        n"radioport_sync_to_car"
      ) as ConfigVarBool;

    if !IsDefined(setting) {
      return true;
    }

    return setting.GetValue();
  }

  public func IsOnFootPlaybackEnabled() -> Bool {
    return this.m_onFootPlaybackEnabled;
  }

  public func IsVehiclePlaybackEnabled() -> Bool {
    if !this.m_vehiclePlaybackInitialized {
      return this.m_onFootPlaybackEnabled;
    }

    return this.m_vehiclePlaybackEnabled;
  }

  public func InitializeVehiclePlaybackFromOnFoot(
    source: CName
  ) -> Bool {
    if !this.m_vehiclePlaybackInitialized {
      this.m_vehiclePlaybackEnabled =
        this.m_onFootPlaybackEnabled;
      this.m_vehiclePlaybackInitialized = true;
    }

    return this.m_vehiclePlaybackEnabled;
  }

  public func SetContextPlaybackEnabled(
    mounted: Bool,
    enabled: Bool,
    source: CName
  ) -> Void {
    if this.IsSyncToVehicleEnabled() {
      this.m_onFootPlaybackEnabled = enabled;
      this.m_vehiclePlaybackEnabled = enabled;
      this.m_vehiclePlaybackInitialized = true;
    } else {
      if mounted {
        this.m_vehiclePlaybackEnabled = enabled;
        this.m_vehiclePlaybackInitialized = true;
      } else {
        this.m_onFootPlaybackEnabled = enabled;
      }
    }
  }

  public func ApplyPlaybackStateForContext(
    mounted: Bool,
    source: CName
  ) -> Bool {
    let changed = false;
    let shouldPlay: Bool;

    if !this.HasActivePlayback() {
      return false;
    }

    if mounted {
      shouldPlay = this.IsVehiclePlaybackEnabled();
    } else {
      shouldPlay = this.m_onFootPlaybackEnabled;
    }

    if shouldPlay {
      if this.m_isPaused {
        changed = this.ResumePlayback(source);
      }
    } else {
      if !this.m_isPaused {
        changed = this.PausePlayback(source);
      }
    }

    return changed;
  }

  public func ReleaseForNativeRadio() -> Void {
    if IsDefined(this.m_activeStation) {
      this.Stop();
    }
  }

  public func GetActiveStationIndex() -> Int32 {
    if IsDefined(this.m_activeStation) {
      return this.m_activeStation.index;
    }

    return -1;
  }

  public func GetCurrentTrackTitle() -> String {
    let track = this.GetCurrentTrack();

    if IsDefined(track) {
      return track.title;
    }

    return "";
  }

  public func HasActivePlayback() -> Bool {
    return IsDefined(this.m_activeStation)
      && IsDefined(this.m_currentSound)
      && NotEquals(this.m_currentEvent, n"");
  }

  public func IsPlaybackRunning() -> Bool {
    return this.HasActivePlayback()
      && !this.m_isPaused;
  }

  public func IsPlaybackPaused() -> Bool {
    return this.m_isPaused;
  }

  public func SetTimeSkipMenuActive(
    active: Bool,
    source: CName
  ) -> Void {
    if Equals(this.m_timeSkipMenuActive, active) {
      return;
    }

    this.m_timeSkipMenuActive = active;

    if active {
      this.m_timeSkipMenuAutoPaused = false;

      if this.HasActivePlayback()
        && !this.m_isPaused {
        this.m_timeSkipMenuAutoPaused =
          this.PausePlayback(source);
      }

      if this.m_isPaused {
        this.PrepareManualPauseForMenu(source);
      }

      return;
    }

    if this.m_timeSkipMenuAutoPaused {
      this.m_timeSkipMenuAutoPaused = false;

      if this.m_isPaused {
        this.ResumePlayback(source);
      }

      return;
    }

    if this.m_isPaused {
      this.ScheduleManualPauseReassertAfterMenu(
        0.15,
        source
      );
    }
  }

  public func SetPhotoModeActive(
    active: Bool,
    source: CName
  ) -> Void {
    if Equals(this.m_photoModeActive, active) {
      return;
    }

    this.m_photoModeActive = active;

    if active {
      this.m_photoModeAutoPaused = false;

      if this.HasActivePlayback()
        && !this.m_isPaused {
        this.m_photoModeAutoPaused =
          this.PausePlayback(source);
      }

      if this.m_isPaused {
        this.PrepareManualPauseForMenu(source);
      }

      return;
    }

    if this.m_photoModeAutoPaused {
      this.m_photoModeAutoPaused = false;

      if this.m_isPaused {
        this.ResumePlayback(source);
      }

      return;
    }

    if this.m_isPaused {
      this.ScheduleManualPauseReassertAfterMenu(
        0.15,
        source
      );
    }
  }

  public func IsRadioControlRestricted() -> Bool {
    return this.m_conversationMuted;
  }

  private func IsPocketRadioAlwaysAvailableEnabled() -> Bool {
    let settings = AWRadioFrameworkSettings.Get();

    return IsDefined(settings)
      && settings.IsPocketRadioAlwaysAvailableEnabled();
  }

  public func IsRepeatCurrentTrackEnabled() -> Bool {
    return this.m_repeatCurrentTrack;
  }

  public func ToggleRepeatCurrentTrack(source: CName) -> Bool {
    if !this.HasActivePlayback()
      || this.m_loadingScreenMuted {
      return false;
    }

    this.m_repeatCurrentTrack = !this.m_repeatCurrentTrack;

    return true;
  }

  public func SkipCurrentTrack(source: CName) -> Bool {
    if !this.HasActivePlayback()
      || this.m_isPaused
      || this.m_loadingScreenMuted
      || Equals(ArraySize(this.m_trackOrder), 0) {
      return false;
    }

    this.m_generation += 1;

    if !this.AdvanceToNextTrack(source) {
      return false;
    }

    return true;
  }

  public func SetPocketRadioRestrictionState(
    restriction: PocketRadioRestrictions,
    restricted: Bool
  ) -> Void {
    let value = EnumInt(restriction);

    if Equals(value, 0) {
      this.m_restrictionSceneTier = restricted;
    } else {
      if Equals(value, 1) {
        this.m_restrictionUpperBodyState = restricted;
      } else {
        if Equals(value, 2) {
          this.m_restrictionQuestContentLock = restricted;
        } else {
          if Equals(value, 3) {
            this.m_restrictionInDaClub = restricted;
          } else {
            if Equals(value, 4) {
              this.m_restrictionBlockFastTravel = restricted;
            } else {
              if Equals(value, 5) {
                this.m_restrictionVehicleScene = restricted;
              } else {
                if Equals(value, 6) {
                  this.m_restrictionVehicleBlockPocketRadio = restricted;
                } else {
                  if Equals(value, 7) {
                    this.m_restrictionPhoneCall = restricted;
                  } else {
                    if Equals(value, 8) {
                      this.m_restrictionPhoneNoTexting = restricted;
                    } else {
                      if Equals(value, 9) {
                        this.m_restrictionPhoneNoCalling = restricted;
                      } else {
                        if Equals(value, 10) {
                          this.m_restrictionFastForward = restricted;
                        } else {
                          if Equals(value, 11) {
                            this.m_restrictionFastForwardHintActive = restricted;
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    this.RefreshConversationMute(
      n"pocket-radio-restriction-detail"
    );
  }

  public func SetAutonomousRideState(
    autodriveEnabled: Bool,
    cinematicCameraActive: Bool,
    delamainTaxiActive: Bool,
    source: CName
  ) -> Void {
    let wasAutodriveEnabled = this.m_autodriveEnabled;
    let wasDelamainTaxiActive = this.m_delamainTaxiActive;

    if Equals(this.m_autodriveEnabled, autodriveEnabled)
      && Equals(this.m_cinematicCameraActive, cinematicCameraActive)
      && Equals(this.m_delamainTaxiActive, delamainTaxiActive) {
      return;
    }

    if autodriveEnabled || delamainTaxiActive {
      this.m_autodriveReleasePending = false;
    } else {
      if wasAutodriveEnabled
        && !wasDelamainTaxiActive
        && this.m_nativePocketRadioRestricted {
        this.m_autodriveReleasePending = true;
      }
    }

    this.m_autodriveEnabled = autodriveEnabled;
    this.m_cinematicCameraActive = cinematicCameraActive;
    this.m_delamainTaxiActive = delamainTaxiActive;

    this.RefreshConversationMute(source);
  }

  private func HasAnyTrackedPocketRadioRestriction() -> Bool {
    return this.m_restrictionSceneTier
      || this.m_restrictionUpperBodyState
      || this.m_restrictionQuestContentLock
      || this.m_restrictionInDaClub
      || this.m_restrictionBlockFastTravel
      || this.m_restrictionVehicleScene
      || this.m_restrictionVehicleBlockPocketRadio
      || this.m_restrictionPhoneCall
      || this.m_restrictionPhoneNoTexting
      || this.m_restrictionPhoneNoCalling
      || this.m_restrictionFastForward
      || this.m_restrictionFastForwardHintActive;
  }

  private func HasBlockingAutonomousRestriction() -> Bool {
    if this.m_restrictionSceneTier
      || this.m_restrictionInDaClub
      || this.m_restrictionBlockFastTravel
      || this.m_restrictionVehicleScene
      || this.m_restrictionVehicleBlockPocketRadio
      || this.m_restrictionPhoneCall
      || this.m_restrictionPhoneNoTexting
      || this.m_restrictionFastForward {
      return true;
    }

    if this.m_delamainTaxiActive {
      return false;
    }

    return this.m_restrictionPhoneNoCalling
      || this.m_restrictionFastForwardHintActive;
  }

  public func IsEffectiveNativePocketRadioRestricted() -> Bool {
    if this.IsPocketRadioAlwaysAvailableEnabled() {
      return false;
    }

    if !this.m_nativePocketRadioRestricted {
      return false;
    }

    if !this.m_autodriveEnabled
      && !this.m_delamainTaxiActive
      && !this.m_autodriveReleasePending {
      return true;
    }

    if !this.HasAnyTrackedPocketRadioRestriction() {
      return !this.m_autodriveReleasePending;
    }

    return this.HasBlockingAutonomousRestriction();
  }

  public func SetPhoneCallConversationRestricted(
    restricted: Bool
  ) -> Void {
    if Equals(
      this.m_conversationPhoneCallRestricted,
      restricted
    ) {
      return;
    }

    this.m_conversationPhoneCallRestricted = restricted;

    if restricted {
      this.m_conversationReleasePending = false;
    } else {
      this.m_conversationReleasePending = true;
    }

    this.RefreshConversationMute(n"conversation-phone-call");
  }

  public func SetSceneTierConversationRestricted(
    restricted: Bool
  ) -> Void {
    if Equals(
      this.m_conversationSceneTierRestricted,
      restricted
    ) {
      return;
    }

    this.m_conversationSceneTierRestricted = restricted;

    if restricted {
      this.m_conversationReleasePending = false;
    } else {
      this.m_conversationReleasePending = true;
    }

    this.RefreshConversationMute(n"conversation-scene-tier");
  }

  public func SetNativePocketRadioRestricted(
    restricted: Bool
  ) -> Void {
    if !restricted {
      this.m_autodriveReleasePending = false;
    }

    if Equals(
      this.m_nativePocketRadioRestricted,
      restricted
    ) {
      this.RefreshConversationMute(
        n"native-pocket-radio-restriction"
      );

      return;
    }

    this.m_nativePocketRadioRestricted = restricted;

    this.RefreshConversationMute(
      n"native-pocket-radio-restriction"
    );
  }

  public func RefreshPocketRadioAvailability(
    source: CName
  ) -> Void {
    let player = GetPlayer(GetGameInstance());
    let pocketRadio: ref<PocketRadio>;

    if !this.IsPocketRadioAlwaysAvailableEnabled()
      && IsDefined(player) {
      pocketRadio = player.GetPocketRadio();

      if IsDefined(pocketRadio) {
        this.m_nativePocketRadioRestricted =
          pocketRadio.IsRestricted();
      }
    }

    this.RefreshConversationMute(source);

    AWRadioMusicDuckBridge.SetRestrictionSuspended(
      this.IsRadioControlRestricted(),
      source
    );

    this.RefreshCombatMusicSuppression(source);
  }

  public func SyncConversationNativeAvailability(
    nativeRestricted: Bool
  ) -> Void {
    if !this.m_conversationReleasePending {
      return;
    }

    if nativeRestricted
      || this.m_conversationPhoneCallRestricted
      || this.m_conversationSceneTierRestricted {
      return;
    }

    this.m_conversationReleasePending = false;
    this.RefreshConversationMute(n"conversation-native-unlock");
  }

  public func SetAudioCombatMixActive(
    active: Bool,
    source: CName
  ) -> Void {
    if Equals(this.m_audioCombatMixActive, active) {
      return;
    }

    this.m_audioCombatMixActive = active;
    this.RefreshCombatMusicSuppression(source);
  }

  public func SetPreventionHeatStage(
    stage: Int32,
    source: CName
  ) -> Void {
    if Equals(this.m_preventionHeatStage, stage) {
      return;
    }

    this.m_preventionHeatStage = stage;

    if stage >= 3 {
      this.m_preventionCombatMusicLatched = true;
    } else {
      if Equals(stage, 0) {
        this.m_preventionCombatMusicLatched = false;

        this.m_audioCombatMixActive = false;
      }
    }

    this.RefreshCombatMusicSuppression(source);
  }

  private func RefreshCombatMusicSuppression(
    source: CName
  ) -> Void {
    let shouldSuppress =
      !this.IsPocketRadioAlwaysAvailableEnabled()
      && (
        this.m_preventionCombatMusicLatched
        || (Equals(this.m_preventionHeatStage, 0)
          && this.m_audioCombatMixActive)
      );

    if Equals(
      this.m_combatMusicSuppressed,
      shouldSuppress
    ) {
      return;
    }

    this.m_combatMusicSuppressed = shouldSuppress;

    AWRadioMusicDuckBridge.SetCombatSuspended(
      shouldSuppress,
      source
    );

    this.StartSafeVolumeFade(source, 5.0);
  }

  private func StartSafeVolumeFade(
    source: CName,
    duration: Float
  ) -> Void {
    let callback: ref<AWRadioVolumeFadeCallback>;
    let delay: Float;
    let step: Int32;
    let steps: Int32 = 20;
    let startVolume: Float;
    let targetVolume: Float;

    if !IsDefined(this.m_currentSound)
      || !IsDefined(this.m_activeStation) {
      return;
    }

    startVolume = ClampF(this.m_outputVolume, 0.0, 2.0);
    targetVolume = this.GetTargetVolume();

    if AbsF(targetVolume - startVolume) < 0.001 {
      return;
    }

    this.m_volumeFadeGeneration += 1;
    step = 1;

    while step <= steps {
      callback = AWRadioVolumeFadeCallback.Create(
        this,
        this.m_volumeFadeGeneration,
        step,
        steps,
        startVolume,
        targetVolume,
        source
      );

      delay = MaxF(duration, 0.0)
        * Cast<Float>(step)
        / Cast<Float>(steps);

      GameInstance
        .GetDelaySystem(GetGameInstance())
        .DelayCallback(callback, delay, false);

      step += 1;
    }
  }

  public func ApplySafeVolumeFadeStep(
    generation: Int32,
    step: Int32,
    steps: Int32,
    startVolume: Float,
    targetVolume: Float,
    source: CName
  ) -> Void {
    let fraction: Float;
    let volume: Float;

    if NotEquals(generation, this.m_volumeFadeGeneration)
      || !IsDefined(this.m_currentSound)
      || steps <= 0 {
      return;
    }

    fraction = ClampF(
      Cast<Float>(step) / Cast<Float>(steps),
      0.0,
      1.0
    );

    volume = ClampF(
      startVolume + (targetVolume - startVolume) * fraction,
      0.0,
      2.0
    );

    this.m_currentSound.SetVolume(
      volume,
      LinearTween.Immediate(0.05)
    );

    this.m_outputVolume = volume;
  }

  private func RefreshConversationMute(
    source: CName
  ) -> Void {
    let shouldMute =
      !this.IsPocketRadioAlwaysAvailableEnabled()
      && (
        this.m_conversationPhoneCallRestricted
        || this.m_conversationSceneTierRestricted
        || this.IsEffectiveNativePocketRadioRestricted()
        || this.m_conversationReleasePending
      );

    if Equals(shouldMute, this.m_conversationMuted) {
      return;
    }

    this.m_conversationMuted = shouldMute;
    this.ApplyActiveVolume(source);

  }

  public func BeginFastTravelHandoff() -> Bool {
    let elapsed: Float;
    let position: Float;
    let track = this.GetCurrentTrack();

    if this.m_loadingScreenMuted
      || !this.IsPlaybackRunning()
      || !IsDefined(track) {
      return false;
    }

    position = this.m_currentSound.Position();

    if position >= 0.0 {
      this.m_loadingScreenPosition = ClampF(
        position,
        0.0,
        track.duration
      );
    } else {
      elapsed = MaxF(
        this.GetPlaybackClock() - this.m_playbackStartedAt,
        0.0
      );

      this.m_loadingScreenPosition = ClampF(
        this.m_playbackAnchor + elapsed,
        0.0,
        track.duration
      );
    }

    this.m_generation += 1;
    this.m_volumeFadeGeneration += 1;

    this.m_currentSound.SetVolume(0.0);
    this.m_currentSound.Stop();
    this.m_currentSound = null;
    this.m_outputVolume = 0.0;
    this.m_loadingScreenMuted = true;
    this.m_loadingScreenSeekPrepared = false;
    this.m_loadingScreenGeneration = this.m_generation;
    this.m_fastTravelSoundDetached = true;

    return true;
  }

  public func MuteForLoadingScreen() -> Bool {
    let elapsed: Float;
    let track = this.GetCurrentTrack();

    if this.m_loadingScreenMuted
      || !this.IsPlaybackRunning()
      || !IsDefined(track) {
      return false;
    }

    elapsed = MaxF(
      this.GetPlaybackClock() - this.m_playbackStartedAt,
      0.0
    );

    this.m_loadingScreenPosition = ClampF(
      this.m_playbackAnchor + elapsed,
      0.0,
      track.duration
    );

    this.m_generation += 1;

    this.m_volumeFadeGeneration += 1;

    this.m_currentSound.SetVolume(
      0.0,
      LinearTween.Immediate(0.05)
    );

    this.m_outputVolume = 0.0;
    this.m_loadingScreenMuted = true;
    this.m_loadingScreenSeekPrepared = false;
    this.m_loadingScreenGeneration = this.m_generation;
    this.m_fastTravelSoundDetached = false;

    return true;
  }

  public func PrepareRestoreAfterLoadingScreen() -> Bool {
    let position = this.m_loadingScreenPosition;
    let settings: ref<AudioSettingsExt>;
    let sound: ref<DynamicSoundEvent>;
    let track = this.GetCurrentTrack();
    let shouldPrepare = this.m_loadingScreenMuted
      && !this.m_loadingScreenSeekPrepared
      && Equals(
        this.m_generation,
        this.m_loadingScreenGeneration
      )
      && (
        this.HasActivePlayback()
        || this.m_fastTravelSoundDetached
      )
      && !this.m_isPaused
      && IsDefined(track);

    if !shouldPrepare {
      this.ClearLoadingScreenMuteState();
      return false;
    }

    if this.m_fastTravelSoundDetached {
      if !this.EnsureSession() {
        this.ClearLoadingScreenMuteState();
        return false;
      }

      settings = new AudioSettingsExt();
      settings.volume = 0.0;
      settings.affectedByTimeDilation = false;

      sound = DynamicSoundEvent.Create(
        track.eventName,
        settings
      );

      if !IsDefined(sound) {
        this.ClearLoadingScreenMuteState();
        return false;
      }

      this.m_currentSound = sound;
      this.m_currentEvent = track.eventName;
      this.m_outputVolume = 0.0;
      this.m_fastTravelSoundDetached = false;

      this.m_player.QueueEvent(sound);
    }

    this.m_currentSound.SeekTo(
      position,
      LinearTween.Immediate(0.0)
    );

    this.m_loadingScreenSeekPrepared = true;

    return true;
  }

  public func CompleteRestoreAfterLoadingScreen() -> Bool {
    let callback: ref<AWRadioTrackEndCallback>;
    let effectiveVolume: Float;
    let position = this.m_loadingScreenPosition;
    let remaining: Float;
    let track = this.GetCurrentTrack();
    let shouldRestore = this.m_loadingScreenMuted
      && this.m_loadingScreenSeekPrepared
      && Equals(
        this.m_generation,
        this.m_loadingScreenGeneration
      )
      && this.HasActivePlayback()
      && !this.m_isPaused
      && IsDefined(track);

    if !shouldRestore {
      this.ClearLoadingScreenMuteState();
      return false;
    }

    remaining = MaxF(
      track.duration - position,
      0.10
    );

    if this.m_conversationMuted
      || this.m_combatMusicSuppressed {
      effectiveVolume = 0.0;
    } else {
      effectiveVolume = this.GetEffectiveVolume();
    }

    this.m_currentSound.SetVolume(
      effectiveVolume,
      LinearTween.Immediate(2.0)
    );

    this.m_outputVolume = effectiveVolume;
    this.m_pausedPosition = position;
    this.m_playbackAnchor = position;
    this.m_playbackStartedAt = this.GetPlaybackClock();

    this.m_generation += 1;

    callback = AWRadioTrackEndCallback.Create(
      this,
      this.m_generation
    );

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(callback, remaining, false);

    this.ClearLoadingScreenMuteState();

    return true;
  }

  private func ClearLoadingScreenMuteState() -> Void {
    this.m_loadingScreenMuted = false;
    this.m_loadingScreenSeekPrepared = false;
    this.m_loadingScreenGeneration = 0;
    this.m_loadingScreenPosition = 0.0;
    this.m_fastTravelSoundDetached = false;
  }

  public func PausePlayback(
    source: CName
  ) -> Bool {
    let elapsed: Float;
    let track = this.GetCurrentTrack();

    if !this.HasActivePlayback()
      || this.m_isPaused
      || !IsDefined(track) {
      return false;
    }

    elapsed = MaxF(
      this.GetPlaybackClock() - this.m_playbackStartedAt,
      0.0
    );

    this.m_pausedPosition = ClampF(
      this.m_playbackAnchor + elapsed,
      0.0,
      track.duration
    );

    this.m_generation += 1;
    this.m_manualPauseGeneration += 1;
    this.m_volumeFadeGeneration += 1;
    this.m_isPaused = true;

    this.m_currentSound.SetVolume(
      0.0,
      LinearTween.Immediate(0.0)
    );
    this.m_outputVolume = 0.0;

    this.m_currentSound.Pause(
      LinearTween.Immediate(0.05)
    );

    return true;
  }

  public func ResumePlayback(
    source: CName
  ) -> Bool {
    let callback: ref<AWRadioTrackEndCallback>;
    let remaining: Float;
    let track = this.GetCurrentTrack();

    if !this.HasActivePlayback()
      || !this.m_isPaused
      || !IsDefined(track) {
      return false;
    }

    remaining = MaxF(
      track.duration - this.m_pausedPosition,
      0.10
    );

    this.m_manualPauseGeneration += 1;
    this.m_isPaused = false;

    this.m_currentSound.Resume(
      LinearTween.Immediate(0.05)
    );

    this.ApplyActiveVolumeTween(
      source,
      0.05
    );

    this.m_playbackAnchor = this.m_pausedPosition;
    this.m_playbackStartedAt = this.GetPlaybackClock();

    this.m_generation += 1;

    callback = AWRadioTrackEndCallback.Create(
      this,
      this.m_generation
    );

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(callback, remaining, false);

    return true;
  }

  public func PrepareManualPauseForMenu(
    source: CName
  ) -> Void {
    if !this.HasActivePlayback()
      || !this.m_isPaused {
      return;
    }

    this.m_volumeFadeGeneration += 1;
    this.m_currentSound.SetVolume(
      0.0,
      LinearTween.Immediate(0.0)
    );
    this.m_outputVolume = 0.0;
  }

  public func ScheduleManualPauseReassertAfterMenu(
    delay: Float,
    source: CName
  ) -> Void {
    let callback: ref<AWRadioMenuPauseReassertCallback>;

    if !this.HasActivePlayback()
      || !this.m_isPaused {
      return;
    }

    callback = AWRadioMenuPauseReassertCallback.Create(
      this,
      this.m_manualPauseGeneration,
      source
    );

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(
        callback,
        MaxF(delay, 0.0),
        false
      );
  }

  public func ReassertManualPauseAfterMenu(
    pauseGeneration: Int32,
    source: CName
  ) -> Void {
    if NotEquals(
        pauseGeneration,
        this.m_manualPauseGeneration
      )
      || !this.HasActivePlayback()
      || !this.m_isPaused {
      return;
    }

    this.m_volumeFadeGeneration += 1;

    this.m_currentSound.SetVolume(
      0.0,
      LinearTween.Immediate(0.0)
    );
    this.m_currentSound.SeekTo(
      this.m_pausedPosition,
      LinearTween.Immediate(0.0)
    );
    this.m_currentSound.Pause(
      LinearTween.Immediate(0.0)
    );
    this.m_outputVolume = 0.0;
  }

  private func GetPlaybackClock() -> Float {
    return EngineTime.ToFloat(
      GameInstance.GetSimTime(
        GetGameInstance()
      )
    );
  }

  public func SetRadioportVolume(
    percent: Float
  ) -> Void {
    this.SetSharedRadioVolume(
      percent,
      n"RadioportVolume"
    );
  }

  public func SetCarRadioVolume(
    percent: Float
  ) -> Void {
    this.SetSharedRadioVolume(
      percent,
      n"CarRadioVolume"
    );
  }

  public func SetSharedRadioVolume(
    percent: Float,
    source: CName
  ) -> Void {
    this.m_sharedRadioVolume = ClampF(
      percent / 100.0,
      0.0,
      1.0
    );

    this.ApplyActiveVolume(source);
  }

  public func RefreshActiveVolume(
    source: CName
  ) -> Void {
    this.ApplyActiveVolume(source);
  }

  private func SyncVolumeSettings() -> Void {
    let group: ref<ConfigGroup>;
    let settings = GameInstance.GetSettingsSystem(
      GetGameInstance()
    );
    let variable: ref<ConfigVarInt>;
    let variableName: CName;

    if !IsDefined(settings) {
      return;
    }

    group = settings.GetGroup(
      n"/audio/volume"
    );

    if !IsDefined(group) {
      return;
    }

    if this.IsPlayerMounted() {
      variableName = n"CarRadioVolume";
    } else {
      variableName = n"RadioportVolume";
    }

    variable = group.GetVar(
      variableName
    ) as ConfigVarInt;

    if !IsDefined(variable) {
      return;
    }

    this.m_sharedRadioVolume = ClampF(
      Cast<Float>(
        variable.GetValue()
      ) / 100.0,
      0.0,
      1.0
    );

    this.ApplyActiveVolume(
      n"settings-sync"
    );
  }

  private func ApplyActiveVolume(
    source: CName
  ) -> Void {
    this.ApplyActiveVolumeTween(
      source,
      0.05
    );
  }

  private func ApplyActiveVolumeTween(
    source: CName,
    duration: Float
  ) -> Void {
    let effectiveVolume: Float;

    if !IsDefined(this.m_currentSound)
      || !IsDefined(this.m_activeStation) {
      return;
    }

    effectiveVolume = this.GetTargetVolume();
    this.m_volumeFadeGeneration += 1;

    this.m_currentSound.SetVolume(
      effectiveVolume,
      LinearTween.Immediate(
        MaxF(duration, 0.0)
      )
    );

    this.m_outputVolume = effectiveVolume;
  }

  private func IsPlayerMounted() -> Bool {
    let player = GetPlayer(
      GetGameInstance()
    );

    return IsDefined(player)
      && IsDefined(
        GetMountedVehicle(player)
      );
  }

  private func GetTargetVolume() -> Float {
    if this.m_isPaused
      || this.m_timeSkipMenuActive
      || this.m_photoModeActive
      || this.m_loadingScreenMuted
      || this.m_conversationMuted
      || this.m_combatMusicSuppressed {
      return 0.0;
    }

    return this.GetEffectiveVolume();
  }

  private func GetEffectiveVolume() -> Float {
    if !IsDefined(this.m_activeStation) {
      return 0.0;
    }

    return ClampF(
      this.m_activeStation.gain
        * this.m_sharedRadioVolume,
      0.0,
      2.0
    );
  }

  public func OnTrackElapsed(generation: Int32) -> Void {
    if NotEquals(generation, this.m_generation) {
      return;
    }

    if !IsDefined(this.m_activeStation)
      || this.m_isPaused {
      return;
    }

    if this.m_repeatCurrentTrack {
      this.PlayCurrentTrack();
      return;
    }

    this.AdvanceToNextTrack(n"natural-track-end");
  }

  private func AdvanceToNextTrack(source: CName) -> Bool {
    let previousTrackIndex: Int32;

    if !IsDefined(this.m_activeStation)
      || Equals(ArraySize(this.m_trackOrder), 0) {
      return false;
    }

    previousTrackIndex = this.m_trackIndex;
    this.m_trackOrderPosition += 1;

    if this.m_trackOrderPosition >= ArraySize(this.m_trackOrder) {
      this.BuildShuffledTrackOrder(previousTrackIndex);
    } else {
      this.m_trackIndex = this.m_trackOrder[
        this.m_trackOrderPosition
      ];
    }

    this.PlayCurrentTrack();
    return true;
  }

  private func EnsureSession() -> Bool {
    if this.m_sessionReady && IsDefined(this.m_player) {
      return true;
    }

    this.m_player = GetPlayer(GetGameInstance());
    this.m_sessionReady = IsDefined(this.m_player);

    return this.m_sessionReady;
  }

  private func StartStation(
    station: ref<AWRadioStationDefinition>
  ) -> Void {
    this.StopInternal(false);

    this.m_activeStation = station;
    this.BuildShuffledTrackOrder(-1);
    this.m_generation += 1;

    this.PlayCurrentTrack();
  }

  private func BuildShuffledTrackOrder(
    previousTrackIndex: Int32
  ) -> Void {
    let count: Int32;
    let i: Int32;
    let randomIndex: Int32;
    let temporaryIndex: Int32;

    ArrayClear(this.m_trackOrder);
    this.m_trackOrderPosition = 0;
    this.m_trackIndex = 0;

    if !IsDefined(this.m_activeStation) {
      return;
    }

    count = ArraySize(this.m_activeStation.tracks);
    i = 0;

    while i < count {
      ArrayPush(this.m_trackOrder, i);
      i += 1;
    }

    i = count - 1;

    while i > 0 {
      randomIndex = RandRange(0, i);
      temporaryIndex = this.m_trackOrder[i];
      this.m_trackOrder[i] = this.m_trackOrder[randomIndex];
      this.m_trackOrder[randomIndex] = temporaryIndex;
      i -= 1;
    }

    if count > 1
      && previousTrackIndex >= 0
      && Equals(this.m_trackOrder[0], previousTrackIndex) {
      temporaryIndex = this.m_trackOrder[0];
      this.m_trackOrder[0] = this.m_trackOrder[1];
      this.m_trackOrder[1] = temporaryIndex;
    }

    if count > 0 {
      this.m_trackIndex = this.m_trackOrder[0];
    }
  }

  private func PlayCurrentTrack() -> Void {
    let callback: ref<AWRadioTrackEndCallback>;
    let settings: ref<AudioSettingsExt>;
    let sound: ref<DynamicSoundEvent>;
    let track = this.GetCurrentTrack();

    if !this.EnsureSession() || !IsDefined(track) {
      return;
    }

    if IsDefined(this.m_currentSound) {
      this.m_currentSound.Stop(
        LinearTween.Immediate(0.05)
      );
    }

    settings = new AudioSettingsExt();
    settings.volume = this.GetTargetVolume();
    settings.affectedByTimeDilation = false;

    sound = DynamicSoundEvent.Create(
      track.eventName,
      settings
    );

    if !IsDefined(sound) {
      return;
    }

    this.m_volumeFadeGeneration += 1;
    this.m_currentSound = sound;
    this.m_currentEvent = track.eventName;
    this.m_outputVolume = settings.volume;
    this.m_isPaused = false;
    this.m_pausedPosition = 0.0;
    this.m_playbackAnchor = 0.0;
    this.m_playbackStartedAt = this.GetPlaybackClock();

    this.m_player.QueueEvent(sound);

    this.m_generation += 1;

    callback = AWRadioTrackEndCallback.Create(
      this,
      this.m_generation
    );

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(callback, track.duration, false);

    this.NotifyTrackChanged();
  }

  private func NotifyTrackChanged() -> Void {
    let event = new VehicleRadioSongChanged();

    GameInstance
      .GetUISystem(GetGameInstance())
      .QueueEvent(event);
  }

  private func GetCurrentTrack() -> ref<AWRadioTrackDefinition> {
    if !IsDefined(this.m_activeStation) {
      return null;
    }

    if Equals(ArraySize(this.m_activeStation.tracks), 0) {
      return null;
    }

    if this.m_trackIndex < 0
      || this.m_trackIndex >= ArraySize(this.m_activeStation.tracks) {
      this.m_trackIndex = 0;
    }

    return this.m_activeStation.tracks[this.m_trackIndex];
  }

  private func Stop() -> Void {
    this.StopInternal(true);
  }

  private func StopInternal(
    resetContext: Bool
  ) -> Void {
    this.m_generation += 1;

    if IsDefined(this.m_currentSound) {
      this.m_currentSound.Stop(
        LinearTween.Immediate(0.05)
      );
    }

    this.ResetPlaybackState();

    if resetContext {
      this.ResetContextPlaybackState();
    }
  }

  private func ResetConversationState() -> Void {
    this.m_conversationPhoneCallRestricted = false;
    this.m_conversationSceneTierRestricted = false;
    this.m_nativePocketRadioRestricted = false;
    this.m_autodriveEnabled = false;
    this.m_cinematicCameraActive = false;
    this.m_delamainTaxiActive = false;
    this.m_autodriveReleasePending = false;
    this.m_restrictionSceneTier = false;
    this.m_restrictionUpperBodyState = false;
    this.m_restrictionQuestContentLock = false;
    this.m_restrictionInDaClub = false;
    this.m_restrictionBlockFastTravel = false;
    this.m_restrictionVehicleScene = false;
    this.m_restrictionVehicleBlockPocketRadio = false;
    this.m_restrictionPhoneCall = false;
    this.m_restrictionPhoneNoTexting = false;
    this.m_restrictionPhoneNoCalling = false;
    this.m_restrictionFastForward = false;
    this.m_restrictionFastForwardHintActive = false;
    this.m_conversationReleasePending = false;
    this.m_conversationMuted = false;
  }

  private func ResetCombatState() -> Void {
    this.m_audioCombatMixActive = false;
    this.m_preventionHeatStage = 0;
    this.m_preventionCombatMusicLatched = false;
    this.m_combatMusicSuppressed = false;
  }

  private func ResetTrackControlState() -> Void {
    this.m_repeatCurrentTrack = false;
  }

  private func ResetContextPlaybackState() -> Void {
    this.m_onFootPlaybackEnabled = false;
    this.m_vehiclePlaybackEnabled = false;
    this.m_vehiclePlaybackInitialized = false;
  }
  private func ResetPlaybackState() -> Void {
    this.m_activeStation = null;
    this.m_trackIndex = 0;
    ArrayClear(this.m_trackOrder);
    this.m_trackOrderPosition = 0;
    this.m_volumeFadeGeneration += 1;
    this.m_currentEvent = n"";
    this.m_currentSound = null;
    this.m_outputVolume = 0.0;
    this.m_isPaused = false;
    this.m_manualPauseGeneration += 1;
    this.m_timeSkipMenuActive = false;
    this.m_timeSkipMenuAutoPaused = false;
    this.m_photoModeActive = false;
    this.m_photoModeAutoPaused = false;
    this.m_pausedPosition = 0.0;
    this.m_playbackAnchor = 0.0;
    this.m_playbackStartedAt = 0.0;
    this.m_loadingScreenMuted = false;
    this.m_loadingScreenGeneration = 0;
    this.m_loadingScreenPosition = 0.0;
    this.m_loadingScreenSeekPrepared = false;
    this.m_fastTravelSoundDetached = false;
  }
}
