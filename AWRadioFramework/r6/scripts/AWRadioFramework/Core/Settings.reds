module AWRadioFramework

public class AWRadioFrameworkSettings extends ScriptableSystem {
  @runtimeProperty("ModSettings.mod", "AW Radio Framework")
  @runtimeProperty("ModSettings.category", "Global Settings")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Mute Ambient Music When Radio Is On")
  @runtimeProperty("ModSettings.description", "Mutes ambient and combat music while a native or AWRadioFramework station is playing. Main-menu music is never affected.")
  public let muteAmbienceWhenRadioIsOn: Bool = true;

  @runtimeProperty("ModSettings.mod", "AW Radio Framework")
  @runtimeProperty("ModSettings.category", "Global Settings")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Pocket Radio Always Available")
  @runtimeProperty("ModSettings.description", "Keeps Pocket Radio and AWRadioFramework radio controls available during normal gameplay restrictions. Loading screens, menus and session transitions are still handled normally.")
  public let pocketRadioAlwaysAvailable: Bool = false;

  @runtimeProperty("ModSettings.mod", "AW Radio Framework")
  @runtimeProperty("ModSettings.category", "AW Radio Settings")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Skip Song")
  @runtimeProperty("ModSettings.description", "Changes the Input Loader key used to skip the current AWRadioFramework track or native radio song.")
  public let AWRadioSkipSongKey: EInputKey = EInputKey.IK_L;

  @runtimeProperty("ModSettings.mod", "AW Radio Framework")
  @runtimeProperty("ModSettings.category", "AW Radio Settings")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Repeat Song")
  @runtimeProperty("ModSettings.description", "Changes the Input Loader key used to toggle repeating the current AWRadioFramework track.")
  public let AWRadioRepeatSongKey: EInputKey = EInputKey.IK_U;

  @runtimeProperty("ModSettings.mod", "AW Radio Framework")
  @runtimeProperty("ModSettings.category", "AW Radio Settings")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Controller / Gamepad Bindings")
  @runtimeProperty("ModSettings.description", "Enables fixed controller combinations: Skip Song = LB/L1 + D-Pad Right; Repeat Song = LB/L1 + D-Pad Left.")
  public let controllerGamepadBindings: Bool = false;


  public static func Get() -> ref<AWRadioFrameworkSettings> {
    return GameInstance
      .GetScriptableSystemsContainer(GetGameInstance())
      .Get(
        n"AWRadioFramework.AWRadioFrameworkSettings"
      ) as AWRadioFrameworkSettings;
  }

  public func IsMusicDuckEnabled() -> Bool {
    return this.muteAmbienceWhenRadioIsOn;
  }

  public func IsPocketRadioAlwaysAvailableEnabled() -> Bool {
    return this.pocketRadioAlwaysAvailable;
  }

  public func AreControllerGamepadBindingsEnabled() -> Bool {
    return this.controllerGamepadBindings;
  }

  private func OnAttach() -> Void {
    ModSettings.RegisterListenerToClass(this);
  }

  private func OnDetach() -> Void {
    ModSettings.UnregisterListenerToClass(this);
  }

  public cb func OnModSettingsChange() -> Void {
    let musicDuck = AWRadioMusicDuckSystem.Get();
    let service = AWRadioService.Get();

    if IsDefined(musicDuck) {
      musicDuck.OnFeatureSettingChanged(
        this.muteAmbienceWhenRadioIsOn,
        n"mod-settings"
      );
    }

    if IsDefined(service) {
      service.RefreshPocketRadioAvailability(
        n"mod-settings"
      );
    }
  }
}
