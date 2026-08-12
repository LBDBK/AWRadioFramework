# AWRadioFramework

**AWRadioFramework** is an event-driven custom radio framework for **Cyberpunk 2077**. It allows Audioware-powered station packs to appear and behave inside the game's native Radioport and vehicle-radio interfaces.

Current framework version: **v 1.4** (DEV)


## Features

- Custom Audioware stations inside the native Radioport and vehicle-radio station lists.
- Native station selection, play/pause, volume controls, selected-row state, and equalizer behaviour.
- Frequency-based station placement using the numeric prefix of the visible station name.
- Custom station names, track titles, internal indexes, gain values, and optional station icons.
- Shuffle-bag playback in which every registered track is used before the next shuffle cycle.
- Protection against immediately repeating the previous cycle's final track when a new shuffle begins.
- Native-style station and song notification whenever a custom track starts.
- Manual **Skip Song** and **Repeat Song** controls with in-game notifications.
- Shared volume between on-foot Radioport and vehicle radio.
- Seamless transfer between on-foot and mounted playback without duplicate audio.
- Native PocketRadio restriction handling for phone calls, dialogue, vendors, and other unavailable-radio states.
- Combat-music handoff while a custom track continues silently in the background.
- Optional gameplay-music ducking while a native or custom station is active.
- Safe music-volume restoration when loading, quitting to the main menu, or starting a new session.
- Restoration of the last playing custom station when the game's **Save Current Station** option is enabled.
- Support for multiple independently installed AWRadioFramework station packs.
- Isolation between native radio playback and custom Audioware playback.
- Duplicate station-index and TweakDB-record detection with a persistent main-menu warning.

## Requirements

Install versions compatible with your current Cyberpunk 2077 game build:

- RED4ext
- redscript
- Codeware
- TweakXL
- Audioware
- Mod Settings
- Input Loader

You also need at least one station pack made specifically for AWRadioFramework.

## Installation

1. Install all required dependencies.
2. Extract the AWRadioFramework archive into the main Cyberpunk 2077 directory.
3. Confirm that the framework files are installed under:

   ```text
   Cyberpunk 2077\r6\scripts\AWRadioFramework\Core\
   Cyberpunk 2077\r6\scripts\AWRadioFramework\Integration\
   Cyberpunk 2077\r6\scripts\AWRadioFramework\Radios
   Cyberpunk 2077\r6\input\AWRadioFramework.xml
   ```

4. Install one or more compatible AWRadioFramework station packs.
5. Fully restart the game.

## Controls

AWRadioFramework follows the game's native radio controls. Common default keyboard controls include:

- `Z`: play or pause the on-foot Radioport.
- Hold `Z`: open Radioport.
- `R`: play or pause the vehicle radio.
- `A` and `D`: adjust radio volume while the relevant radio interface is open.
- `L`: skip the current AWRadioFramework track.
- `U`: toggle Repeat Song for the current AWRadioFramework track.

Player bindings may differ when the game's controls have been changed.

The **Skip Song** and **Repeat Song** bindings can be changed under:

```text
Settings > Mod Settings > AW Radio Framework > AW Radio Settings
```

Skip Song and Repeat Song apply only to AWRadioFramework stations. They do not alter native station playlists.

## Creating a station pack

The recommended method is the separate **AW Radio Station Builder v0.2.2**.

The builder reads supported audio files, extracts available metadata and durations, creates the station-registration files, and packages the result into a ready-to-install ZIP.

A generated station uses this layout:

```text
r6\audioware\YourStation\audios.yml
r6\audioware\YourStation\tracks\...
r6\scripts\AWRadioFramework\Radios\YourStation\YourStation.reds
r6\tweaks\AWRadioFramework\YourStation\YourStation.yaml
README_YourStation.txt
archive\pc\mod\YourStation.archive       optional
```

The shared parent folders are intentional. Mod managers remove only the files and station-specific folders installed by a package; they should not remove another station or the framework runtime.

The builder does not generate a project JSON file.

### Station index allocation policy

For public station packs, use an index from:

```text
1000-9999
```

Indexes `0-999` are reserved by project convention for framework, development, testing, or personal use. This is an AWRadioFramework allocation policy, not a claimed engine limit.

The builder generates an index in the public range, and station authors must still verify that it is not already used by another installed station.

### Optional station icons

The builder can include an existing station archive, but it does not create Ink atlases, Ink widgets, XBM textures, or custom icon resources.

Custom icon resources must be prepared separately, packaged in the optional archive, and referenced by the station's TweakXL record.

## Station-author rules

Every station pack should follow these rules:

