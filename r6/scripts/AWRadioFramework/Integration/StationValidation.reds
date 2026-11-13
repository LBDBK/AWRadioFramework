module AWRadioFramework

import Codeware.*

public abstract class AWRadioStationValidationPopup {
  public static func Show(
    controller: ref<worlduiIGameController>,
    message: String
  ) -> ref<inkGameNotificationToken> {
    return GenericMessageNotification.Show(
      controller,
      GetLocalizedText("LocKey#11447"),
      message,
      GenericMessageNotificationType.OK
    );
  }
}

@addField(SingleplayerMenuGameController)
private let m_awRadioStationValidationPopup: ref<inkGameNotificationToken>;

@addMethod(SingleplayerMenuGameController)
public func AWRadioShowPendingValidationPopup() -> Void {
  let service = AWRadioService.Get();

  if !IsDefined(service)
    || !service.HasPendingStationValidationWarning()
    || IsDefined(this.m_awRadioStationValidationPopup) {
    return;
  }

  this.m_awRadioStationValidationPopup = AWRadioStationValidationPopup.Show(
    this,
    service.GetStationValidationWarningMessage()
  );

  if IsDefined(this.m_awRadioStationValidationPopup) {
    this.m_awRadioStationValidationPopup.RegisterListener(
      this,
      n"OnAWRadioStationValidationPopupClosed"
    );
  }
}

@wrapMethod(SingleplayerMenuGameController)
private func PopulateMenuItemList() {
  wrappedMethod();

  let service = AWRadioService.Get();

  if IsDefined(service) {
    service.SetStationValidationMenuController(this);
  }
}

@addMethod(SingleplayerMenuGameController)
protected cb func OnAWRadioStationValidationPopupClosed(
  data: ref<inkGameNotificationData>
) {
  let service = AWRadioService.Get();

  this.m_awRadioStationValidationPopup = null;

  if IsDefined(service) {
    service.MarkStationValidationWarningShown();
  }
}
