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

public class AWRadioService extends ScriptableService {
  private let m_callbackSystem: wref<CallbackSystem>;
  private let m_player: wref<PlayerPuppet>;

  private let m_stations: array<ref<AWRadioStationDefinition>>;
  private let m_activeStation: ref<AWRadioStationDefinition>;
  private let m_trackIndex: Int32;
  private let m_trackOrder: array<Int32>;
  private let m_trackOrderPosition: Int32;
  private let m_currentEvent: CName;
  private let m_currentSound: ref<DynamicSoundEvent>;
  private let m_generation: Int32;
  private let m_repeatCurrentTrack: Bool;
  private let m_isPaused: Bool;
  private let m_pausedPosition: Float;
  private let m_playbackAnchor: Float;
  private let m_playbackStartedAt: Float;
  private let m_sessionReady: Bool;
  private let m_loadingScreenMuted: Bool;
  private let m_loadingScreenGeneration: Int32;
  private let m_loadingScreenPosition: Float;
  private let m_loadingScreenSeekPrepared: Bool;
  private let m_conversationPhoneCallRestricted: Bool;
  private let m_conversationSceneTierRestricted: Bool;
  private let m_conversationReleasePending: Bool;
  private let m_conversationMuted: Bool;
  private let m_audioCombatMixActive: Bool;
  private let m_preventionHeatStage: Int32;
  private let m_preventionCombatMusicLatched: Bool;
  private let m_combatMusicSuppressed: Bool;
  private let m_volumeFadeGeneration: Int32;
  private let m_outputVolume: Float;
  // Radioport and vehicle controls both update this one shared value.
  // Mounting changes UI context only; it must not change custom-radio volume.
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

