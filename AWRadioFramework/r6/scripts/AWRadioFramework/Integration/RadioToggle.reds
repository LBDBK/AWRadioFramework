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
  let service = AWRadioService.Get();

  if IsDefined(service)
    && service.HasActivePlayback() {
    return service.IsPlaybackRunning();
  }

  return wrappedMethod();
}

@wrapMethod(PocketRadio)
private func HandleRadioToggleEvent(
  evt: ref<RadioToggleEvent>
) -> Void {
  let desiredPaused: Bool;
  let savedStationState = AWRadioSavedStationSystem.Get();
  let service = AWRadioService.Get();

  if IsDefined(service)
    && service.HasActivePlayback()
    && !IsDefined(
      GetMountedVehicle(
        GetPlayer(GetGameInstance())
      )
    ) {
    desiredPaused = !service.IsPlaybackPaused();

    wrappedMethod(evt);

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
  let savedStationState = AWRadioSavedStationSystem.Get();
  let service = AWRadioService.Get();
  let vanillaResult: Bool;

  if IsDefined(service)
    && service.HasActivePlayback() {
    desiredPaused = !service.IsPlaybackPaused();

    vanillaResult = wrappedMethod(evt);

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

    AWRadioVehicleTransitionBridge.SyncMountedState(
      service.IsPlaybackRunning(),
      n"mounted-hotkey"
    );

    AWRadioVehicleTransitionBridge
      .ScheduleMountedStateSync(
        0.10,
        n"mounted-hotkey-100ms"
      );

    return vanillaResult;
  }

  vanillaResult = wrappedMethod(evt);

  AWRadioMusicDuckBridge.RefreshMountedRadio(
    n"mounted-native-hotkey"
  );

  return vanillaResult;
}
