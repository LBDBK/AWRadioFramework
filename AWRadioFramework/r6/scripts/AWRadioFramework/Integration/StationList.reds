module AWRadioFramework

import Codeware.*

public abstract class AWRadioStationListHelper {
  private static func ReadRecord(
    item: ref<IScriptable>,
    recordProperty: ref<ReflectionProp>
  ) -> wref<RadioStation_Record> {
    if !IsDefined(item) || !IsDefined(recordProperty) {
      return null;
    }

    return FromVariant<wref<RadioStation_Record>>(
      recordProperty.GetValue(ToVariant(item))
    );
  }

  public static func GetRecord(
    item: ref<IScriptable>
  ) -> wref<RadioStation_Record> {
    let itemClass: ref<ReflectionClass>;
    let recordProperty: ref<ReflectionProp>;

    if !IsDefined(item) {
      return null;
    }

    itemClass = Reflection.GetClassOf(ToVariant(item), true);

    if !IsDefined(itemClass) {
      return null;
    }

    recordProperty = itemClass.GetProperty(n"record");

    if !IsDefined(recordProperty) {
      return null;
    }

    return AWRadioStationListHelper.ReadRecord(
      item,
      recordProperty
    );
  }

  public static func ContainsRecord(
    stations: array<ref<IScriptable>>,
    recordID: TweakDBID
  ) -> Bool {
    let record: wref<RadioStation_Record>;
    let i = 0;

    while i < ArraySize(stations) {
      record = AWRadioStationListHelper.GetRecord(stations[i]);

      if IsDefined(record) && Equals(record.GetID(), recordID) {
        return true;
      }

      i += 1;
    }

    return false;
  }

  private static func ReadFrequencyFromName(
    displayName: String
  ) -> Float {
    let frequencyText: String;
    let remainingName: String;

    if !StrSplitFirst(
      displayName,
      " ",
      frequencyText,
      remainingName
    ) {
      return -1.0;
    }

    return StringToFloat(frequencyText, -1.0);
  }

  private static func ReadFrequency(
    record: wref<RadioStation_Record>
  ) -> Float {
    let frequency: Float;

    if !IsDefined(record) {
      return -1.0;
    }

    frequency = AWRadioStationListHelper.ReadFrequencyFromName(
      GetLocalizedText(record.DisplayName())
    );

    if frequency >= 0.0 {
      return frequency;
    }

    return AWRadioStationListHelper.ReadFrequencyFromName(
      record.DisplayName()
    );
  }

  public static func InsertByFrequency(
    stations: array<ref<IScriptable>>,
    item: ref<IScriptable>
  ) -> array<ref<IScriptable>> {
    let result: array<ref<IScriptable>>;
    let itemRecord = AWRadioStationListHelper.GetRecord(item);
    let itemFrequency = AWRadioStationListHelper.ReadFrequency(itemRecord);
    let currentRecord: wref<RadioStation_Record>;
    let currentFrequency: Float;
    let inserted = false;
    let i = 0;

    while i < ArraySize(stations) {
      if !inserted && itemFrequency >= 0.0 {
        currentRecord = AWRadioStationListHelper.GetRecord(stations[i]);
        currentFrequency = AWRadioStationListHelper.ReadFrequency(currentRecord);

        if currentFrequency >= 0.0 && currentFrequency > itemFrequency {
          ArrayPush(result, item);
          inserted = true;
        }
      }

      ArrayPush(result, stations[i]);
      i += 1;
    }

    if !inserted {
      ArrayPush(result, item);
    }

    return result;
  }

  public static func CreateItem(
    record: ref<RadioStation_Record>
  ) -> ref<IScriptable> {
    let assignedRecord: wref<RadioStation_Record>;
    let weakRecord: wref<RadioStation_Record>;
    let item: ref<IScriptable>;
    let itemClass = Reflection.GetClass(n"RadioListItemData");
    let recordProperty: ref<ReflectionProp>;

    if !IsDefined(record) {
      return null;
    }

    if !IsDefined(itemClass) {
      return null;
    }

    item = itemClass.MakeHandle();

    if !IsDefined(item) {
      return null;
    }

    recordProperty = itemClass.GetProperty(n"record");

    if !IsDefined(recordProperty) {
      return null;
    }

    weakRecord = record;

    recordProperty.SetValue(
      ToVariant(item),
      ToVariant(weakRecord)
    );

    assignedRecord = AWRadioStationListHelper.ReadRecord(
      item,
      recordProperty
    );

    if !IsDefined(assignedRecord) {
      return null;
    }

    if NotEquals(assignedRecord.GetID(), record.GetID()) {
      return null;
    }

    return item;
  }
}

@wrapMethod(VehiclesManagerDataHelper)
public static func GetRadioStations(
  player: ref<GameObject>
) -> array<ref<IScriptable>> {
  let result = wrappedMethod(player);
  let service = AWRadioService.Get();
  let definitions: array<ref<AWRadioStationDefinition>>;
  let definition: ref<AWRadioStationDefinition>;
  let item: ref<IScriptable>;
  let record: ref<RadioStation_Record>;
  let i = 0;

  if !IsDefined(service) {
    return result;
  }

  definitions = service.GetStations();

  if Equals(ArraySize(definitions), 0) {
    return result;
  }

  while i < ArraySize(definitions) {
    definition = definitions[i];

    if IsDefined(definition)
      && !AWRadioStationListHelper.ContainsRecord(
        result,
        definition.recordID
      ) {
      record = TweakDBInterface.GetRadioStationRecord(
        definition.recordID
      );

      if IsDefined(record) {
        item = AWRadioStationListHelper.CreateItem(record);

        if IsDefined(item) {
          result = AWRadioStationListHelper.InsertByFrequency(
            result,
            item
          );
        }
      }
    }

    i += 1;
  }

  return result;
}
