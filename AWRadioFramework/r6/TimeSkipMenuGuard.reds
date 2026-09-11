module AWRadioFramework

@wrapMethod(TimeskipGameController)
protected cb func OnInitialize() -> Bool {
  let service = AWRadioService.Get();

  if IsDefined(service) {
    service.SetTimeSkipMenuActive(
      true,
      n"timeskip-menu-open"
    );
  }

  return wrappedMethod();
}

@wrapMethod(TimeskipGameController)
protected cb func OnUninitialize() -> Bool {
  let service = AWRadioService.Get();

  if IsDefined(service) {
    service.SetTimeSkipMenuActive(
      false,
      n"timeskip-menu-close"
    );
  }

  return wrappedMethod();
}
