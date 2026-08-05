module AWRadioFramework

public abstract class AWRadioRestrictionBridge {
  public static func Sync(
    service: ref<AWRadioService>,
    nativeRestricted: Bool,
    source: CName
  ) -> Void {
    if !IsDefined(service) {
      AWRadioMusicDuckBridge.SetRestrictionSuspended(
        nativeRestricted,
        source
      );

      return;
    }

    service.SetNativePocketRadioRestricted(nativeRestricted);
    service.SyncConversationNativeAvailability(
      service.IsEffectiveNativePocketRadioRestricted()
    );

    AWRadioMusicDuckBridge.SetRestrictionSuspended(
      service.IsRadioControlRestricted(),
      source
    );
  }
}

@wrapMethod(PocketRadio)
public func HandleRestriction(
  restriction: PocketRadioRestrictions,
  restricted: Bool
) -> Void {
  let isPhoneCall = EnumInt(restriction)
    == EnumInt(PocketRadioRestrictions.PhoneCall);
  let isSceneTier = EnumInt(restriction)
    == EnumInt(PocketRadioRestrictions.SceneTier);
  let service = AWRadioService.Get();

  if restricted && IsDefined(service) {
    service.SetPocketRadioRestrictionState(
      restriction,
      true
    );
  }

  wrappedMethod(restriction, restricted);

  if IsDefined(service) {
    if !restricted {
      service.SetPocketRadioRestrictionState(
        restriction,
        false
      );
    }

    if isPhoneCall {
      service.SetPhoneCallConversationRestricted(
        restricted && this.IsRestricted()
      );
    }

    if isSceneTier {
      service.SetSceneTierConversationRestricted(
        restricted && this.IsRestricted()
      );
    }
  }

  AWRadioRestrictionBridge.Sync(
    service,
    this.IsRestricted(),
    n"pocket-radio-restriction"
  );

}

@wrapMethod(PocketRadio)
public func HandleRestrictionStateChanged() -> Void {
  let service = AWRadioService.Get();

  wrappedMethod();

  AWRadioRestrictionBridge.Sync(
    service,
    this.IsRestricted(),
    n"pocket-radio-restriction-state"
  );

}
