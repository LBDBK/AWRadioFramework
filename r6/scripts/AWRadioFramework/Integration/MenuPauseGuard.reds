module AWRadioFramework

public class AWRadioMenuPauseGuardSystem extends ScriptableSystem {
  private let m_menuListener: ref<CallbackHandle>;

  private func OnAttach() -> Void {
    this.m_menuListener = GameInstance
      .GetBlackboardSystem(this.GetGameInstance())
      .Get(GetAllBlackboardDefs().UI_System)
      .RegisterListenerBool(
        GetAllBlackboardDefs().UI_System.IsInMenu,
        this,
        n"OnMenuStateChanged"
      );
  }

  private func OnDetach() -> Void {
    if IsDefined(this.m_menuListener) {
      GameInstance
        .GetBlackboardSystem(this.GetGameInstance())
        .Get(GetAllBlackboardDefs().UI_System)
        .UnregisterListenerBool(
          GetAllBlackboardDefs().UI_System.IsInMenu,
          this.m_menuListener
        );

      this.m_menuListener = null;
    }
  }

  protected cb func OnMenuStateChanged(
    value: Bool
  ) -> Bool {
    let service = AWRadioService.Get();

    if !IsDefined(service) {
      return value;
    }

    service.SetGameMenuActive(
      value,
      value
        ? n"ui-menu-open"
        : n"ui-menu-close"
    );

    return value;
  }
}
