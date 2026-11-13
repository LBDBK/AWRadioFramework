module AWRadioFramework

public abstract class AWRadioLoadingLifecycleParity04 {
  public static func Enter(source: CName) -> Void {
    let service = AWRadioService.Get();
    let running = IsDefined(service) && service.IsPlaybackRunning();
    let muted = false;

    AWRadioMusicDuckBridge.SetLoadingSuspended(
      true,
      source
    );

    if IsDefined(service) {
      muted = service.MuteForLoadingScreen();
    }

    FTLog(
      s"[AWRadioFramework][PARITY04] LOADING-ENTER source=\(source) service=\(IsDefined(service)) runningBefore=\(running) muted=\(muted)"
    );
  }

  public static func FinishGeneric(source: CName) -> Void {
    let service = AWRadioService.Get();
    let pending = IsDefined(service)
      && service.IsGenericLoadingScreenRestorePending();

    FTLog(
      s"[AWRadioFramework][PARITY04] LOADING-FINISH source=\(source) genericPending=\(pending)"
    );

    if pending
      && service.ArmLoadingScreenRestore(
        source
      ) {
      AWRadioLoadingBridge.ScheduleSeekRestore();
    }

    if !IsDefined(service)
      || pending
      || !service.IsLoadingScreenRestorePending() {
      AWRadioMusicDuckBridge.SetLoadingSuspended(
        false,
        source
      );
    }
  }
}

@wrapMethod(LoadingScreenProgressBarController)
protected cb func OnInitialize() -> Bool {
  AWRadioLoadingLifecycleParity04.Enter(
    n"loading-progress-init"
  );

  return wrappedMethod();
}

@wrapMethod(LoadingScreenProgressBarController)
private final func SetProgress(
  progress: Float
) -> Void {
  wrappedMethod(progress);

  if progress >= 1.0 {
    AWRadioLoadingLifecycleParity04.FinishGeneric(
      n"loading-progress-complete"
    );
  }
}

@wrapMethod(LoadingScreenLogicController)
protected cb func OnInitialize() -> Bool {
  AWRadioLoadingLifecycleParity04.Enter(
    n"loading-logic-init"
  );

  return wrappedMethod();
}