    FTLog("[AWRadioFramework] service loaded");
  }

  private cb func OnSessionReady(event: ref<GameSessionEvent>) -> Void {
    this.m_player = GetPlayer(GetGameInstance());
    this.m_sessionReady = IsDefined(this.m_player);

    this.ResetConversationState();
    this.ResetCombatState();
    this.ResetPlaybackState();
    this.ResetTrackControlState();
    this.SyncVolumeSettings();

    FTLog("[AWRadioFramework] session ready");
  }

  private cb func OnSessionBeforeEnd(event: ref<GameSessionEvent>) -> Void {
    this.Stop();
    this.ResetConversationState();
    this.ResetCombatState();
    this.ResetTrackControlState();

    this.m_sessionReady = false;
    this.m_player = null;

    FTLog("[AWRadioFramework] session ending");
  }

  // Public station-pack API.
  //
  // Station packs call this from their own Codeware ScriptableService during
  // OnInitialize. Registration is global for the game launch and is not tied
  // to a save/session.
  public func RegisterStation(
    station: ref<AWRadioStationDefinition>
  ) -> Bool {
    let existing: ref<AWRadioStationDefinition>;

    if !IsDefined(station) {
      return false;
    }

    if station.index < 0 || Equals(ArraySize(station.tracks), 0) {
      FTLog("[AWRadioFramework] rejected incomplete station");
      return false;
    }

    existing = this.FindStationByIndex(station.index);

    if IsDefined(existing) {
      if Equals(existing.recordID, station.recordID) {
        return true;
      }

      FTLog(s"[AWRadioFramework] duplicate station index \(station.index)");
      return false;
    }

    if IsDefined(this.FindStationByRecord(station.recordID)) {
      FTLog(s"[AWRadioFramework] duplicate station record \(station.recordID)");
      return false;
    }

    ArrayPush(this.m_stations, station);

    FTLog(s"[AWRadioFramework] registered station index \(station.index)");
    return true;
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

  // Called by the vanilla radio-event integration.
  //
  // Returns true when the event belongs to this framework and must not be
  // passed to the native receiver.
  public func HandleRadioEvent(
    toggle: Bool,
    setStation: Bool,
    stationIndex: Int32
  ) -> Bool {
    let station = this.FindStationByIndex(stationIndex);

    if !IsDefined(station) {
      return false;
    }

    if !this.EnsureSession() {
      return true;
    }

    if !toggle {
      this.Stop();
      return true;
    }

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

  // Called before a normal/vanilla station event is allowed through.
  public func ReleaseForNativeRadio() -> Void {
    if IsDefined(this.m_activeStation) {
      FTLog(
        "[AWRadioFramework] releasing custom station for native radio"
      );

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

  public func IsRepeatCurrentTrackEnabled() -> Bool {
    return this.m_repeatCurrentTrack;
  }

  public func ToggleRepeatCurrentTrack(source: CName) -> Bool {
    if !this.HasActivePlayback()
      || this.m_loadingScreenMuted {
      return false;
    }

    this.m_repeatCurrentTrack = !this.m_repeatCurrentTrack;

    FTLog(
      s"[AWRadioFramework] repeat-current-track=\(this.m_repeatCurrentTrack) source=\(source)"
    );

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

    FTLog(
      s"[AWRadioFramework] skipped to track \(this.GetCurrentTrackTitle()) source=\(source)"
    );

    return true;
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

    FTLog(
      s"[AWRadioFramework] conversation PhoneCall restriction=\(restricted)"
    );

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

    FTLog(
      s"[AWRadioFramework] conversation SceneTier restriction=\(restricted)"
    );

    this.RefreshConversationMute(n"conversation-scene-tier");
  }

  public func SyncConversationNativeAvailability(
    nativeRestricted: Bool
  ) -> Void {
    if !this.m_conversationReleasePending {
      return;
    }

    FTLog(
      s"[AWRadioFramework] conversation native availability restricted=\(nativeRestricted)"
    );

    if nativeRestricted
      || this.m_conversationPhoneCallRestricted
      || this.m_conversationSceneTierRestricted {
      return;
    }

    this.m_conversationReleasePending = false;
    this.RefreshConversationMute(n"conversation-native-unlock");
  }

  public func IsConversationMuted() -> Bool {
    return this.m_conversationMuted;
  }

  // The audio system owns the ordinary combat mix transition. Prevention
  // encounters are special: the combat mix can toggle at one or two stars
  // while vanilla radio keeps playing. For those encounters, suppression is
  // latched only when the prevention heat reaches stage 3, then held until
  // the heat fully returns to zero.
  public func SetAudioCombatMixActive(
    active: Bool,
    source: CName
  ) -> Void {
    if Equals(this.m_audioCombatMixActive, active) {
      return;
    }

    this.m_audioCombatMixActive = active;
    this.RefreshCombatMusicSuppression(source);

    FTLog(
      s"[AWRadioFramework] combat audio mix active=\(active) heat=\(this.m_preventionHeatStage) source=\(source)"
    );
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

        // Prevention can leave the scripted combat-mix flag stale while its
        // own music unwinds. Heat zero is the authoritative end of that
        // encounter, so do not let the stale flag keep custom radio muted.
        this.m_audioCombatMixActive = false;
      }
    }

    this.RefreshCombatMusicSuppression(source);

    FTLog(
      s"[AWRadioFramework] prevention heat stage=\(stage) combat-music-latched=\(this.m_preventionCombatMusicLatched) source=\(source)"
    );
  }

  public func IsCombatMusicSuppressed() -> Bool {
    return this.m_combatMusicSuppressed;
  }

  private func RefreshCombatMusicSuppression(
    source: CName
  ) -> Void {
    let shouldSuppress = this.m_preventionCombatMusicLatched
      || (Equals(this.m_preventionHeatStage, 0)
        && this.m_audioCombatMixActive);

    if Equals(
      this.m_combatMusicSuppressed,
      shouldSuppress
    ) {
      return;
    }

    this.m_combatMusicSuppressed = shouldSuppress;
    this.StartSafeVolumeFade(source, 5.0);

    FTLog(
      s"[AWRadioFramework] combat music suppression active=\(shouldSuppress) source=\(source) fade=5.000000s"
    );
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

    FTLog(
      s"[AWRadioFramework] scheduled safe volume fade source=\(source) start=\(startVolume) target=\(targetVolume) duration=\(duration)s generation=\(this.m_volumeFadeGeneration)"
    );
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

    if Equals(step, steps) {
      FTLog(
        s"[AWRadioFramework] completed safe volume fade source=\(source) volume=\(volume) generation=\(generation)"
      );
    }
  }

  private func RefreshConversationMute(
    source: CName
  ) -> Void {
    let shouldMute =
      this.m_conversationPhoneCallRestricted
      || this.m_conversationSceneTierRestricted
      || this.m_conversationReleasePending;

    if Equals(shouldMute, this.m_conversationMuted) {
      return;
    }

    this.m_conversationMuted = shouldMute;
    this.ApplyActiveVolume(source);

    if shouldMute {
      FTLog(
        s"[AWRadioFramework] conversation mute engaged source=\(source)"
      );
    } else {
      FTLog(
        s"[AWRadioFramework] conversation mute released source=\(source)"
      );
    }
  }

  // Loading-screen audio suppression must not query Audioware Position() while
  // the map has disconnected the dynamic-event command channel. The framework
  // already owns an accurate simulation-time playback clock, which naturally
  // stops while menus suppress the radio. Capture that logical position, mute
  // the retained event, then seek while still silent after loading. A second
  // one-shot callback restores volume only after the seek has had time to land.
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

    // Invalidate the existing track-end callback while the retained event is
    // silent underneath the loading presentation.
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

    FTLog(
      s"[AWRadioFramework] loading mute armed event=\(this.m_currentEvent) simulated-position=\(this.m_loadingScreenPosition)s generation=\(this.m_loadingScreenGeneration)"
    );

    return true;
  }

  public func PrepareRestoreAfterLoadingScreen() -> Bool {
    let position = this.m_loadingScreenPosition;
    let track = this.GetCurrentTrack();
    let shouldPrepare = this.m_loadingScreenMuted
      && !this.m_loadingScreenSeekPrepared
      && Equals(
        this.m_generation,
        this.m_loadingScreenGeneration
      )
      && this.HasActivePlayback()
      && !this.m_isPaused
      && IsDefined(track);

    if !shouldPrepare {
      this.ClearLoadingScreenMuteState();
      return false;
    }

    // Keep the event at volume zero while the asynchronous seek command is
    // delivered. Volume restoration happens in a separate one-shot callback.
    this.m_currentSound.SeekTo(
      position,
      LinearTween.Immediate(0.0)
    );

    this.m_loadingScreenSeekPrepared = true;

    FTLog(
      s"[AWRadioFramework] prepared silent loading restore event=\(this.m_currentEvent) position=\(position)s"
    );

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
      LinearTween.Immediate(0.05)
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

    FTLog(
      s"[AWRadioFramework] loading mute released event=\(this.m_currentEvent) restored-position=\(position)s remaining=\(remaining)s effective-volume=\(effectiveVolume)"
    );

    return true;
  }

  private func ClearLoadingScreenMuteState() -> Void {
    this.m_loadingScreenMuted = false;
    this.m_loadingScreenSeekPrepared = false;
    this.m_loadingScreenGeneration = 0;
    this.m_loadingScreenPosition = 0.0;
  }

  public func TogglePlaybackPause(
    source: CName
  ) -> Bool {
    if this.m_isPaused {
      return this.ResumePlayback(source);
    }

    return this.PausePlayback(source);
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

    // Invalidate the existing track-end callback.
    this.m_generation += 1;

    this.m_currentSound.Pause(
      LinearTween.Immediate(0.05)
    );

    this.m_isPaused = true;

    FTLog(
      s"[AWRadioFramework] paused \(this.m_currentEvent) at \(this.m_pausedPosition)s source=\(source)"
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

    this.m_currentSound.Resume(
      LinearTween.Immediate(0.05)
    );

    this.m_isPaused = false;
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

    FTLog(
      s"[AWRadioFramework] resumed \(this.m_currentEvent) at \(this.m_pausedPosition)s remaining=\(remaining)s source=\(source)"
    );

    return true;
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

  public func GetRadioportVolume() -> Float {
    return this.m_sharedRadioVolume;
  }

  public func GetCarRadioVolume() -> Float {
    return this.m_sharedRadioVolume;
  }

  public func GetSharedRadioVolume() -> Float {
    return this.m_sharedRadioVolume;
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

    // On session start, use the setting belonging to the player's current
    // context as the initial shared value. After that, whichever control is
    // changed last updates the same shared value through the listener.
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

    FTLog(
      s"[AWRadioFramework] initialized shared radio volume \(variable.GetValue())% from \(variableName)"
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
    let percent = Cast<Int32>(
      this.m_sharedRadioVolume * 100.0
    );

    if !IsDefined(this.m_currentSound)
      || !IsDefined(this.m_activeStation) {
      FTLog(
        s"[AWRadioFramework] stored shared radio volume \(percent)% source=\(source)"
      );

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

    FTLog(
      s"[AWRadioFramework] applied shared radio volume \(percent)% effective=\(effectiveVolume) source=\(source) fade=\(duration)s"
    );
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
    if this.m_loadingScreenMuted
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
      FTLog(
        s"[AWRadioFramework] repeating track \(this.GetCurrentTrackTitle())"
      );

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

      FTLog(
        s"[AWRadioFramework] reshuffled station index \(this.m_activeStation.index) next-track-index=\(this.m_trackIndex) source=\(source)"
      );
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
    this.Stop();

    FTLog(
      s"[AWRadioFramework] starting station index \(station.index)"
    );

    this.m_activeStation = station;
    this.BuildShuffledTrackOrder(-1);
    this.m_generation += 1;

    FTLog(
      s"[AWRadioFramework] shuffled station index \(station.index) tracks=\(ArraySize(station.tracks)) first-track-index=\(this.m_trackIndex)"
    );

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
      FTLog(
        s"[AWRadioFramework] failed to create dynamic sound \(track.eventName)"
      );

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

    FTLog(
      s"[AWRadioFramework] playing dynamic \(track.eventName) volume=\(settings.volume)"
    );

    this.NotifyTrackChanged();
  }

  private func NotifyTrackChanged() -> Void {
    let event = new VehicleRadioSongChanged();

    GameInstance
      .GetUISystem(GetGameInstance())
      .QueueEvent(event);

    FTLog("[AWRadioFramework] queued track UI refresh");
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
    let eventName = this.m_currentEvent;

    this.m_generation += 1;

    if IsDefined(this.m_currentSound) {
      FTLog(
        s"[AWRadioFramework] stopping dynamic Audioware event \(eventName)"
      );

      this.m_currentSound.Stop(
        LinearTween.Immediate(0.05)
      );
    }

    this.ResetPlaybackState();
  }

  private func ResetConversationState() -> Void {
    this.m_conversationPhoneCallRestricted = false;
    this.m_conversationSceneTierRestricted = false;
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
    this.m_pausedPosition = 0.0;
    this.m_playbackAnchor = 0.0;
    this.m_playbackStartedAt = 0.0;
    this.m_loadingScreenMuted = false;
    this.m_loadingScreenGeneration = 0;
    this.m_loadingScreenPosition = 0.0;
    this.m_loadingScreenSeekPrepared = false;
  }
}
