module AWRadioFramework

@wrapMethod(LoadingScreenLogicController)
protected cb func OnInitialize() -> Void {
  let service = AWRadioService.Get();

  if IsDefined(service)
    && service.MuteForLoadingScreen() {
  }

  wrappedMethod();
}
