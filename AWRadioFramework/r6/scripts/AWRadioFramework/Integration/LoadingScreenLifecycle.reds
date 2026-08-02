module AWRadioFramework

@wrapMethod(LoadingScreenLogicController)
protected cb func OnInitialize() -> Void {
  let service = AWRadioService.Get();

  AWRadioMusicDuckBridge.SetLoadingSuspended(
    true,
    n"loading-screen-start"
  );

  if IsDefined(service) {
    service.MuteForLoadingScreen();
  }

  wrappedMethod();
}
