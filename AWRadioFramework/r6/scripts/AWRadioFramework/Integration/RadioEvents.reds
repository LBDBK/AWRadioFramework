module AWRadioFramework

public abstract class AWRadioPocketStateBridge {
  public static func QueueState(
    toggle: Bool,
    setStation: Bool,
    station: Int32
  ) -> Void {
    let event: ref<VehicleRadioEvent>;
    let player = GetPlayer(GetGameInstance());

    if !IsDefined(player) {
      return;
    }

    event = new VehicleRadioEvent();
    event.toggle = toggle;
    event.setStation = setStation;
    event.station = station;

    player.QueueEvent(event);

  }
}

@wrapMethod(QuickSlotsManager)
public final func SendRadioEvent(
  toggle: Bool,
  setStation: Bool,
  station: Int32
) -> Void {
  let activeIndex: Int32;
  let savedStationState = AWRadioSavedStationSystem.Get();
  let selectedRowState = AWRadioSelectedRowService.Get();
  let service = AWRadioService.Get();
  let selectedRecordIndex = -1;

  if toggle && setStation {
    selectedRecordIndex = station;
  }

  if IsDefined(selectedRowState) {
    selectedRowState.SetActiveRecordIndex(
      selectedRecordIndex
    );
  }

  if IsDefined(service) {
    if service.IsCustomStation(station) {
      if IsDefined(savedStationState) {
        savedStationState.RecordCustomRadioEvent(
          toggle,
          setStation,
          station
        );
      }

      activeIndex = service.GetActiveStationIndex();

      if toggle && NotEquals(activeIndex, station) {

        wrappedMethod(false, false, -1);
      }

      if !toggle || NotEquals(activeIndex, station) {
        AWRadioPocketStateBridge.QueueState(
          toggle,
          setStation,
          station
        );
      }

      if service.HandleRadioEvent(toggle, setStation, station) {
        if IsDefined(selectedRowState) {
          selectedRowState.ScheduleRefresh();
        }

        AWRadioMusicDuckBridge.SetRadioPlaying(
          service.IsPlaybackRunning(),
          n"quickslots-custom"
        );

        return;
      }
    } else {
      if IsDefined(savedStationState) {
        if !toggle && service.HasActivePlayback() {
          savedStationState.RecordPlaybackState(false);
        } else {
          savedStationState.RecordNativeRadioEvent(
            toggle,
            setStation,
            station
          );
        }
      }

      service.ReleaseForNativeRadio();
    }
  }

  wrappedMethod(toggle, setStation, station);

  AWRadioMusicDuckBridge.SetRadioPlaying(
    toggle,
    n"quickslots-native"
  );

  if IsDefined(selectedRowState) {
    selectedRowState.ScheduleRefresh();
  }
}
