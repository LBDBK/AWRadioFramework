module AWRadioFramework

public class AWRadioSavedStationRestoreCallback extends DelayCallback {
  private let m_attempt: Int32;
  private let m_generation: Int32;

  public static func Create(
    attempt: Int32,
    generation: Int32
  ) -> ref<AWRadioSavedStationRestoreCallback> {
    let callback = new AWRadioSavedStationRestoreCallback();

    callback.m_attempt = attempt;
    callback.m_generation = generation;

    return callback;
  }

  public func Call() -> Void {
    let state = AWRadioSavedStationSystem.Get();

    if IsDefined(state) {
      state.TryRestore(
        this.m_attempt,
        this.m_generation
      );
    }
  }
}

public class AWRadioSavedStationSystem extends ScriptableSystem {
  private persistent let m_hasCustomStation: Bool;
  private persistent let m_stationIndex: Int32;
  private persistent let m_wasPlaying: Bool;

  private let m_callbackSystem: wref<CallbackSystem>;
  private let m_sessionReady: Bool;
  private let m_restorePending: Bool;
  private let m_generation: Int32;

  public static func Get() -> ref<AWRadioSavedStationSystem> {
    return GameInstance
      .GetScriptableSystemsContainer(GetGameInstance())
      .Get(
        n"AWRadioFramework.AWRadioSavedStationSystem"
      ) as AWRadioSavedStationSystem;
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
  }

  private func OnDetach() -> Void {
    this.m_callbackSystem = null;
  }

  private cb func OnSessionReady(
    event: ref<GameSessionEvent>
  ) -> Void {
    if !IsDefined(event) || event.IsPreGame() {
      this.m_sessionReady = false;
      this.m_restorePending = false;
      this.m_generation += 1;

      return;
    }

    this.m_sessionReady = true;
    this.m_generation += 1;
    this.m_restorePending = this.m_hasCustomStation
      && this.m_wasPlaying;

    if this.m_restorePending {
      this.ScheduleRestore(
        0.75,
        1,
        this.m_generation
      );
    }
  }

  private cb func OnSessionBeforeEnd(
    event: ref<GameSessionEvent>
  ) -> Void {
    this.m_sessionReady = false;
    this.m_restorePending = false;
    this.m_generation += 1;
  }

  public func RecordCustomRadioEvent(
    toggle: Bool,
    setStation: Bool,
    stationIndex: Int32
  ) -> Void {
    if toggle && setStation {
      this.m_hasCustomStation = true;
      this.m_stationIndex = stationIndex;
      this.m_wasPlaying = true;
      this.m_restorePending = false;
      this.m_generation += 1;

      return;
    }

    if this.m_hasCustomStation
      && Equals(this.m_stationIndex, stationIndex) {
      this.RecordPlaybackState(false);
    }
  }

  public func RecordPlaybackState(
    isPlaying: Bool
  ) -> Void {
    if !this.m_hasCustomStation {
      return;
    }

    this.m_wasPlaying = isPlaying;

    if !isPlaying {
      this.m_restorePending = false;
      this.m_generation += 1;
    }
  }

  public func RecordNativeRadioEvent(
    toggle: Bool,
    setStation: Bool
  ) -> Void {
    if !toggle || !setStation {
      return;
    }

    this.m_hasCustomStation = false;
    this.m_stationIndex = 0;
    this.m_wasPlaying = false;
    this.m_restorePending = false;
    this.m_generation += 1;
  }

  private func GetSaveCurrentStationSetting() -> ref<ConfigVarBool> {
    return GameInstance
      .GetSettingsSystem(this.GetGameInstance())
      .GetVar(
        n"/gameplay/radioport",
        n"radioport_save_station"
      ) as ConfigVarBool;
  }

  private func ScheduleRestore(
    delay: Float,
    attempt: Int32,
    generation: Int32
  ) -> Void {
    let callback = AWRadioSavedStationRestoreCallback.Create(
      attempt,
      generation
    );

    GameInstance
      .GetDelaySystem(this.GetGameInstance())
      .DelayCallback(
        callback,
        delay,
        false
      );
  }

  private func RetryRestore(
    attempt: Int32,
    generation: Int32
  ) -> Bool {
    if attempt < 4 {
      this.ScheduleRestore(
        0.50,
        attempt + 1,
        generation
      );
    } else {
      this.m_restorePending = false;
    }

    return false;
  }

  public func TryRestore(
    attempt: Int32,
    generation: Int32
  ) -> Bool {
    let player: wref<PlayerPuppet>;
    let quickSlotsManager: ref<QuickSlotsManager>;
    let saveCurrentStation: ref<ConfigVarBool>;
    let service = AWRadioService.Get();
    let stationIndex = this.m_stationIndex;

    if NotEquals(generation, this.m_generation)
      || !this.m_restorePending
      || !this.m_sessionReady {
      return false;
    }

    saveCurrentStation = this.GetSaveCurrentStationSetting();

    if !IsDefined(saveCurrentStation) {
      return this.RetryRestore(
        attempt,
        generation
      );
    }

    if !saveCurrentStation.GetValue() {
      this.m_restorePending = false;

      return false;
    }

    player = GetPlayer(this.GetGameInstance());

    if !IsDefined(player)
      || !IsDefined(service)
      || !service.IsCustomStation(stationIndex) {
      return this.RetryRestore(
        attempt,
        generation
      );
    }

    if service.HasActivePlayback()
      && Equals(
        service.GetActiveStationIndex(),
        stationIndex
      ) {
      this.m_restorePending = false;
      this.m_wasPlaying = service.IsPlaybackRunning();

      return true;
    }

    quickSlotsManager = player.GetQuickSlotsManager();

    if !IsDefined(quickSlotsManager) {
      return this.RetryRestore(
        attempt,
        generation
      );
    }

    quickSlotsManager.SendRadioEvent(
      false,
      false,
      -1
    );

    AWRadioPocketStateBridge.QueueState(
      true,
      true,
      stationIndex
    );

    service.HandleRadioEvent(
      true,
      true,
      stationIndex
    );

    if !service.HasActivePlayback()
      || NotEquals(
        service.GetActiveStationIndex(),
        stationIndex
      ) {
      return this.RetryRestore(
        attempt,
        generation
      );
    }

    this.m_restorePending = false;
    this.m_wasPlaying = service.IsPlaybackRunning();

    AWRadioMusicDuckBridge.SetRadioPlaying(
      service.IsPlaybackRunning(),
      n"saved-station-restore"
    );

    AWRadioPlaybackUIBridge.Sync(service);

    if IsDefined(GetMountedVehicle(player)) {
      AWRadioVehicleTransitionBridge.SyncMountedState(
        service.IsPlaybackRunning(),
        n"saved-station-restore"
      );

      AWRadioVehicleTransitionBridge
        .ScheduleMountedStateSync(
          0.10,
          n"saved-station-restore-100ms"
        );
    }

    return true;
  }
}
