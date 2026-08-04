module AWRadioFramework

import Codeware.*

public abstract class AWRadioTrackUIHelper {
  public static func SetTrackText(
    controller: ref<VehicleRadioPopupGameController>,
    title: String
  ) -> Bool {
    let controllerClass: ref<ReflectionClass>;
    let trackNameProperty: ref<ReflectionProp>;
    let trackNameRef: inkTextRef;
    let trackNameValue: Variant;

    if !IsDefined(controller) {
      return false;
    }

    controllerClass = Reflection.GetClassOf(
      ToVariant(controller),
      true
    );

    if !IsDefined(controllerClass) {
      return false;
    }

    trackNameProperty = controllerClass.GetProperty(n"trackName");

    if !IsDefined(trackNameProperty) {
      return false;
    }

    trackNameValue = trackNameProperty.GetValue(
      ToVariant(controller)
    );

    trackNameRef = FromVariant<inkTextRef>(
      trackNameValue
    );

    inkTextRef.SetText(trackNameRef, title);
    inkWidgetRef.SetVisible(trackNameRef, true);
    inkWidgetRef.SetOpacity(trackNameRef, 1.0);

    return true;
  }
}

@wrapMethod(VehicleRadioPopupGameController)
private final func SetTrackName(track: CName) -> Void {
  let service = AWRadioService.Get();
  let title: String;

  wrappedMethod(track);

  if !IsDefined(service)
    || service.GetActiveStationIndex() < 0 {
    return;
  }

  title = service.GetCurrentTrackTitle();

  if Equals(title, "") {
    return;
  }

  AWRadioTrackUIHelper.SetTrackText(
    this,
    title
  );
}