- Use a unique TweakDB record ID.
- Use a unique station index.
- Use the same station index in Redscript and TweakXL.
- Use the same visible station name in Redscript and TweakXL.
- Use the public `1000-9999` range for released station packs.
- Begin the visible name with a numeric frequency when ordered placement is required.
- Use unique Audioware event names for every track.
- Provide a valid duration for every registered track.
- Keep station Redscript under `r6\scripts\AWRadioFramework\Radios\<Station>\`.
- Keep station files out of the framework's `Core` and `Integration` folders.
- Distribute only music, audio, artwork, and other assets you have permission to distribute.

Do not edit AWRadioFramework runtime files for an individual station pack. Station-specific definitions belong in the station pack's own Redscript, TweakXL, Audioware, and optional archive paths.

For the full registration format and manual examples, see `STATION_CREATION_GUIDE.md`.

## Compatibility

AWRadioFramework is designed to coexist with:

- The game's native radio stations.
- Multiple AWRadioFramework station packs.
- Normal on-foot and mounted Radioport behaviour.

Station packs made for another custom-radio framework are not automatically compatible with AWRadioFramework.

## Troubleshooting

### No custom station appears

- Confirm that a compatible AWRadioFramework station pack is installed.
- Confirm that the station Redscript is under `r6\scripts\AWRadioFramework\Radios\<Station>\`.
- Confirm that the TweakXL file is under `r6\tweaks\AWRadioFramework\<Station>\`.
- Confirm that the station's `.reds` and `.yaml` files use the same record ID, visible name, and internal index.
- Check whether the main menu shows a duplicate-station warning.
- Confirm that all required dependencies load successfully.
- Check the first Redscript compiler error.
- Perform a full game restart.

### Only one of two stations appears

The second station may have been rejected because both packs use the same internal index or TweakDB record.

Read the persistent main-menu warning, update the conflicting station's Redscript and TweakXL definitions, and restart the game.

### The station icon is missing

- Confirm that the archive containing the icon resources is installed.
- Confirm that the TweakXL icon reference points to an existing record or flat.
- Confirm that the Ink widget, atlas, texture part, and XBM paths match exactly.
- Check the TweakXL log for a non-existent record or flat warning.

### The station appears but produces no audio

- Confirm that Audioware loaded successfully.
- Confirm that `r6\audioware\<Station>\audios.yml` points to the correct files.
- Confirm that the Audioware event names match the station's Redscript definitions exactly.
- Confirm that the audio files are in `r6\audioware\<Station>\tracks\` or the paths declared by the manifest.
- Confirm that the audio format is supported by Audioware.
- Confirm that the audio files are not DRM-protected.
- Confirm that the station gain is greater than `0.0`.

### The station is much louder or quieter than vanilla

The final output volume is the station gain multiplied by the shared Radioport or vehicle-radio volume.

Use `0.30` as a reasonable starting point, compare against several vanilla stations at the same volume, and adjust the station gain gradually.

The framework clamps gain between `0.0` and `2.0`.

### Track titles do not update

- Confirm that every track has a non-empty title in the station definition.
- Confirm that the registered duration is valid.
- Regenerate the station using the current builder.
- Check for another mod replacing the Radioport track UI or notification methods.

### Skip Song or Repeat Song does not work

- Confirm that Input Loader is installed and loaded.
- Confirm that Mod Settings is installed.
- Check the configured bindings under **AW Radio Settings**.
- Test another key if the current binding is already used by the game or another mod.
- Skip is unavailable while playback is paused or suspended.

### The station remains silent during a vendor, call, dialogue, or combat state

This may be intended while the native Radioport remains restricted or while combat handoff is active.

Wait until the native Radioport becomes available again. The framework follows the game's aggregate restriction state and normal unlock delay rather than restoring audio immediately after an individual restriction flag changes.

### The station does not restore after loading a save

- Enable the game's **Save Current Station** option.
- Confirm that the station pack is still installed.
- Confirm that its internal station index has not changed.
- Confirm that the station was playing rather than manually paused before leaving the previous session.
- Allow the gameplay session a moment to finish initializing.

### Main-menu music is muted

- Disable and re-enable **Mute Ambient Music When Radio Is On** to force a settings refresh.
- Fully quit and restart the game.
- Check for another mod changing the game's `MusicVolume` setting.

### Redscript compilation fails

Read the first compiler error first. Later errors are often consequences of the first unresolved type, function, file, or syntax issue.

When reporting a framework issue, include:

- The exact AWRadioFramework version.
- The station pack used (no songs needed).
- Relevant Audioware and TweakXL log entries.
- The exact steps needed to reproduce the issue.
- Whether the issue also occurs with other radio-related mods removed.

## Uninstallation

Remove the framework runtime files:

```text
Cyberpunk 2077\r6\scripts\AWRadioFramework\Core\
Cyberpunk 2077\r6\scripts\AWRadioFramework\Integration\
Cyberpunk 2077\r6\input\AWRadioFramework.xml
```

Remove each station pack's own files, commonly:

```text
Cyberpunk 2077\r6\scripts\AWRadioFramework\Radios\<Station>\
Cyberpunk 2077\r6\tweaks\AWRadioFramework\<Station>\
Cyberpunk 2077\r6\audioware\<Station>\
Cyberpunk 2077\archive\pc\mod\<Station>.archive
```

Remove only the station-specific folders and files installed by that station pack. Do not delete the shared `AWRadioFramework`, `Radios`, `tweaks\AWRadioFramework`, or `audioware` parent folders when they still contain other installed content.

## Licence

AWRadioFramework source code and project documentation are released under the **MIT License**. See [`LICENSE`](LICENSE).

The MIT License applies only to original AWRadioFramework material distributed by the copyright holder.

Cyberpunk 2077, RED4ext, redscript, Codeware, TweakXL, Audioware, Mod Settings, Input Loader, third-party station packs, music, artwork, trademarks, and other third-party material remain subject to their respective owners' terms and licences.

## Disclaimer

AWRadioFramework is an unofficial community project and is not affiliated with, endorsed by, or sponsored by CD PROJEKT RED.

**Cyberpunk 2077** and related names, characters, logos, and assets are the property of their respective owners.
