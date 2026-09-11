module AWRadioFramework

import Codeware.*

public class AWRadioMountedSyncCallback extends DelayCallback {
  private let m_source: CName;

  public static func Create(
    source: CName
  ) -> ref<AWRadioMountedSyncCallback> {
    let callback = new AWRadioMountedSyncCallback();

    callback.m_source = source;

    return callback;
  }

  public func Call() -> Void {
    let service = AWRadioService.Get();

    if IsDefined(service)
      && service.HasActivePlayback() {
      AWRadioVehicleTransitionBridge.SyncMountedState(
        service.IsPlaybackRunning(),
        this.m_source
      );
    }
  }
}

public class AWRadioUnmountRestoreCallback extends DelayCallback {
  private let m_source: CName;

  public static func Create(
    source: CName
  ) -> ref<AWRadioUnmountRestoreCallback> {
    let callback = new AWRadioUnmountRestoreCallback();

    callback.m_source = source;

    return callback;
  }

  public func Call() -> Void {
    AWRadioVehicleTransitionBridge.RestorePocketState(
      this.m_source
    );
  }
}

public class AWRadioContextUIRefreshCallback extends DelayCallback {
  private let m_expectedMounted: Bool;
  private let m_source: CName;

  public static func Create(
    expectedMounted: Bool,
    source: CName
  ) -> ref<AWRadioContextUIRefreshCallback> {
    let callback = new AWRadioContextUIRefreshCallback();

    callback.m_expectedMounted = expectedMounted;
    callback.m_source = source;

    return callback;
  }

  public func Call() -> Void {
    AWRadioVehicleTransitionBridge.RefreshContextUI(
      this.m_expectedMounted,
      this.m_source
    );
  }
}

public abstract class AWRadioVehicleTransitionBridge {
  private static func SetNumericProperty(
    target: ref<IScriptable>,
    propertyName: CName,
    value: Int32
  ) -> Bool {
    let classType: ref<ReflectionClass>;
    let owner: Variant;
    let property: ref<ReflectionProp>;
    let propertyType: ref<ReflectionType>;
    let typeName: CName;

    let int16Value: Int16;
    let int32Value: Int32;
    let uint16Value: Uint16;
    let uint32Value: Uint32;

    if !IsDefined(target) {
      return false;
    }

    owner = ToVariant(target);

    classType = Reflection.GetClassOf(
      owner,
      true
    );

    if !IsDefined(classType) {
      return false;
    }

    property = classType.GetProperty(
      propertyName
    );

    if !IsDefined(property) {
      return false;
    }

    propertyType = property.GetType();

    if !IsDefined(propertyType) {
      return false;
    }

    typeName = propertyType.GetName();

    if Equals(typeName, n"Uint32") {
      uint32Value = Cast<Uint32>(value);

      property.SetValue(
        owner,
        ToVariant(uint32Value)
      );

      return true;
    }

    if Equals(typeName, n"Int32") {
      int32Value = value;

      property.SetValue(
        owner,
        ToVariant(int32Value)
      );

      return true;
    }

    if Equals(typeName, n"Uint16") {
      uint16Value = Cast<Uint16>(value);

      property.SetValue(
        owner,
        ToVariant(uint16Value)
      );

      return true;
    }

    if Equals(typeName, n"Int16") {
      int16Value = Cast<Int16>(value);

      property.SetValue(
        owner,
        ToVariant(int16Value)
      );

      return true;
    }

    return false;
  }

  private static func SetComponentBoolProperty(
    component: ref<VehicleComponent>,
    propertyName: CName,
    value: Bool
  ) -> Bool {
    let classType: ref<ReflectionClass>;
    let owner: Variant;
    let property: ref<ReflectionProp>;
    let propertyType: ref<ReflectionType>;

    if !IsDefined(component) {
      return false;
    }

    owner = ToVariant(component);

    classType = Reflection.GetClassOf(
      owner,
      true
    );

    if !IsDefined(classType) {
      return false;
    }

    property = classType.GetProperty(
      propertyName
    );

    if !IsDefined(property) {
      return false;
    }

    propertyType = property.GetType();

    if !IsDefined(propertyType)
      || NotEquals(
        propertyType.GetName(),
        n"Bool"
      ) {
      return false;
    }

    property.SetValue(
      owner,
      ToVariant(value)
    );

    return true;
  }

  public static func RewriteStationChange(
    evt: ref<VehicleRadioStationChanged>
  ) -> Bool {
    let service = AWRadioService.Get();

    if !IsDefined(evt)
      || !IsDefined(service)
      || !service.HasActivePlayback() {
      return false;
    }

    if AWRadioVehicleTransitionBridge.SetNumericProperty(
      evt,
      n"radioIndex",
      service.GetActiveStationIndex()
    ) {
      return true;
    }

    return false;
  }

