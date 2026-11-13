module AWRadioFramework

@wrapMethod(AudioSystem)
public final func HandleCombatMix(
  localPlayer: ref<GameObject>
) -> Void {
  let service = AWRadioService.Get();

  wrappedMethod(localPlayer);

  if IsDefined(service) {
    service.SetAudioCombatMixActive(
      true,
      n"audio-combat-mix"
    );
  }
}

@wrapMethod(AudioSystem)
public final func HandleOutOfCombatMix(
  localPlayer: ref<GameObject>
) -> Void {
  let service = AWRadioService.Get();

  wrappedMethod(localPlayer);

  if IsDefined(service) {
    service.SetAudioCombatMixActive(
      false,
      n"audio-out-of-combat-mix"
    );
  }
}

@wrapMethod(PreventionSystem)
private func OnHeatChanged(
  previousHeat: EPreventionHeatStage
) -> Void {
  let service = AWRadioService.Get();

  wrappedMethod(previousHeat);

  if IsDefined(service) {
    service.SetPreventionHeatStage(
      EnumInt(this.GetHeatStage()),
      n"audio-prevention-heat"
    );
  }
}
