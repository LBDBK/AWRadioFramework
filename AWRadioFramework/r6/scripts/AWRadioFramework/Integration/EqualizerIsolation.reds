module AWRadioFramework

import Codeware.*

public abstract class AWRadioSelectedRowUI {
  private static func GetProperty(
    controllerClass: ref<ReflectionClass>,
    propertyName: CName
  ) -> ref<ReflectionProp> {
    if !IsDefined(controllerClass) {
      return null;
    }

    return controllerClass.GetProperty(propertyName);
  }

  private static func GetControllerClass(
    controller: ref<RadioStationListItemController>
  ) -> ref<ReflectionClass> {
    if !IsDefined(controller) {
      return null;
    }

    return Reflection.GetClassOf(
      ToVariant(controller),
      true
    );
  }

  private static func GetStationData(
    controller: ref<RadioStationListItemController>,
    controllerClass: ref<ReflectionClass>
  ) -> ref<RadioListItemData> {
    let property = AWRadioSelectedRowUI.GetProperty(
      controllerClass,
      n"stationData"
    );

    if !IsDefined(property) {
      return null;
    }

    return FromVariant<ref<RadioListItemData>>(
      property.GetValue(ToVariant(controller))
    );
  }

  private static func GetRecord(
    controller: ref<RadioStationListItemController>,
    controllerClass: ref<ReflectionClass>
  ) -> wref<RadioStation_Record> {
    let stationData = AWRadioSelectedRowUI.GetStationData(
      controller,
      controllerClass
    );

    if !IsDefined(stationData) {
      return null;
    }

    return AWRadioStationListHelper.GetRecord(stationData);
  }

  private static func ApplyWidgetState(
    widgetRef: inkWidgetRef,
    visible: Bool
  ) -> Void {
    inkWidgetRef.SetVisible(
      widgetRef,
      visible
    );

    if visible {
      inkWidgetRef.SetOpacity(
        widgetRef,
        1.0
      );
    }
  }

  private static func SetWidgetState(
    controller: ref<RadioStationListItemController>,
    controllerClass: ref<ReflectionClass>,
    propertyName: CName,
    visible: Bool
  ) -> Bool {
    let compoundRef: inkCompoundRef;
    let horizontalPanelRef: inkHorizontalPanelRef;
    let imageRef: inkImageRef;
    let property = AWRadioSelectedRowUI.GetProperty(
      controllerClass,
      propertyName
    );
    let propertyType: ref<ReflectionType>;
    let textRef: inkTextRef;
    let typeName: CName;
    let value: Variant;
    let widgetRef: inkWidgetRef;

    if !IsDefined(property) {
      return false;
    }

    propertyType = property.GetType();

    if !IsDefined(propertyType) {
      return false;
    }

    typeName = propertyType.GetName();
    value = property.GetValue(ToVariant(controller));

    if Equals(typeName, n"inkWidgetReference") {
      widgetRef = FromVariant<inkWidgetRef>(value);

      AWRadioSelectedRowUI.ApplyWidgetState(
        widgetRef,
        visible
      );

      return true;
    }

    if Equals(typeName, n"inkImageWidgetReference") {
      imageRef = FromVariant<inkImageRef>(value);

      AWRadioSelectedRowUI.ApplyWidgetState(
        imageRef,
        visible
      );

      return true;
    }

    if Equals(typeName, n"inkTextWidgetReference") {
      textRef = FromVariant<inkTextRef>(value);

      AWRadioSelectedRowUI.ApplyWidgetState(
        textRef,
        visible
      );

      return true;
    }

    if Equals(typeName, n"inkHorizontalPanelWidgetReference") {
      horizontalPanelRef = FromVariant<inkHorizontalPanelRef>(value);

      AWRadioSelectedRowUI.ApplyWidgetState(
        horizontalPanelRef,
        visible
      );

      return true;
    }

    if Equals(typeName, n"inkCompoundWidgetReference") {
      compoundRef = FromVariant<inkCompoundRef>(value);

      AWRadioSelectedRowUI.ApplyWidgetState(
        compoundRef,
        visible
      );

      return true;
    }

    return false;
  }

  private static func ClearForcedRow(
    controller: ref<RadioStationListItemController>,
    controllerClass: ref<ReflectionClass>,
    state: ref<AWRadioSelectedRowService>
  ) -> Void {
    let codeSet = AWRadioSelectedRowUI.SetWidgetState(
      controller,
      controllerClass,
      n"codeTLicon",
      true
    );
    let equalizerSet = AWRadioSelectedRowUI.SetWidgetState(
      controller,
      controllerClass,
      n"equilizerIcon",
      false
    );

    if codeSet && equalizerSet {
      state.ClearForcedController(controller);

    }
  }

  public static func Update(
    controller: ref<RadioStationListItemController>,
    state: ref<AWRadioSelectedRowService>
  ) -> Void {
    let activeRecordIndex: Int32;
    let codeSet: Bool;
    let controllerClass: ref<ReflectionClass>;
    let equalizerSet: Bool;
    let record: wref<RadioStation_Record>;

    if !IsDefined(controller) || !IsDefined(state) {
      return;
    }

    controllerClass = AWRadioSelectedRowUI.GetControllerClass(
      controller
    );

    if !IsDefined(controllerClass) {
      return;
    }

    activeRecordIndex = state.GetActiveRecordIndex();
    record = AWRadioSelectedRowUI.GetRecord(
      controller,
      controllerClass
    );

    if !IsDefined(record) {
      return;
    }

    if activeRecordIndex < 0 {
      if state.IsForcedController(controller) {
        AWRadioSelectedRowUI.ClearForcedRow(
          controller,
          controllerClass,
          state
        );
      }

      return;
    }

    if NotEquals(record.Index(), activeRecordIndex) {
      if state.IsForcedController(controller) {
        AWRadioSelectedRowUI.ClearForcedRow(
          controller,
          controllerClass,
          state
        );
      }

      return;
    }

    equalizerSet = AWRadioSelectedRowUI.SetWidgetState(
      controller,
      controllerClass,
      n"equilizerIcon",
      true
    );

    codeSet = AWRadioSelectedRowUI.SetWidgetState(
      controller,
      controllerClass,
      n"codeTLicon",
      false
    );

    if equalizerSet && codeSet {
      state.MarkForcedController(controller);

    }
  }
}

@wrapMethod(RadioStationListItemController)
private final func UpdateEquializer() -> Void {
  let state = AWRadioSelectedRowService.Get();

  if IsDefined(state) {
    state.Register(this);
  }

  wrappedMethod();

  AWRadioSelectedRowUI.Update(
    this,
    state
  );
}
