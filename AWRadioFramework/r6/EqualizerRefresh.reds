module AWRadioFramework

import Codeware.*

public class AWRadioSelectedRowRefreshCallback extends DelayCallback {
  private let m_generation: Int32;
  private let m_service: wref<AWRadioSelectedRowService>;

  public static func Create(
    service: wref<AWRadioSelectedRowService>,
    generation: Int32
  ) -> ref<AWRadioSelectedRowRefreshCallback> {
    let callback = new AWRadioSelectedRowRefreshCallback();

    callback.m_service = service;
    callback.m_generation = generation;

    return callback;
  }

  public func Call() -> Void {
    if IsDefined(this.m_service) {
      this.m_service.RefreshVisibleRows(this.m_generation);
    }
  }
}

public class AWRadioSelectedRowService extends ScriptableService {
  private let m_activeRecordIndex: Int32;
  private let m_controllers:
    array<wref<RadioStationListItemController>>;
  private let m_forcedController:
    wref<RadioStationListItemController>;
  private let m_generation: Int32;

  private cb func OnInitialize() -> Void {
    this.m_activeRecordIndex = -1;
  }

  public static func Get() -> ref<AWRadioSelectedRowService> {
    return GameInstance
      .GetScriptableServiceContainer()
      .GetService(
        n"AWRadioFramework.AWRadioSelectedRowService"
      ) as AWRadioSelectedRowService;
  }

  public func Register(
    controller: wref<RadioStationListItemController>
  ) -> Void {
    let existing: wref<RadioStationListItemController>;
    let i = 0;

    if !IsDefined(controller) {
      return;
    }

    while i < ArraySize(this.m_controllers) {
      existing = this.m_controllers[i];

      if IsDefined(existing)
        && Equals(existing, controller) {
        return;
      }

      i += 1;
    }

    ArrayPush(this.m_controllers, controller);
  }

  public func SetActiveRecordIndex(
    recordIndex: Int32
  ) -> Void {
    if Equals(this.m_activeRecordIndex, recordIndex) {
      return;
    }

    this.m_activeRecordIndex = recordIndex;
  }

  public func GetActiveRecordIndex() -> Int32 {
    return this.m_activeRecordIndex;
  }

  public func IsForcedController(
    controller: wref<RadioStationListItemController>
  ) -> Bool {
    return IsDefined(controller)
      && IsDefined(this.m_forcedController)
      && Equals(controller, this.m_forcedController);
  }

  public func MarkForcedController(
    controller: wref<RadioStationListItemController>
  ) -> Void {
    this.m_forcedController = controller;
  }

  public func ClearForcedController(
    controller: wref<RadioStationListItemController>
  ) -> Void {
    if this.IsForcedController(controller) {
      this.m_forcedController = null;
    }
  }

  public func ScheduleRefresh() -> Void {
    let callback: ref<AWRadioSelectedRowRefreshCallback>;

    this.m_generation += 1;

    callback = AWRadioSelectedRowRefreshCallback.Create(
      this,
      this.m_generation
    );

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(callback, 0.10, false);
  }

  public func RefreshVisibleRows(
    generation: Int32
  ) -> Void {
    let args: array<Variant>;
    let controller:
      wref<RadioStationListItemController>;
    let controllerClass: ref<ReflectionClass>;
    let retained:
      array<wref<RadioStationListItemController>>;
    let status: Bool;
    let updateFunction: ref<ReflectionMemberFunc>;
    let i = 0;

    if NotEquals(generation, this.m_generation) {
      return;
    }

    controllerClass = Reflection.GetClass(
      n"RadioStationListItemController"
    );

    if !IsDefined(controllerClass) {
      return;
    }

    updateFunction = controllerClass.GetFunction(
      n"UpdateEquializer"
    );

    if !IsDefined(updateFunction) {
      return;
    }

    while i < ArraySize(this.m_controllers) {
      controller = this.m_controllers[i];

      if IsDefined(controller) {
        ArrayPush(retained, controller);

        status = false;
        updateFunction.Call(
          controller,
          args,
          status
        );
      }

      i += 1;
    }

    this.m_controllers = retained;
  }
}
