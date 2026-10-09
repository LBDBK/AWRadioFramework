module AWRadioFramework

public abstract class AWRadioLoadingLifecycleParity04 {
  public static func Enter(source: CName) -> Void {
    let service = AWRadioService.Get();
    AWRadioMusicDuckBridge.SetLoadingSuspended(
      true,
      source
    );

    if IsDefined(service) {
      service.MuteForLoadingScreen();
    }
  }

  public static func FinishGeneric(source: CName) -> Void {
    let service = AWRadioService.Get();
    let pending = IsDefined(service)
      && service.IsGenericLoadingScreenRestorePending();

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
protected cb func OnInitialize() -> Void {
  AWRadioLoadingLifecycleParity04.Enter(
    n"loading-progress-init"
  );

  wrappedMethod();
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
protected cb func OnInitialize() -> Void {
  AWRadioLoadingLifecycleParity04.Enter(
    n"loading-logic-init"
  );

  wrappedMethod();
}
