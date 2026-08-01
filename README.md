# AWRadioFramework

**AWRadioFramework** is an event-driven custom radio framework for **Cyberpunk 2077**. It allows Audioware-powered station packs to appear and behave inside the game's native Radioport and vehicle-radio interfaces.

Current framework version: **v0.7**

## What the framework provides

- Custom Audioware stations inside the native Radioport station list.
- Native `RadioListItemData` integration rather than a separate custom menu.
- Frequency-based list placement from the numeric prefix of the visible station name.
- Custom station names, internal station indexes, track titles, and optional station icons.
- Native Radioport equalizer state for custom stations.
- On-foot and mounted pause/resume through the game's normal radio controls.
- Native confirmation jingles for radio pause and resume actions.
- Accurate resume position using a local simulation-time clock.
- Automatic track advancement using the duration supplied by the station pack.
- Shared Audioware volume synchronized with both Radioport and vehicle-radio volume settings.
- Seamless mount and unmount transfer without starting a second native station.
- Isolation between native radio stations and custom Audioware stations.

The framework uses **Redscript, Codeware, TweakXL, and Audioware**. It does not require CET or Lua, and it does not use polling or `OnUpdate` loops.

## Requirements

Install versions compatible with your current Cyberpunk 2077 game build:

- RED4ext
- redscript
- Codeware
- TweakXL
- Audioware

AWRadioFramework itself does not contain music in the end-user release. At least one compatible station pack must also be installed.

## Installation

1. Install all required dependencies.
2. Extract the AWRadioFramework archive into the Cyberpunk 2077 game directory.
3. Allow the archive to place files under:

   ```text
   Cyberpunk 2077\r6\scripts\AWRadioFramework\
   ```

4. Install one or more compatible AWRadioFramework station packs.
5. Start the game with a full restart so Redscript, TweakXL, and Audioware can load the new files.

## Using the radio

A correctly installed custom station appears in the native Radioport list and in the mounted vehicle-radio flow.

The framework follows the game's normal radio controls. On a default keyboard layout, the relevant inputs are commonly:

- `Z` for on-foot Radioport pause/resume.
- `R` for mounted vehicle-radio pause/resume.
- `A` and `D` for radio volume adjustment while the relevant native radio interface is open.

Actual bindings may differ when the player changes the game's control settings.

Radioport and vehicle-radio volume represent one shared custom-radio volume. Changing either native volume setting updates the other setting without restarting the active Audioware track.

## Station list order

A station's visible name should begin with a numeric frequency:

```text
98.9 NIGHT CITY DNB
```

The numeric prefix controls where the station appears in the native radio list. For example, `98.9` is placed between `98.7` and `99.9`.

The visible frequency is not the station's internal index. The internal index must remain a unique positive whole number shared by the station's Redscript and TweakXL definitions.

Example:

```reds
AWRadioStationDefinition.Create(
  t"RadioStation.NightCityDNB",
  420,
  n"98.9 NIGHT CITY DNB",
  1.0
);
```

In this example:

- `98.9` controls visible list placement.
- `420` is the unique internal station index.

A station name without a valid numeric prefix is still retained, but it is placed after frequency-ordered stations.

## Creating a station pack

Station packs are separate from the framework and normally contain:

```text
r6\audioware\YourStation\audios.yml
r6\audioware\YourStation\tracks\...
r6\scripts\YourStation\YourStation.reds
r6\tweaks\YourStation\YourStation.yaml
archive\pc\mod\YourStation.archive       optional custom icon
```

Use the separate **AWRadioFramework Station Creator Kit** and **Station Creation Guide** for the complete workflow.

Important station-author rules:

- Use a unique TweakDB record ID.
- Use a unique positive integer station index.
- Use the same index in Redscript and TweakXL.
- Use the same visible station name in Redscript and TweakXL.
- Begin the visible name with a numeric frequency when ordered placement is desired.
- Supply the real duration of every track in seconds.
- Keep Audioware event names unique.
- Distribute only audio and artwork you have permission to distribute.
- Do not modify the framework's `Core` or `Integration` files for an individual station pack.

## Compatibility

AWRadioFramework is designed to coexist with the game's native stations and with multiple independently registered AWRadioFramework station packs.

Mods that replace the same Radioport, vehicle-radio, station-list, or radio-event methods may require compatibility work. When diagnosing an issue, test with the DEVELOPMENT build and provide the relevant Redscript and Audioware logs.

## Troubleshooting

### The framework loads but no custom station appears

- Confirm that a compatible station pack is installed.
- Confirm that the station's `.reds` and `.yaml` files use the same record ID, visible name, and internal index.
- Confirm that all required dependencies load successfully.
- Perform a full game restart after changing Redscript, TweakXL, or Audioware files.

### The station appears at the bottom

Confirm that the visible station name begins with a valid numeric value followed by a space, for example:

```text
98.9 NIGHT CITY DNB
```

Do not replace the internal integer station index with the decimal frequency.

### The station appears but produces no audio

- Confirm that Audioware loaded successfully.
- Confirm that `audios.yml` points to the correct audio files.
- Confirm that the Audioware event names exactly match the event names registered in the station's Redscript file.
- Confirm that the audio files use an Audioware-supported format and are not DRM-protected.

### Redscript compilation fails

Use the DEVELOPMENT package and inspect the first reported compiler error. Later errors are often consequences of the first unresolved type, function, or syntax error.

## Uninstallation

Remove:

```text
Cyberpunk 2077\r6\scripts\AWRadioFramework\
```

Station packs are separate mods. Remove each station pack's own Redscript, TweakXL, Audioware, audio, and optional archive files separately.

## Licence

AWRadioFramework source code and project documentation are released under the **MIT License**. See [`LICENSE`](LICENSE).

The MIT License applies only to original AWRadioFramework material distributed by the copyright holder. Cyberpunk 2077, RED4ext, redscript, Codeware, TweakXL, Audioware, third-party station packs, music, artwork, trademarks, and other third-party material remain subject to their respective owners' terms and licences.

## Disclaimer

AWRadioFramework is an unofficial community project and is not affiliated with, endorsed by, or sponsored by CD PROJEKT RED.

**Cyberpunk 2077** and related names, characters, logos, and assets are the property of their respective owners.
