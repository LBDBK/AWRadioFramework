module AWRadioFramework

public abstract class AWRadioPocketRadioAvailability {
  public static func IsEnabled() -> Bool {
    let settings = AWRadioFrameworkSettings.Get();

    return IsDefined(settings)
      && settings.IsPocketRadioAlwaysAvailableEnabled();
  }
}

@wrapMethod(PocketRadio)
public func IsRestricted() -> Bool {
  if AWRadioPocketRadioAvailability.IsEnabled() {
    return false;
  }

  return wrappedMethod();
}

@wrapMethod(PocketRadio)
public func IsRestrictionOverwritten() -> Bool {
  if AWRadioPocketRadioAvailability.IsEnabled() {
    return true;
  }

  return wrappedMethod();
}
