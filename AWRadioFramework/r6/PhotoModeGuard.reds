module AWRadioFramework

public class AWRadioPhotoModeGuardSystem extends ScriptableSystem {
  private let m_photoModeListener: ref<CallbackHandle>;

  private func OnAttach() -> Void {
    this.m_photoModeListener = GameInstance
      .GetBlackboardSystem(this.GetGameInstance())
      .Get(GetAllBlackboardDefs().PhotoMode)
      .RegisterListenerBool(
        GetAllBlackboardDefs().PhotoMode.IsActive,
        this,
        n"OnPhotoModeStateChanged"
      );
  }

  private func OnDetach() -> Void {
    if IsDefined(this.m_photoModeListener) {
      GameInstance
        .GetBlackboardSystem(this.GetGameInstance())
        .Get(GetAllBlackboardDefs().PhotoMode)
        .UnregisterListenerBool(
          GetAllBlackboardDefs().PhotoMode.IsActive,
          this.m_photoModeListener
        );

      this.m_photoModeListener = null;
    }
  }

  protected cb func OnPhotoModeStateChanged(
    active: Bool
  ) -> Bool {
    let service = AWRadioService.Get();

    if !IsDefined(service) {
      return active;
    }

    service.SetPhotoModeActive(
      active,
      active
        ? n"photomode-open"
        : n"photomode-close"
    );

    return active;
  }
}
