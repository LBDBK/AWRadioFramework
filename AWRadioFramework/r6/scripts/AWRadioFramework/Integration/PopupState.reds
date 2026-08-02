module AWRadioFramework

import Codeware.*

public abstract class AWRadioPopupStateHelper {

  private static func GetNumericProperty(
    controller: ref<VehicleRadioPopupGameController>,
    propertyName: CName
  ) -> Int32 {
    let controllerClass: ref<ReflectionClass>;
    let owner: Variant;
    let property: ref<ReflectionProp>;
    let propertyType: ref<ReflectionType>;
    let typeName: CName;

    if !IsDefined(controller) {
      return -1;
    }

    owner = ToVariant(controller);

    controllerClass = Reflection.GetClassOf(
      owner,
      true
    );

    if !IsDefined(controllerClass) {
      return -1;
    }

    property = controllerClass.GetProperty(propertyName);

    if !IsDefined(property) {
      return -1;
    }

    propertyType = property.GetType();

    if !IsDefined(propertyType) {
      return -1;
    }

    typeName = propertyType.GetName();

    if Equals(typeName, n"Uint32") {
      return Cast<Int32>(
        FromVariant<Uint32>(
          property.GetValue(owner)
        )
      );
    }

    if Equals(typeName, n"Int32") {
      return FromVariant<Int32>(
        property.GetValue(owner)
      );
    }

    if Equals(typeName, n"Uint16") {
      return Cast<Int32>(
        FromVariant<Uint16>(
          property.GetValue(owner)
        )
      );
    }

    if Equals(typeName, n"Int16") {
      return Cast<Int32>(
        FromVariant<Int16>(
          property.GetValue(owner)
        )
      );
    }

    return -1;
  }

  private static func SetNumericProperty(
    controller: ref<VehicleRadioPopupGameController>,
    propertyName: CName,
    value: Int32
  ) -> Bool {
    let controllerClass: ref<ReflectionClass>;
    let owner: Variant;
    let property: ref<ReflectionProp>;
    let propertyType: ref<ReflectionType>;
    let typeName: CName;

    let int16Value: Int16;
    let int32Value: Int32;
    let uint16Value: Uint16;
    let uint32Value: Uint32;

    let verifiedInt16: Int16;
    let verifiedInt32: Int32;
    let verifiedUint16: Uint16;
    let verifiedUint32: Uint32;

    if !IsDefined(controller) {
      return false;
    }

    owner = ToVariant(controller);

    controllerClass = Reflection.GetClassOf(
      owner,
      true
    );

    if !IsDefined(controllerClass) {
      return false;
    }

    property = controllerClass.GetProperty(propertyName);

    if !IsDefined(property) {

      return false;
    }

    propertyType = property.GetType();

    if !IsDefined(propertyType) {

      return false;
    }

    typeName = propertyType.GetName();

    if Equals(typeName, n"Uint32") {
      uint32Value = Cast<Uint32>(value);

      property.SetValue(
        owner,
        ToVariant(uint32Value)
      );

      verifiedUint32 = FromVariant<Uint32>(
        property.GetValue(owner)
      );

      if Equals(verifiedUint32, uint32Value) {
        return true;
      }
    } else {
      if Equals(typeName, n"Int32") {
        int32Value = value;

        property.SetValue(
          owner,
          ToVariant(int32Value)
        );

        verifiedInt32 = FromVariant<Int32>(
          property.GetValue(owner)
        );

        if Equals(verifiedInt32, int32Value) {
          return true;
        }
      } else {
        if Equals(typeName, n"Uint16") {
          uint16Value = Cast<Uint16>(value);

          property.SetValue(
            owner,
            ToVariant(uint16Value)
          );

          verifiedUint16 = FromVariant<Uint16>(
            property.GetValue(owner)
          );

          if Equals(verifiedUint16, uint16Value) {
            return true;
          }
        } else {
          if Equals(typeName, n"Int16") {
            int16Value = Cast<Int16>(value);

            property.SetValue(
              owner,
              ToVariant(int16Value)
            );

            verifiedInt16 = FromVariant<Int16>(
              property.GetValue(owner)
            );

            if Equals(verifiedInt16, int16Value) {
              return true;
            }
          } else {

            return false;
          }
        }
      }
    }

    return false;
  }

  public static func RestoreActiveStation(
    controller: ref<VehicleRadioPopupGameController>
  ) -> Void {
    let activeIndex: Int32;
    let itemRecord: wref<RadioStation_Record>;
    let stations: array<ref<IScriptable>>;
    let service = AWRadioService.Get();
    let player = GetPlayer(GetGameInstance());
    let i = 0;

    if !IsDefined(service) || !IsDefined(player) {
      return;
    }

    activeIndex = service.GetActiveStationIndex();

    if activeIndex < 0 {
      return;
    }

    stations = VehiclesManagerDataHelper.GetRadioStations(player);

    while i < ArraySize(stations) {
      itemRecord = AWRadioStationListHelper.GetRecord(stations[i]);

      if IsDefined(itemRecord)
        && Equals(itemRecord.Index(), activeIndex) {

        AWRadioPopupStateHelper.SetNumericProperty(
          controller,
          n"startupIndex",
          i
        );

        AWRadioPopupStateHelper.SetNumericProperty(
          controller,
          n"currentRadioId",
          activeIndex
        );

        return;
      }

      i += 1;
    }

  }
  public static func CaptureSelectedRecord(
    controller: ref<VehicleRadioPopupGameController>
  ) -> Void {
    let record: wref<RadioStation_Record>;
    let startupIndex = AWRadioPopupStateHelper.GetNumericProperty(
      controller,
      n"startupIndex"
    );
    let state = AWRadioSelectedRowService.Get();
    let stations: array<ref<IScriptable>>;
    let player = GetPlayer(GetGameInstance());

    if !IsDefined(state)
      || !IsDefined(player)
      || startupIndex < 0 {
      return;
    }

    stations = VehiclesManagerDataHelper.GetRadioStations(
      player
    );

    if startupIndex >= ArraySize(stations) {

      return;
    }

    record = AWRadioStationListHelper.GetRecord(
      stations[startupIndex]
    );

    if !IsDefined(record) {

      return;
    }

    let service = AWRadioService.Get();

    if IsDefined(service)
      && service.HasActivePlayback()
      && service.IsPlaybackPaused() {
      state.SetActiveRecordIndex(-1);

    } else {
      state.SetActiveRecordIndex(
        record.Index()
      );
    }

  }

}

@wrapMethod(VehicleRadioPopupGameController)
private final func SetupData() -> Void {
  let selectedRowState = AWRadioSelectedRowService.Get();

  wrappedMethod();

  AWRadioPopupStateHelper.RestoreActiveStation(this);
  AWRadioPopupStateHelper.CaptureSelectedRecord(this);

  if IsDefined(selectedRowState) {
    selectedRowState.ScheduleRefresh();
  }
}
