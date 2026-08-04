module AWRadioFramework

public class AWRadioMusicDuckRefreshCallback extends DelayCallback {
  private let m_generation: Int32;
  private let m_source: CName;

  public static func Create(
    generation: Int32,
    source: CName
  ) -> ref<AWRadioMusicDuckRefreshCallback> {
    let callback = new AWRadioMusicDuckRefreshCallback();

    callback.m_generation = generation;
    callback.m_source = source;

    return callback;
  }

  public func Call() -> Void {
    let system = AWRadioMusicDuckSystem.Get();

    if IsDefined(system) {
      system.RefreshCurrentRadioState(
        this.m_generation,
        this.m_source
      );
    }
  }
}

public class AWRadioMusicVolumeListener extends ConfigVarListener {
  private let m_owner: wref<AWRadioMusicDuckSystem>;

  public func Initialize(
    owner: wref<AWRadioMusicDuckSystem>
  ) -> Void {
    this.m_owner = owner;
  }

  public func Start() -> Void {
    this.Register(n"/audio/volume");
  }

  protected cb func OnVarModified(
    groupPath: CName,
    varName: CName,
    varType: ConfigVarType,
    reason: ConfigChangeReason
  ) -> Void {
    if NotEquals(groupPath, n"/audio/volume")
      || NotEquals(varName, n"MusicVolume") {
      return;
    }

    if IsDefined(this.m_owner) {
      this.m_owner.OnMusicVolumeChanged(reason);
    }
  }
}

public class AWRadioMusicDuckSystem extends ScriptableSystem {
  private let m_callbackSystem: wref<CallbackSystem>;
  private let m_listener: ref<AWRadioMusicVolumeListener>;
  private let m_player: wref<PlayerPuppet>;

  private let m_gameplaySession: Bool;
  private let m_radioPlaying: Bool;
  private let m_loadingSuspended: Bool;
  private let m_restrictionSuspended: Bool;
  private let m_combatSuspended: Bool;

  private let m_isDucked: Bool;
  private let m_hasSavedMusicVolume: Bool;
  private let m_savedMusicVolume: Int32;
  private let m_internalWrite: Bool;
  private let m_generation: Int32;

  public static func Get() -> ref<AWRadioMusicDuckSystem> {
    return GameInstance
      .GetScriptableSystemsContainer(GetGameInstance())
      .Get(
        n"AWRadioFramework.AWRadioMusicDuckSystem"
      ) as AWRadioMusicDuckSystem;
  }

  private func OnAttach() -> Void {
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

    this.m_listener = new AWRadioMusicVolumeListener();
    this.m_listener.Initialize(this);
    this.m_listener.Start();
  }

  private func OnDetach() -> Void {
    this.RestoreMusicVolume(n"system-detach");

    this.m_generation += 1;
    this.m_gameplaySession = false;
    this.m_radioPlaying = false;
    this.m_loadingSuspended = false;
    this.m_restrictionSuspended = false;
    this.m_combatSuspended = false;
    this.m_player = null;
    this.m_listener = null;
    this.m_callbackSystem = null;
  }

  private cb func OnSessionReady(
    event: ref<GameSessionEvent>
  ) -> Void {
    this.RestoreMusicVolume(n"session-ready-safety");

    this.m_generation += 1;
    this.m_radioPlaying = false;
    this.m_loadingSuspended = false;
    this.m_restrictionSuspended = false;
    this.m_combatSuspended = false;
    this.m_player = null;

    if !IsDefined(event) || event.IsPreGame() {
      this.m_gameplaySession = false;

      return;
    }

    this.m_gameplaySession = true;
    this.m_player = GetPlayer(this.GetGameInstance());

    if !IsDefined(this.m_player) {
      this.ScheduleRefresh(
        0.50,
        this.m_generation,
        n"session-ready-player-retry"
      );

      return;
    }

    if this.IsFeatureEnabled() {
      this.CaptureCurrentMusicVolume(n"gameplay-session-ready");

      this.ScheduleRefresh(
        1.00,
        this.m_generation,
        n"gameplay-session-ready"
      );
    }
  }

  private cb func OnSessionBeforeEnd(
    event: ref<GameSessionEvent>
  ) -> Void {
    this.RestoreMusicVolume(n"session-before-end");

    this.m_generation += 1;
    this.m_gameplaySession = false;
    this.m_radioPlaying = false;
    this.m_loadingSuspended = false;
    this.m_restrictionSuspended = false;
    this.m_combatSuspended = false;
    this.m_player = null;
  }

  public func OnFeatureSettingChanged(
    enabled: Bool,
    source: CName
  ) -> Void {
    if !enabled {
      this.RestoreMusicVolume(source);
      return;
    }

    if this.m_gameplaySession {
      this.RefreshCurrentRadioState(
        this.m_generation,
        source
      );
    }
  }

