module AWRadioFramework

import Codeware.*

public abstract class AWRadioTrackNotificationHelper {
  public static func SetNotificationText(
    controller: ref<VehicleSummonWidgetGameController>,
    stationTitle: String,
    trackTitle: String
  ) -> Bool {
    let controllerClass: ref<ReflectionClass>;
    let owner: Variant;
    let radioStationName: inkTextRef;
    let radioStationNameProperty: ref<ReflectionProp>;
    let rootWidget: wref<inkWidget>;
    let rootWidgetProperty: ref<ReflectionProp>;
    let subText: inkTextRef;
    let subTextProperty: ref<ReflectionProp>;

    if !IsDefined(controller) {
      return false;
    }

    owner = ToVariant(controller);
    controllerClass = Reflection.GetClassOf(owner, true);

    if !IsDefined(controllerClass) {
      return false;
    }

    rootWidgetProperty = controllerClass.GetProperty(n"rootWidget");
    radioStationNameProperty = controllerClass.GetProperty(
      n"radioStationName"
    );
    subTextProperty = controllerClass.GetProperty(n"subText");

    if !IsDefined(rootWidgetProperty)
      || !IsDefined(radioStationNameProperty)
      || !IsDefined(subTextProperty) {
      return false;
    }

    rootWidget = FromVariant<wref<inkWidget>>(
      rootWidgetProperty.GetValue(owner)
    );
    radioStationName = FromVariant<inkTextRef>(
      radioStationNameProperty.GetValue(owner)
    );
    subText = FromVariant<inkTextRef>(
      subTextProperty.GetValue(owner)
    );

    if !IsDefined(rootWidget) {
      return false;
    }

    rootWidget.SetVisible(true);

    inkTextRef.SetText(radioStationName, stationTitle);
    inkWidgetRef.SetVisible(radioStationName, true);

    inkTextRef.SetText(subText, trackTitle);
    inkWidgetRef.SetVisible(subText, true);

    return true;
  }

  public static func GetStationTitle(
    station: ref<AWRadioStationDefinition>
  ) -> String {
    let title: String;

    if !IsDefined(station) {
      return "";
    }

    title = NameToString(station.displayName);

    return title;
  }
}

@wrapMethod(VehicleSummonWidgetGameController)
private final func TryShowVehicleRadioNotification() -> Void {
  let animationOptions: inkAnimOptions;
  let dpadAction: ref<DPADActionPerformed>;
  let service: ref<AWRadioService>;
  let station: ref<AWRadioStationDefinition>;
  let stationTitle: String;
  let trackTitle: String;

  wrappedMethod();

  service = AWRadioService.Get();

  if !IsDefined(service)
    || service.GetActiveStationIndex() < 0 {
    return;
  }

  station = service.FindStationByIndex(
    service.GetActiveStationIndex()
  );
  trackTitle = service.GetCurrentTrackTitle();

  if !IsDefined(station) || Equals(trackTitle, "") {
    return;
  }

  stationTitle = AWRadioTrackNotificationHelper.GetStationTitle(
    station
  );

  if Equals(stationTitle, "") {
    return;
  }

  this.PlayAnimation(
    n"OnSongChanged",
    animationOptions,
    n"OnTimeOut"
  );

  dpadAction = new DPADActionPerformed();
  dpadAction.action = EHotkey.DPAD_RIGHT;
  dpadAction.state = EUIActionState.COMPLETED;
  this.QueueEvent(dpadAction);

  AWRadioTrackNotificationHelper.SetNotificationText(
    this,
    stationTitle,
    trackTitle
  );
}
