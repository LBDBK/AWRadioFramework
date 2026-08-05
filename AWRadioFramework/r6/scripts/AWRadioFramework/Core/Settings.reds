module AWRadioFramework

public class AWRadioFrameworkSettings extends ScriptableSystem {
  @runtimeProperty("ModSettings.mod", "AW Radio Framework")
  @runtimeProperty("ModSettings.category", "Global Settings")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Mute Ambient Music When Radio Is On")
  @runtimeProperty("ModSettings.description", "Mutes ambient and combat music while a native or AWRadioFramework station is playing. Main-menu music is never affected.")
  public let muteAmbienceWhenRadioIsOn: Bool = true;

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
  @runtimeProperty("ModSettings.description", "Enables separate controller or gamepad bindings for Skip Song and Repeat Song.")
  public let controllerGamepadBindings: Bool = false;

  @runtimeProperty("ModSettings.mod", "AW Radio Framework")
  @runtimeProperty("ModSettings.category", "AW Radio Settings")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Skip Song - Controller / Gamepad (Hold)")
  @runtimeProperty("ModSettings.description", "Changes the controller or gamepad button that must be held to skip the current AWRadioFramework track or native radio song.")
  @runtimeProperty("ModSettings.dependency", "controllerGamepadBindings")
  public let AWRadioSkipSongControllerKey: EInputKey = EInputKey.IK_Pad_LeftShoulder;

  @runtimeProperty("ModSettings.mod", "AW Radio Framework")
  @runtimeProperty("ModSettings.category", "AW Radio Settings")
  @runtimeProperty("ModSettings.category.order", "2")
  @runtimeProperty("ModSettings.displayName", "Repeat Song - Controller / Gamepad")
  @runtimeProperty("ModSettings.description", "Changes the controller or gamepad button used to toggle repeating the current AWRadioFramework track.")
  @runtimeProperty("ModSettings.dependency", "controllerGamepadBindings")
  public let AWRadioRepeatSongControllerKey: EInputKey = EInputKey.IK_Pad_DigitLeft;

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

    if IsDefined(musicDuck) {
      musicDuck.OnFeatureSettingChanged(
        this.muteAmbienceWhenRadioIsOn,
        n"mod-settings"
      );
    }
  }
}