  public func SetRadioPlaying(
    playing: Bool,
    source: CName
  ) -> Void {
    if !this.m_gameplaySession {
      return;
    }

    this.m_radioPlaying = playing;

    this.Refresh(source);
  }

  public func SetLoadingSuspended(
    suspended: Bool,
    source: CName
  ) -> Void {
    if !this.m_gameplaySession {
      return;
    }

    this.m_loadingSuspended = suspended;

    if !suspended {
      this.RefreshCurrentRadioState(
        this.m_generation,
        source
      );
    } else {
      this.Refresh(source);
    }
  }

  public func SetRestrictionSuspended(
    suspended: Bool,
    source: CName
  ) -> Void {
    if !this.m_gameplaySession {
      return;
    }

    this.m_restrictionSuspended = suspended;

    if !suspended {
      this.RefreshCurrentRadioState(
        this.m_generation,
        source
      );
    } else {
      this.Refresh(source);
    }
  }

  public func SetCombatSuspended(
    suspended: Bool,
    source: CName
  ) -> Void {
    if !this.m_gameplaySession {
      return;
    }

    this.m_combatSuspended = suspended;

    if !suspended {
      this.RefreshCurrentRadioState(
        this.m_generation,
        source
      );
    } else {
      this.Refresh(source);
    }
  }

  public func RefreshCurrentRadioState(
    generation: Int32,
    source: CName
  ) -> Void {
    if NotEquals(generation, this.m_generation)
      || !this.m_gameplaySession {
      return;
    }

    this.m_player = GetPlayer(this.GetGameInstance());

    if !IsDefined(this.m_player) {
      return;
    }

    AWRadioMusicDuckBridge.RefreshCurrentRadioState(source);
  }

  public func OnMusicVolumeChanged(
    reason: ConfigChangeReason
  ) -> Void {
    let value: Int32;
    let variable: ref<ConfigVarInt>;

    if this.m_internalWrite
      || !this.CanUseGameplayAudio() {
      return;
    }

    variable = this.GetMusicVolumeSetting();

    if !IsDefined(variable) {
      return;
    }

    value = variable.GetValue();

    if this.m_isDucked {
      if value > 0 {
        this.m_savedMusicVolume = value;
        this.m_hasSavedMusicVolume = true;

        this.WriteMusicVolume(
          variable,
          0,
          n"user-volume-change-reduck"
        );
      }

      return;
    }

    this.m_savedMusicVolume = value;
    this.m_hasSavedMusicVolume = true;
  }

  private func ScheduleRefresh(
    delay: Float,
    generation: Int32,
    source: CName
  ) -> Void {
    let callback = AWRadioMusicDuckRefreshCallback.Create(
      generation,
      source
    );

    GameInstance
      .GetDelaySystem(this.GetGameInstance())
      .DelayCallback(
        callback,
        delay,
        false
      );
  }

  private func CanUseGameplayAudio() -> Bool {
    return this.m_gameplaySession
      && IsDefined(this.m_player)
      && IsDefined(GetPlayer(this.GetGameInstance()));
  }

  private func Refresh(
    source: CName
  ) -> Void {
    let shouldDuck = this.IsFeatureEnabled()
      && this.CanUseGameplayAudio()
      && this.m_radioPlaying
      && !this.m_loadingSuspended
      && !this.m_restrictionSuspended
      && !this.m_combatSuspended;

    if shouldDuck {
      this.DuckMusicVolume(source);
    } else {
      this.RestoreMusicVolume(source);
    }
  }

  private func IsFeatureEnabled() -> Bool {
    let settings = AWRadioFrameworkSettings.Get();

    if !IsDefined(settings) {
      return true;
    }

    return settings.IsMusicDuckEnabled();
  }

  private func CaptureCurrentMusicVolume(
    source: CName
  ) -> Bool {
    let variable: ref<ConfigVarInt>;

    if !this.CanUseGameplayAudio() {
      return false;
    }

    variable = this.GetMusicVolumeSetting();

    if !IsDefined(variable) {
      return false;
    }

    this.m_savedMusicVolume = variable.GetValue();
    this.m_hasSavedMusicVolume = true;

    return true;
  }

  private func DuckMusicVolume(
    source: CName
  ) -> Bool {
    let currentValue: Int32;
    let variable: ref<ConfigVarInt>;

    if !this.IsFeatureEnabled()
      || !this.CanUseGameplayAudio() {
      return false;
    }

    variable = this.GetMusicVolumeSetting();

    if !IsDefined(variable) {
      return false;
    }

    currentValue = variable.GetValue();

    if !this.m_isDucked {
      if currentValue > 0 {
        this.m_savedMusicVolume = currentValue;
        this.m_hasSavedMusicVolume = true;
      }

      this.m_isDucked = true;
    }

    if NotEquals(currentValue, 0) {
      this.WriteMusicVolume(
        variable,
        0,
        source
      );
    }

    return true;
  }

