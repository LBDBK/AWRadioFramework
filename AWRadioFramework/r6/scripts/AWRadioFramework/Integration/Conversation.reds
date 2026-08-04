module AWRadioFramework

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
    if isPhoneCall {
      service.SetPhoneCallConversationRestricted(true);
    }

    if isSceneTier {
      service.SetSceneTierConversationRestricted(true);
    }
  }

  wrappedMethod(restriction, restricted);

  if !restricted && IsDefined(service) {
    if isPhoneCall {
      service.SetPhoneCallConversationRestricted(false);
    }

    if isSceneTier {
      service.SetSceneTierConversationRestricted(false);
    }
  }

  AWRadioMusicDuckBridge.SetRestrictionSuspended(
    this.IsRestricted(),
    n"pocket-radio-restriction"
  );
}

@wrapMethod(PocketRadio)
public func HandleRestrictionStateChanged() -> Void {
  let service = AWRadioService.Get();

  wrappedMethod();

  if IsDefined(service) {
    service.SetNativePocketRadioRestricted(
      this.IsRestricted()
    );

    service.SyncConversationNativeAvailability(
      this.IsRestricted()
    );
  }

  AWRadioMusicDuckBridge.SetRestrictionSuspended(
    this.IsRestricted(),
    n"pocket-radio-restriction-state"
  );
}