  public static func SyncMountedState(
    isPlaying: Bool,
    source: CName
  ) -> Bool {
    let blackboard: ref<IBlackboard>;
    let component: ref<VehicleComponent>;
    let player = GetPlayer(GetGameInstance());
    let service = AWRadioService.Get();
    let station: ref<AWRadioStationDefinition>;
    let vehicle: wref<VehicleObject>;

    if !IsDefined(player)
      || !IsDefined(service)
      || !service.HasActivePlayback() {
      return false;
    }

    service.RefreshActiveVolume(source);

    vehicle = GetMountedVehicle(player);

    if !IsDefined(vehicle) {
      return false;
    }

    vehicle.ToggleRadioReceiver(false);

    component = vehicle.GetVehicleComponent();

    if IsDefined(component) {
      AWRadioVehicleTransitionBridge.SetComponentBoolProperty(
        component,
        n"radioState",
        isPlaying
      );
    }

    blackboard = vehicle.GetBlackboard();

    if IsDefined(blackboard) {
      blackboard.SetBool(
        GetAllBlackboardDefs()
          .Vehicle
          .VehRadioState,
        isPlaying
      );

      station = service.FindStationByIndex(
        service.GetActiveStationIndex()
      );

      if IsDefined(station) {
        blackboard.SetName(
          GetAllBlackboardDefs()
            .Vehicle
            .VehRadioStationName,
          station.displayName
        );
      }
    }

    return true;
  }

  public static func ScheduleMountedStateSync(
    delay: Float,
    source: CName
  ) -> Void {
    let callback = AWRadioMountedSyncCallback.Create(
      source
    );

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(
        callback,
        delay,
        false
      );
  }

  public static func RestorePocketState(
    source: CName
  ) -> Bool {
    let service = AWRadioService.Get();

    if !IsDefined(service)
      || !service.HasActivePlayback() {
      return false;
    }

    service.RefreshActiveVolume(source);

    AWRadioPocketStateBridge.QueueState(
      service.IsPlaybackRunning(),
      true,
      service.GetActiveStationIndex()
    );

    AWRadioPlaybackUIBridge.Sync(service);

    GameInstance
      .GetUISystem(GetGameInstance())
      .QueueEvent(
        new VehicleRadioSongChanged()
      );

    return true;
  }

  public static func SyncPocketCustomState(
    shouldPlay: Bool,
    source: CName
  ) -> Bool {
    let player = GetPlayer(GetGameInstance());
    let service = AWRadioService.Get();

    if !IsDefined(player)
      || !IsDefined(service)
      || !service.HasActivePlayback() {
      return false;
    }

    service.RefreshActiveVolume(source);

    AWRadioPocketStateBridge.QueueState(
      false,
      false,
      -1
    );

    AWRadioPocketStateBridge.QueueState(
      shouldPlay,
      true,
      service.GetActiveStationIndex()
    );

    AWRadioPlaybackUIBridge.Sync(service);

    GameInstance
      .GetUISystem(GetGameInstance())
      .QueueEvent(
        new VehicleRadioSongChanged()
      );

    return true;
  }

  public static func RefreshContextUI(
    expectedMounted: Bool,
    source: CName
  ) -> Bool {
    let mounted: Bool;
    let player = GetPlayer(GetGameInstance());
    let service = AWRadioService.Get();

    if !IsDefined(player)
      || !IsDefined(service)
      || !service.HasActivePlayback() {
      return false;
    }

    mounted = IsDefined(GetMountedVehicle(player));

    if NotEquals(mounted, expectedMounted) {
      return false;
    }

    if mounted {
      AWRadioVehicleTransitionBridge.SyncMountedState(
        service.IsPlaybackRunning(),
        source
      );
    }

    AWRadioPlaybackUIBridge.Sync(service);

    GameInstance
      .GetUISystem(GetGameInstance())
      .QueueEvent(
        new VehicleRadioSongChanged()
      );

    return true;
  }

  public static func ScheduleContextUIRefresh(
    delay: Float,
    expectedMounted: Bool,
    source: CName
  ) -> Void {
    let callback = AWRadioContextUIRefreshCallback.Create(
      expectedMounted,
      source
    );

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(
        callback,
        delay,
        false
      );
  }

  public static func SchedulePocketRestore(
    delay: Float,
    source: CName
  ) -> Void {
    let callback = AWRadioUnmountRestoreCallback.Create(
      source
    );

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(
        callback,
        delay,
        false
      );
  }
}