  private func RestoreMusicVolume(
    source: CName
  ) -> Bool {
    let currentValue: Int32;
    let variable: ref<ConfigVarInt>;

    if !this.m_isDucked {
      return false;
    }

    variable = this.GetMusicVolumeSetting();
    this.m_isDucked = false;

    if !IsDefined(variable)
      || !this.m_hasSavedMusicVolume {
      return false;
    }

    currentValue = variable.GetValue();

    if NotEquals(
      currentValue,
      this.m_savedMusicVolume
    ) {
      this.WriteMusicVolume(
        variable,
        this.m_savedMusicVolume,
        source
      );
    }

    return true;
  }

  private func WriteMusicVolume(
    variable: ref<ConfigVarInt>,
    value: Int32,
    source: CName
  ) -> Void {
    if !IsDefined(variable) {
      return;
    }

    this.m_internalWrite = true;
    variable.SetValue(value);
    this.m_internalWrite = false;
  }

  private func GetMusicVolumeSetting() -> ref<ConfigVarInt> {
    let settings = GameInstance.GetSettingsSystem(
      this.GetGameInstance()
    );

    if !IsDefined(settings) {
      return null;
    }

    return settings.GetVar(
      n"/audio/volume",
      n"MusicVolume"
    ) as ConfigVarInt;
  }
}

public class AWRadioMusicDuckMountedRefreshCallback extends DelayCallback {
  private let m_source: CName;

  public static func Create(
    source: CName
  ) -> ref<AWRadioMusicDuckMountedRefreshCallback> {
    let callback = new AWRadioMusicDuckMountedRefreshCallback();

    callback.m_source = source;

    return callback;
  }

  public func Call() -> Void {
    AWRadioMusicDuckBridge.RefreshMountedRadio(this.m_source);
  }
}

public abstract class AWRadioMusicDuckBridge {
  public static func SetRadioPlaying(
    playing: Bool,
    source: CName
  ) -> Void {
    let system = AWRadioMusicDuckSystem.Get();

    if IsDefined(system) {
      system.SetRadioPlaying(
        playing,
        source
      );
    }
  }

  public static func RefreshCurrentRadioState(
    source: CName
  ) -> Void {
    let player = GetPlayer(GetGameInstance());
    let pocketRadio: ref<PocketRadio>;
    let service = AWRadioService.Get();

    if IsDefined(service)
      && service.HasActivePlayback() {
      AWRadioMusicDuckBridge.SetRadioPlaying(
        service.IsPlaybackRunning(),
        source
      );

      return;
    }

    if !IsDefined(player) {
      AWRadioMusicDuckBridge.SetRadioPlaying(
        false,
        source
      );

      return;
    }

    if IsDefined(GetMountedVehicle(player)) {
      AWRadioMusicDuckBridge.RefreshMountedRadio(source);
      return;
    }

    pocketRadio = player.GetPocketRadio();

    AWRadioMusicDuckBridge.SetRadioPlaying(
      IsDefined(pocketRadio) && pocketRadio.IsActive(),
      source
    );
  }

  public static func RefreshMountedRadio(
    source: CName
  ) -> Void {
    let blackboard: ref<IBlackboard>;
    let player = GetPlayer(GetGameInstance());
    let service = AWRadioService.Get();
    let vehicle: wref<VehicleObject>;

    if IsDefined(service)
      && service.HasActivePlayback() {
      AWRadioMusicDuckBridge.SetRadioPlaying(
        service.IsPlaybackRunning(),
        source
      );

      return;
    }

    if !IsDefined(player) {
      return;
    }

    vehicle = GetMountedVehicle(player);

    if !IsDefined(vehicle) {
      return;
    }

    blackboard = vehicle.GetBlackboard();

    if !IsDefined(blackboard) {
      return;
    }

    AWRadioMusicDuckBridge.SetRadioPlaying(
      blackboard.GetBool(
        GetAllBlackboardDefs()
          .Vehicle
          .VehRadioState
      ),
      source
    );
  }

  public static func ScheduleMountedRadioRefresh(
    delay: Float,
    source: CName
  ) -> Void {
    let callback = AWRadioMusicDuckMountedRefreshCallback.Create(source);

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(
        callback,
        delay,
        false
      );
  }

  public static func SetLoadingSuspended(
    suspended: Bool,
    source: CName
  ) -> Void {
    let system = AWRadioMusicDuckSystem.Get();

    if IsDefined(system) {
      system.SetLoadingSuspended(
        suspended,
        source
      );
    }
  }

  public static func SetRestrictionSuspended(
    suspended: Bool,
    source: CName
  ) -> Void {
    let system = AWRadioMusicDuckSystem.Get();

    if IsDefined(system) {
      system.SetRestrictionSuspended(
        suspended,
        source
      );
    }
  }

  public static func SetCombatSuspended(
    suspended: Bool,
    source: CName
  ) -> Void {
    let system = AWRadioMusicDuckSystem.Get();

    if IsDefined(system) {
      system.SetCombatSuspended(
        suspended,
        source
      );
    }
  }
}
