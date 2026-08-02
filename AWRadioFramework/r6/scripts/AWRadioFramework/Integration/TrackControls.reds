module AWRadioFramework

import Codeware.*

public class AWRadioTrackControlListener {
  private let m_notificationFieldsLogged: Bool;
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
    let notificationTypeRTTI: ref<ReflectionType>;
    let owner: Variant;
    let titleProperty: ref<ReflectionProp>;
    let titleRTTI: ref<ReflectionType>;

    if !IsDefined(event) {
      return false;
    }

    owner = ToVariant(event);
    eventClass = Reflection.GetClassOf(owner, true);

    if !IsDefined(eventClass) {
      FTLog(
        "[AWRadioFramework] UIInGameNotificationEvent RTTI class unavailable"
      );
      return false;
    }

    notificationTypeProperty = eventClass.GetProperty(
      n"notificationType"
    );

    if !IsDefined(notificationTypeProperty) {
      FTLog(
        "[AWRadioFramework] UIInGameNotificationEvent.notificationType RTTI property missing"
      );
      return false;
    }

    titleProperty = eventClass.GetProperty(n"title");

    if !IsDefined(titleProperty) {
      FTLog(
        "[AWRadioFramework] UIInGameNotificationEvent.title RTTI property missing"
      );
      return false;
    }

    notificationTypeRTTI = notificationTypeProperty.GetType();
    titleRTTI = titleProperty.GetType();

    if !this.m_notificationFieldsLogged {
      this.m_notificationFieldsLogged = true;

      if IsDefined(notificationTypeRTTI) {
        FTLog(
          s"[AWRadioFramework] notificationType RTTI type=\(notificationTypeRTTI.GetName())"
        );
      }

      if IsDefined(titleRTTI) {
        FTLog(
          s"[AWRadioFramework] notification title RTTI type=\(titleRTTI.GetName())"
        );
      }
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
      FTLog(
        "[AWRadioFramework] generic track-control notification not queued"
      );
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
    let service: ref<AWRadioService>;

    if !ListenerAction.IsButtonJustReleased(action) {
      return false;
    }

    actionName = ListenerAction.GetName(action);

    if !Equals(actionName, n"AWRadioSkipSong")
      && !Equals(actionName, n"AWRadioToggleRepeatSong") {
      return false;
    }

    if !IsDefined(this.m_player) {
      return false;
    }

    service = AWRadioService.Get();

    if !IsDefined(service) {
      return false;
    }

    if Equals(actionName, n"AWRadioSkipSong") {
      if !service.SkipCurrentTrack(n"input-loader") {
        return false;
      }

      this.ShowTrackControlMessage(
        s"SKIP SONG: \(service.GetCurrentTrackTitle())"
      );

      FTLog(
        s"[AWRadioFramework] input skip accepted track=\(service.GetCurrentTrackTitle())"
      );

      return true;
    }

    if !service.ToggleRepeatCurrentTrack(n"input-loader") {
      return false;
    }

    if service.IsRepeatCurrentTrackEnabled() {
      this.ShowTrackControlMessage("REPEAT SONG: ON");
    } else {
      this.ShowTrackControlMessage("REPEAT SONG: OFF");
    }

    FTLog(
      s"[AWRadioFramework] input repeat accepted enabled=\(service.IsRepeatCurrentTrackEnabled())"
    );

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

  FTLog("[AWRadioFramework] track-control input listener registered");

  return result;
}
