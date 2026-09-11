module AWRadioFramework

public class AWRadioTrackDefinition {
  public let eventName: CName;
  public let title: String;
  public let duration: Float;

  public static func Create(
    eventName: CName,
    title: String,
    duration: Float
  ) -> ref<AWRadioTrackDefinition> {
    let track = new AWRadioTrackDefinition();

    track.eventName = eventName;
    track.title = title;
    track.duration = MaxF(duration, 0.10);

    return track;
  }
}

public class AWRadioStationDefinition {
  public let recordID: TweakDBID;
  public let index: Int32;
  public let displayName: CName;
  public let gain: Float;
  public let tracks: array<ref<AWRadioTrackDefinition>>;

  public static func Create(
    recordID: TweakDBID,
    index: Int32,
    displayName: CName,
    gain: Float
  ) -> ref<AWRadioStationDefinition> {
    let station = new AWRadioStationDefinition();

    station.recordID = recordID;
    station.index = index;
    station.displayName = displayName;
    station.gain = ClampF(gain, 0.0, 2.0);

    return station;
  }

  public func AddTrack(track: ref<AWRadioTrackDefinition>) -> Void {
    if IsDefined(track) {
      ArrayPush(this.tracks, track);
    }
  }
}
