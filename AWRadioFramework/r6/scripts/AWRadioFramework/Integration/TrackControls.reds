module AWRadioFramework

import Codeware.*

public class AWRadioTrackControlListener {
  private let m_player: wref<PlayerPuppet>;

  public func Initialize(player: wref<PlayerPuppet>) -> Void {
    this.m_player = player;
  }

  private func ConfigureGenericNotification(
    event: ref<UIInGameNotificationEvent>,
    message: String
  ) -> Bool {
    let eventClass: ref<ReflectionClass>;
    let notificationType: UIInGameNotificationType;
    let notificationTypeProperty: ref<ReflectionProp>;
    let owner: Variant;
    let titleProperty: ref<ReflectionProp>;

    if !IsDefined(event) {
      return false;
    }

    owner = ToVariant(event);
    eventClass = Reflection.GetClassOf(owner, true);

    if !IsDefined(eventClass) {
      return false;
    }

    notificationTypeProperty = eventClass.GetProperty(
      n"notificationType"
    );

    if !IsDefined(notificationTypeProperty) {
      return false;
    }

    titleProperty = eventClass.GetProperty(n"title");

    if !IsDefined(titleProperty) {
      return false;
    }

    notificationType = UIInGameNotificationType.GenericNotification;

    notificationTypeProperty.SetValue(
      owner,
      ToVariant(notificationType)
    );

    titleProperty.SetValue(
      owner,
      ToVariant(message)
    );

    return true;
  }

  private func ShowTrackControlMessage(message: String) -> Void {
    let event: ref<UIInGameNotificationEvent>;

    if !IsDefined(this.m_player) {
      return;
    }

    event = new UIInGameNotificationEvent();

    if !this.ConfigureGenericNotification(event, message) {
      return;
    }

    GameInstance
      .GetUISystem(this.m_player.GetGame())
      .QueueEvent(event);
  }

  protected cb func OnAction(
    action: ListenerAction,
    consumer: ListenerActionConsumer
  ) -> Bool {
    let actionName: CName;
    let controllerAction: Bool;
    let nativeSkip: ref<AWNativeRadioSkipService>;
    let nativeTrackTitle: String;
    let result: Bool;
    let service: ref<AWRadioService>;
    let settings: ref<AWRadioFrameworkSettings>;

    actionName = ListenerAction.GetName(action);

    controllerAction = Equals(
      actionName,
      n"AWRadioSkipSongController"
    ) || Equals(
      actionName,
      n"AWRadioToggleRepeatSongController"
    );

    if controllerAction {
      settings = AWRadioFrameworkSettings.Get();

      if !IsDefined(settings)
        || !settings.AreControllerGamepadBindingsEnabled() {
        return false;
      }

      if !ListenerAction.IsButtonJustReleased(action) {
        return false;
      }

      if Equals(actionName, n"AWRadioSkipSongController") {
        actionName = n"AWRadioSkipSong";
      } else {
        actionName = n"AWRadioToggleRepeatSong";
      }
    } else {
      if !ListenerAction.IsButtonJustReleased(action) {
        return false;
      }

      if !Equals(actionName, n"AWRadioSkipSong")
        && !Equals(actionName, n"AWRadioToggleRepeatSong") {
        return false;
      }
    }

    if !IsDefined(this.m_player) {
      return false;
    }

    service = AWRadioService.Get();

    if !IsDefined(service) {
      return false;
    }

    if service.IsRadioControlRestricted() {
      return false;
    }

    if Equals(actionName, n"AWRadioSkipSong") {
      if service.HasActivePlayback() {
        result = service.SkipCurrentTrack(n"input-loader");

        if !result {
          return false;
        }

        this.ShowTrackControlMessage(
          s"SKIP SONG: \(service.GetCurrentTrackTitle())"
        );

        return true;
      }

      nativeSkip = AWNativeRadioSkipService.Get();

      if !IsDefined(nativeSkip) {
        result = false;
      } else {
        result = nativeSkip.TrySkip(this.m_player);
      }

      if !result {
        return false;
      }

      nativeTrackTitle =
        nativeSkip.GetLastSkippedTrackTitle();

      if Equals(nativeTrackTitle, "") {
        this.ShowTrackControlMessage("SKIP SONG");
      } else {
        this.ShowTrackControlMessage(
          s"SKIP SONG: \(nativeTrackTitle)"
        );
      }

      return true;
    }

    result = service.ToggleRepeatCurrentTrack(n"input-loader");

    if !result {
      return false;
    }

    if service.IsRepeatCurrentTrackEnabled() {
      this.ShowTrackControlMessage("REPEAT SONG: ON");
    } else {
      this.ShowTrackControlMessage("REPEAT SONG: OFF");
    }

    return true;
  }
}

@addField(PlayerPuppet)
private let m_awRadioTrackControlListener: ref<AWRadioTrackControlListener>;

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool = wrappedMethod();
  let listener: ref<AWRadioTrackControlListener>;

  if IsDefined(this.m_awRadioTrackControlListener) {
    return result;
  }

  listener = new AWRadioTrackControlListener();
  listener.Initialize(this);
  this.m_awRadioTrackControlListener = listener;

  this.RegisterInputListener(
    listener,
    n"AWRadioSkipSong"
  );

  this.RegisterInputListener(
    listener,
    n"AWRadioToggleRepeatSong"
  );

  this.RegisterInputListener(
    listener,
    n"AWRadioSkipSongController"
  );

  this.RegisterInputListener(
    listener,
    n"AWRadioToggleRepeatSongController"
  );

  return result;
}