@wrapMethod(EnteringEvents)
protected func OnEnter(
  stateContext: ref<StateContext>,
  scriptInterface: ref<StateGameScriptInterface>
) -> Void {
  let service = AWRadioService.Get();

  wrappedMethod(
    stateContext,
    scriptInterface
  );

  AWRadioMusicDuckBridge.ScheduleMountedRadioRefresh(
    0.10,
    n"vehicle-mount-100ms"
  );

  AWRadioMusicDuckBridge.ScheduleMountedRadioRefresh(
    0.50,
    n"vehicle-mount-500ms"
  );

  if IsDefined(service)
    && service.HasActivePlayback() {
    if service.IsSyncToVehicleEnabled() {
      AWRadioVehicleTransitionBridge
        .ScheduleMountedStateSync(
          0.05,
          n"mount-50ms"
        );

      AWRadioVehicleTransitionBridge
        .ScheduleMountedStateSync(
          0.10,
          n"mount-100ms"
        );

      AWRadioVehicleTransitionBridge
        .ScheduleMountedStateSync(
          0.50,
          n"mount-500ms"
        );
    } else {
      service.InitializeVehiclePlaybackFromOnFoot(
        n"vehicle-mount-initialize"
      );

      service.ApplyPlaybackStateForContext(
        true,
        n"vehicle-mount-apply"
      );

      AWRadioVehicleTransitionBridge.SyncMountedState(
        service.IsPlaybackRunning(),
        n"vehicle-mount-immediate"
      );

      AWRadioVehicleTransitionBridge.ScheduleContextUIRefresh(
        0.10,
        true,
        n"vehicle-mount-ui-100ms"
      );

      AWRadioVehicleTransitionBridge.ScheduleContextUIRefresh(
        0.35,
        true,
        n"vehicle-mount-ui-350ms"
      );

      AWRadioPlaybackUIBridge.Sync(service);

      GameInstance
        .GetUISystem(GetGameInstance())
        .QueueEvent(
          new VehicleRadioSongChanged()
        );

      AWRadioMusicDuckBridge.SetRadioPlaying(
        service.IsPlaybackRunning(),
        n"vehicle-mount-custom"
      );
    }
  }
}

@wrapMethod(PocketRadio)
private func HandleVehicleRadioStationChanged(
  evt: ref<VehicleRadioStationChanged>
) -> Void {
  AWRadioVehicleTransitionBridge
    .RewriteStationChange(evt);

  wrappedMethod(evt);
}

@wrapMethod(PocketRadio)
private func HandleVehicleUnmounted(
  vehicle: wref<VehicleObject>
) -> Void {
  let onFootShouldPlay: Bool;
  let service = AWRadioService.Get();

  if IsDefined(service)
    && service.HasActivePlayback()
    && IsDefined(vehicle) {
    vehicle.ToggleRadioReceiver(false);
  }

  wrappedMethod(vehicle);

  if IsDefined(service)
    && service.HasActivePlayback() {
    if IsDefined(vehicle) {
      vehicle.ToggleRadioReceiver(false);
    }

    if service.IsSyncToVehicleEnabled() {
      AWRadioVehicleTransitionBridge.RestorePocketState(
        n"unmount-immediate"
      );

      AWRadioVehicleTransitionBridge
        .SchedulePocketRestore(
          0.05,
          n"unmount-50ms"
        );

      AWRadioVehicleTransitionBridge
        .SchedulePocketRestore(
          0.10,
          n"unmount-100ms"
        );
    } else {
      onFootShouldPlay = service.IsOnFootPlaybackEnabled();

      service.ApplyPlaybackStateForContext(
        false,
        n"vehicle-unmount-apply"
      );

      AWRadioVehicleTransitionBridge.SyncPocketCustomState(
        onFootShouldPlay,
        n"vehicle-unmount-pocket"
      );

      AWRadioVehicleTransitionBridge.ScheduleContextUIRefresh(
        0.10,
        false,
        n"vehicle-unmount-ui-100ms"
      );

      AWRadioVehicleTransitionBridge.ScheduleContextUIRefresh(
        0.35,
        false,
        n"vehicle-unmount-ui-350ms"
      );
    }

    AWRadioMusicDuckBridge.SetRadioPlaying(
      service.IsPlaybackRunning(),
      n"vehicle-unmount-custom"
    );
  } else {
    AWRadioMusicDuckBridge.SetRadioPlaying(
      this.IsActive(),
      n"vehicle-unmount-native"
    );
  }
}

@wrapMethod(PocketRadio)
private func HandleVehicleRadioEvent(
  evt: ref<VehicleRadioEvent>
) -> Void {
  let service = AWRadioService.Get();

  wrappedMethod(evt);

  if IsDefined(service)
    && service.HasActivePlayback() {
    AWRadioMusicDuckBridge.SetRadioPlaying(
      service.IsPlaybackRunning(),
      n"vehicle-radio-event-custom"
    );
  } else {
    AWRadioMusicDuckBridge.SetRadioPlaying(
      evt.toggle,
      n"vehicle-radio-event-native"
    );
  }

  if IsDefined(service)
    && service.HasActivePlayback()
    && IsDefined(
      GetMountedVehicle(
        GetPlayer(GetGameInstance())
      )
    ) {
    AWRadioVehicleTransitionBridge.SyncMountedState(
      service.IsPlaybackRunning(),
      n"vehicle-radio-event"
    );

    if service.IsSyncToVehicleEnabled() {
      AWRadioVehicleTransitionBridge
        .ScheduleMountedStateSync(
          0.10,
          n"selection-100ms"
        );
    } else {
      AWRadioPlaybackUIBridge.Sync(service);

      AWRadioVehicleTransitionBridge.ScheduleContextUIRefresh(
        0.10,
        true,
        n"vehicle-radio-event-ui-100ms"
      );
    }
  }
}
