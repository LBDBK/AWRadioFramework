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

  AWRadioAutonomousRideBridge.Sync(
    n"autonomous-context-detach",
    false,
    false,
    false
  );
}
