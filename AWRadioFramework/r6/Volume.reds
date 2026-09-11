module AWRadioFramework

public class AWRadioVolumeSettingsListener extends ConfigVarListener {
  private let m_game: GameInstance;
  private let m_isMirroring: Bool;

  public func Initialize(game: GameInstance) -> Void {
    this.m_game = game;
    this.ApplyInitialValue();
  }

  public func Start() -> Void {
    this.Register(
      n"/audio/volume"
    );
  }

  protected cb func OnVarModified(
    groupPath: CName,
    varName: CName,
    varType: ConfigVarType,
    reason: ConfigChangeReason
  ) -> Void {
    if NotEquals(
      groupPath,
      n"/audio/volume"
    ) {
      return;
    }

    if !Equals(
      varName,
      n"RadioportVolume"
    ) && !Equals(
      varName,
      n"CarRadioVolume"
    ) {
      return;
    }

    if this.m_isMirroring {
      return;
    }

    this.ApplyAndMirror(varName);
  }

  private func ApplyInitialValue() -> Void {
    let player = GetPlayer(
      this.m_game
    );

    if IsDefined(player)
      && IsDefined(
        GetMountedVehicle(player)
      ) {
      this.ApplyAndMirror(
        n"CarRadioVolume"
      );

      return;
    }

    this.ApplyAndMirror(
      n"RadioportVolume"
    );
  }

  private func ApplyAndMirror(
    sourceName: CName
  ) -> Void {
    let group: ref<ConfigGroup>;
    let service = AWRadioService.Get();
    let settings = GameInstance.GetSettingsSystem(
      this.m_game
    );
    let sourceVariable: ref<ConfigVarInt>;
    let targetName: CName;
    let targetVariable: ref<ConfigVarInt>;
    let value: Int32;

    if !IsDefined(service)
      || !IsDefined(settings) {
      return;
    }

    group = settings.GetGroup(
      n"/audio/volume"
    );

    if !IsDefined(group) {
      return;
    }

    sourceVariable = group.GetVar(
      sourceName
    ) as ConfigVarInt;

    if !IsDefined(sourceVariable) {
      return;
    }

    value = sourceVariable.GetValue();

    if Equals(
      sourceName,
      n"RadioportVolume"
    ) {
      targetName = n"CarRadioVolume";

      service.SetRadioportVolume(
        Cast<Float>(value)
      );
    } else {
      targetName = n"RadioportVolume";

      service.SetCarRadioVolume(
        Cast<Float>(value)
      );
    }

    targetVariable = group.GetVar(
      targetName
    ) as ConfigVarInt;

    if !IsDefined(targetVariable)
      || Equals(
        targetVariable.GetValue(),
        value
      ) {
      return;
    }

    this.m_isMirroring = true;

    targetVariable.SetValue(value);

    this.m_isMirroring = false;
  }
}

public class AWRadioVolumeSubSystem extends ScriptableSystem {
  private let m_listener:
    ref<AWRadioVolumeSettingsListener>;

  private func OnAttach() -> Void {
    this.m_listener =
      new AWRadioVolumeSettingsListener();

    this.m_listener.Initialize(
      this.GetGameInstance()
    );

    this.m_listener.Start();
  }

  private func OnDetach() -> Void {
    this.m_listener = null;
  }
}
