module AWRadioFramework

public class AWRadioLoadingVolumeRestoreCallback extends DelayCallback {
  public func Call() -> Void {
    let service = AWRadioService.Get();

    if IsDefined(service) {
      service.CompleteRestoreAfterLoadingScreen();
    }
  }
}

public class AWRadioLoadingSeekCallback extends DelayCallback {
  public func Call() -> Void {
    let service = AWRadioService.Get();

    if IsDefined(service)
      && service.PrepareRestoreAfterLoadingScreen() {
      AWRadioLoadingBridge.ScheduleVolumeRestore();
    }
  }
}

public abstract class AWRadioLoadingBridge {
  public static func ScheduleSeekRestore() -> Void {
    let callback = new AWRadioLoadingSeekCallback();

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(
        callback,
        1.0,
        false
      );
  }

  public static func ScheduleVolumeRestore() -> Void {
    let callback = new AWRadioLoadingVolumeRestoreCallback();

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(
        callback,
        0.10,
        false
      );
  }

  public static func MuteLateFallback() -> Void {
    let service = AWRadioService.Get();

    if IsDefined(service) {
      service.MuteForLoadingScreen();
    }
  }
}

@wrapMethod(WorldMapMenuGameController)
private func FastTravel() -> Void {
  let service = AWRadioService.Get();

  if this.IsFastTravelEnabled()
    && IsDefined(this.GetPlayer()) {
    AWRadioMusicDuckBridge.SetLoadingSuspended(
      true,
      n"world-map-fast-travel"
    );
  }

  if IsDefined(service) {
    service.BeginFastTravelHandoff();
  }

  wrappedMethod();
}

@wrapMethod(FastTravelSystem)
protected cb func OnLoadingScreenFinished(
  value: Bool
) -> Bool {
  let result: Bool;

  if !value {
    AWRadioLoadingBridge.MuteLateFallback();
  }

  result = wrappedMethod(value);

  if value {
    AWRadioLoadingBridge.ScheduleSeekRestore();

    AWRadioMusicDuckBridge.SetLoadingSuspended(
      false,
      n"loading-screen-finished"
    );
  }

  return result;
}
