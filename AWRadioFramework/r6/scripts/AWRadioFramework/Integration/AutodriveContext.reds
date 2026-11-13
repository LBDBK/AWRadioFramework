module AWRadioFramework

public abstract class AWRadioAutonomousRideBridge {
  public static func Sync(
    source: CName,
    autodriveEnabled: Bool,
    cinematicCameraActive: Bool,
    delamainTaxiActive: Bool
  ) -> Void {
    let service = AWRadioService.Get();

    if IsDefined(service) {
      service.SetAutonomousRideState(
        autodriveEnabled,
        cinematicCameraActive,
        delamainTaxiActive,
        source
      );

      AWRadioMusicDuckBridge.SetRestrictionSuspended(
        service.IsRadioControlRestricted(),
        source
      );
    }
  }

  public static func SyncLiveState(source: CName) -> Void {
    let blackboardSystem = GameInstance.GetBlackboardSystem(
      GetGameInstance()
    );
    let blackboard: ref<IBlackboard>;

    if !IsDefined(blackboardSystem) {
      return;
    }

    blackboard = blackboardSystem.Get(
      GetAllBlackboardDefs().UI_AutodriveData
    );

    if !IsDefined(blackboard) {
      return;
    }

    AWRadioAutonomousRideBridge.Sync(
      source,
      blackboard.GetBool(
        GetAllBlackboardDefs().UI_AutodriveData.AutoDriveEnabled
      ),
      blackboard.GetBool(
        GetAllBlackboardDefs().UI_AutodriveData.CinematicCameraActive
      ),
      blackboard.GetBool(
        GetAllBlackboardDefs().UI_AutodriveData.AutoDriveDelamain
      )
    );
  }
}

@wrapMethod(VehicleAutodriveContextDecisions)
protected func OnStateChanged() -> Void {
  wrappedMethod();

  AWRadioAutonomousRideBridge.Sync(
    n"vehicle-autodrive-state",
    this.m_autodriveEnabled,
    this.m_cinematicCameraActive,
    this.m_delamainTaxi
  );
}

@wrapMethod(VehicleCinematicCameraContextDecisions)
protected func OnStateChanged() -> Void {
  wrappedMethod();

  AWRadioAutonomousRideBridge.Sync(
    n"vehicle-cinematic-state",
    this.m_autodriveEnabled,
    this.m_cinematicCameraActive,
    this.m_delamainTaxi
  );
}

@wrapMethod(VehicleDelamainTaxiContextDecisions)
protected func OnStateChanged() -> Void {
  wrappedMethod();

  AWRadioAutonomousRideBridge.Sync(
    n"vehicle-delamain-state",
    this.m_autodriveEnabled,
    this.m_cinematicCameraActive,
    this.m_delamainTaxi
  );
}

@wrapMethod(AutodriveAndCinematicCameraContextDecisions)
protected func OnDetach(
  const stateContext: ref<StateContext>,
  const scriptInterface: ref<StateGameScriptInterface>
) -> Void {
  wrappedMethod(stateContext, scriptInterface);

  AWRadioAutonomousRideBridge.SyncLiveState(
    n"autonomous-context-detach"
  );
}
