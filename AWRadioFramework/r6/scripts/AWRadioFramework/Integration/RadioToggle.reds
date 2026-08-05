module AWRadioFramework

public abstract class AWRadioPlaybackUIBridge {
  public static func Sync(
    service: ref<AWRadioService>
  ) -> Void {
    let recordIndex = -1;
    let selectedRowState =
      AWRadioSelectedRowService.Get();

    if !IsDefined(service)
      || !IsDefined(selectedRowState) {
      return;
    }

    if service.IsPlaybackRunning() {
      recordIndex = service.GetActiveStationIndex();
    }

    selectedRowState.SetActiveRecordIndex(
      recordIndex
    );

    selectedRowState.ScheduleRefresh();
  }
}

@wrapMethod(PocketRadio)
public final func IsActive() -> Bool {
  let mounted: Bool;
  let player: wref<PlayerPuppet>;
  let service = AWRadioService.Get();

  if IsDefined(service)
    && service.HasActivePlayback() {
    if service.IsSyncToVehicleEnabled() {
      return service.IsPlaybackRunning();
    }

    player = GetPlayer(GetGameInstance());
    mounted = IsDefined(player)
      && IsDefined(GetMountedVehicle(player));

    if mounted {
      return service.IsVehiclePlaybackEnabled();
    }

    return service.IsOnFootPlaybackEnabled();
  }

  return wrappedMethod();
}

@wrapMethod(PocketRadio)
private func HandleRadioToggleEvent(
  evt: ref<RadioToggleEvent>
) -> Void {
  let desiredPaused: Bool;
  let desiredPlaying: Bool;
  let savedStationState = AWRadioSavedStationSystem.Get();
  let service = AWRadioService.Get();

  if IsDefined(service)
    && service.HasActivePlayback()
    && !IsDefined(
      GetMountedVehicle(
        GetPlayer(GetGameInstance())
      )
    ) {
    if service.IsSyncToVehicleEnabled() {
      desiredPaused = !service.IsPlaybackPaused();
      desiredPlaying = !desiredPaused;

      wrappedMethod(evt);

      service.SetContextPlaybackEnabled(
        false,
        desiredPlaying,
        n"on-foot-hotkey-sync-enabled"
      );

      if desiredPaused {
        if !service.IsPlaybackPaused() {
          service.PausePlayback(
            n"on-foot-hotkey"
          );
        }
      } else {
        if service.IsPlaybackPaused() {
          service.ResumePlayback(
            n"on-foot-hotkey"
          );
        }
      }
    } else {
      desiredPlaying = !service.IsOnFootPlaybackEnabled();

      service.SetContextPlaybackEnabled(
        false,
        desiredPlaying,
        n"on-foot-hotkey-intent"
      );

      service.ApplyPlaybackStateForContext(
        false,
        n"on-foot-hotkey-apply"
      );

      AWRadioVehicleTransitionBridge.SyncPocketCustomState(
        desiredPlaying,
        n"on-foot-hotkey-pocket"
      );

      AWRadioVehicleTransitionBridge.ScheduleContextUIRefresh(
        0.10,
        false,
        n"on-foot-hotkey-ui-100ms"
      );
    }

    AWRadioPlaybackUIBridge.Sync(service);

    if IsDefined(savedStationState) {
      savedStationState.RecordPlaybackState(
        service.IsPlaybackRunning()
      );
    }

    AWRadioMusicDuckBridge.SetRadioPlaying(
      service.IsPlaybackRunning(),
      n"on-foot-custom-hotkey"
    );

    return;
  }

  wrappedMethod(evt);

  AWRadioMusicDuckBridge.SetRadioPlaying(
    this.IsActive(),
    n"on-foot-native-hotkey"
  );
}

@wrapMethod(VehicleComponent)
protected cb func OnRadioToggleEvent(
  evt: ref<RadioToggleEvent>
) -> Bool {
  let desiredPaused: Bool;
  let desiredPlaying: Bool;
  let savedStationState = AWRadioSavedStationSystem.Get();
  let service = AWRadioService.Get();
  let vanillaResult: Bool;

  if IsDefined(service)
    && service.HasActivePlayback() {
    if service.IsSyncToVehicleEnabled() {
      desiredPaused = !service.IsPlaybackPaused();
      desiredPlaying = !desiredPaused;

      vanillaResult = wrappedMethod(evt);

      service.SetContextPlaybackEnabled(
        true,
        desiredPlaying,
        n"mounted-hotkey-sync-enabled"
      );

      if desiredPaused {
        if !service.IsPlaybackPaused() {
          service.PausePlayback(
            n"mounted-hotkey"
          );
        }
      } else {
        if service.IsPlaybackPaused() {
          service.ResumePlayback(
            n"mounted-hotkey"
          );
        }
      }

      AWRadioVehicleTransitionBridge.SyncMountedState(
        service.IsPlaybackRunning(),
        n"mounted-hotkey"
      );

      AWRadioVehicleTransitionBridge
        .ScheduleMountedStateSync(
          0.10,
          n"mounted-hotkey-100ms"
        );
    } else {
      desiredPlaying = !service.IsVehiclePlaybackEnabled();

      vanillaResult = wrappedMethod(evt);

      service.SetContextPlaybackEnabled(
        true,
        desiredPlaying,
        n"mounted-hotkey-intent"
      );

      service.ApplyPlaybackStateForContext(
        true,
        n"mounted-hotkey-apply"
      );

      AWRadioVehicleTransitionBridge.SyncMountedState(
        desiredPlaying,
        n"mounted-hotkey"
      );

      GameInstance
        .GetUISystem(GetGameInstance())
        .QueueEvent(
          new VehicleRadioSongChanged()
        );

      AWRadioVehicleTransitionBridge.ScheduleContextUIRefresh(
        0.10,
        true,
        n"mounted-hotkey-ui-100ms"
      );
    }

    AWRadioPlaybackUIBridge.Sync(service);

    if IsDefined(savedStationState) {
      savedStationState.RecordPlaybackState(
        service.IsPlaybackRunning()
      );
    }

    AWRadioMusicDuckBridge.SetRadioPlaying(
      service.IsPlaybackRunning(),
      n"mounted-custom-hotkey"
    );

    return vanillaResult;
  }

  vanillaResult = wrappedMethod(evt);

  AWRadioMusicDuckBridge.RefreshMountedRadio(
    n"mounted-native-hotkey"
  );

  return vanillaResult;
}
