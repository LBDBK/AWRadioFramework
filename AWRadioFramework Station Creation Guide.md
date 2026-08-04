# AWRadioFramework Station Creation Guide

This guide explains how to create and package a custom Cyberpunk 2077 radio station for **AWRadioFramework** using **AW Radio Station Builder v0.1**.

The Builder is the recommended workflow. It creates the Audioware manifest, Redscript station provider, TweakXL station record, packaged folder structure, and station README. Manual editing is still documented later for authors who need to inspect or adjust generated files.

AWRadioFramework itself provides the radio runtime. A station pack provides the music, metadata, station registration, and optional icon assets.

---

## 1. Before you begin

Install AWRadioFramework and versions of these dependencies compatible with your current Cyberpunk 2077 game build:

- RED4ext
- redscript
- Codeware
- TweakXL
- Audioware
- Mod Settings
- Input Loader

You also need:

- **AW Radio Station Builder v0.1**
- One or more supported audio files
- Permission to distribute every audio file and artwork asset included in the station pack

Supported song formats:

```text
.wav
.ogg
.mp3
.flac
```

Recommended audio preparation:

- Use stereo audio.
- Use 44.1 kHz or 48 kHz.
- Avoid DRM-protected files.
- Use simple file names containing letters, numbers, and underscores.
- Avoid characters that complicate paths or metadata, such as `#`, `:`, `?`, and quotation marks.

Examples:

```text
neon_velocity.flac
artist_track_01.mp3
night_drive.wav
```

---

## 2. What the Builder creates

AW Radio Station Builder v0.1:

- Reads supported audio files.
- Extracts available metadata.
- Reads each track's real duration.
- Creates the Audioware `audios.yml` manifest.
- Creates the station Redscript provider.
- Creates the station TweakXL record.
- Copies the selected audio files into the station package.
- Can include an existing optional station archive.
- Generates a ready-to-install ZIP.
- Generates station documentation.

The Builder does **not** create custom icon assets such as:

- `.inkatlas`
- `.inkwidget`
- `.xbm`
- `.archive` resources

It can include an archive you already prepared, but it does not build those resources for you.

The Builder does **not** generate a project JSON file. JSON generation and its old checkbox were removed in v0.2.2.

---

## 3. Generated station layout

A generated station uses this structure:

```text
r6
├─ audioware
│  └─ YourStation
│     ├─ audios.yml
│     └─ tracks
│        ├─ track_01.flac
│        ├─ track_02.mp3
│        └─ track_03.ogg
├─ scripts
│  └─ AWRadioFramework
│     └─ Radios
│        └─ YourStation
│           └─ YourStation.reds
└─ tweaks
   └─ AWRadioFramework
      └─ YourStation
         └─ YourStation.yaml

README_YourStation.txt

archive
└─ pc
   └─ mod
      └─ YourStation.archive          optional
```

The shared parent folders are intentional:

```text
r6\scripts\AWRadioFramework\Radios
r6\tweaks\AWRadioFramework
r6\audioware
```

Each station receives its own subfolder. Mod managers remove only the files and station-specific folders installed by that package, rather than deleting another station or the framework runtime.

Never place station code inside:

```text
r6\scripts\AWRadioFramework\Core
r6\scripts\AWRadioFramework\Integration
```

Those folders belong to the framework.

---

## 4. Create a station with the Builder

### Step 1: Prepare the tracks

Collect the songs you want to include in one folder.

Before importing them:

- Confirm every file plays correctly.
- Remove DRM-protected files.
- Use clear file names.
- Confirm you have permission to distribute them.
- Avoid adding the same file twice unless that duplication is intentional.

The Builder automates most of the work for you.

### Step 2: Open AW Radio Station Builder

Start **AW Radio Station Builder v0.1**.

Create a new station project and enter the station details described below.

### Step 3: Choose an internal station name

The internal name is used for generated folders, classes, Audioware IDs, and TweakDB records.

Example:

```text
NightCityDNB
```

Use:

- Letters
- Numbers
- Underscores

Do not use:

- Spaces
- Hyphens
- Path separators
- A number as the first character

Good examples:

```text
NightCityDNB
SamuraiClassics
DBK_Radio_One
```

Avoid generic names such as:

```text
Radio
Music
Station1
```

A station-specific internal name reduces the chance of colliding with another mod.

### Step 4: Choose the visible station name

This is the name shown in Radioport.

Example:

```text
98.9 NIGHT CITY DNB
```

AWRadioFramework sorts custom stations using the numeric prefix of the visible name.

Examples:

```text
88.4 INDUSTRIAL NOISE
98.9 NIGHT CITY DNB
104.2 AFTERLIFE RADIO
```

The visible frequency controls list placement only. It is not the internal station index.

Keep the name reasonably short because the game UI may truncate long station names.

### Step 5: Choose a station index

The station index is a unique positive integer used internally by the game and framework.

For public station packs, use:

```text
1000-9999
```

Indexes `0-999` are reserved by AWRadioFramework project convention for framework development, testing, or personal use. This is an allocation policy, not a claimed game-engine limit.

The station index:

- Must be unique.
- Must not match another AWRadioFramework station.
- Must be the same in the generated `.reds` and `.yaml` files.
- Is unrelated to the displayed frequency.

Example:

```text
Visible name: 98.9 NIGHT CITY DNB
Station index: 4287
```

The Builder generates an index in the public range, but station authors should still verify that it is not already used by another installed station.

### Step 6: Set the station gain

The gain controls the station's base playback level before the player's radio-volume setting is applied.

Recommended starting value:

```text
0.30
```

Test against several native stations before increasing it.

### Step 7: Add the tracks

Import the supported audio files.

For each track, review the title shown by the Builder.

Use a readable title such as:

```text
Artist - Song Title
```

The title is shown in Radioport and in the native-style now-playing notification.

Keep titles reasonably short. Very long titles may be truncated by the game UI.

The Builder creates unique Audioware event IDs from the station data. Do not manually replace them with generic IDs such as:

```text
track1
song
music
```

Audioware event IDs are global and must not collide with another mod.

### Step 8: Add an optional station archive

A custom icon is optional. The station works without one.

When you already have a valid archive containing the station icon resources, the Builder can include that archive in the generated package.

The archive should contain the required resources, normally including the appropriate atlas and texture assets. The generated TweakXL record must reference the exact resource paths and atlas part names contained in that archive.

Use unique internal depot paths.

Good:

```text
base\icon\your_desired_name.xbm
```

Avoid generic paths:

```text
base\icon\radio.xbm
```

Generic paths can collide with another mod.

### Step 9: Build the station package

Review the station information and generate the ZIP.

Before installation, open the ZIP and confirm that it contains the expected station-specific paths:

```text
r6\audioware\<Station>\
r6\scripts\AWRadioFramework\Radios\<Station>\
r6\tweaks\AWRadioFramework\<Station>\
```

An optional icon archive belongs under:

```text
archive\pc\mod\
```

The station ZIP must not contain AWRadioFramework's `Core` or `Integration` scripts.

---

## 5. Install the generated station

1. Install AWRadioFramework and all required dependencies.
2. Extract the generated station ZIP into the Cyberpunk 2077 game directory, or install it through a mod manager.
3. Confirm that the station files are located under their generated paths.
4. Fully close and restart the game.

Example game root:

```text
Cyberpunk 2077
├─ archive
├─ bin
├─ engine
├─ r6
└─ red4ext
```

A full restart is required after changing:

- Station Redscript
- TweakXL records
- `audios.yml`
- Audio files
- Input files
- Icon archives

Returning to the main menu is not enough. Audioware prepares its audio bank during startup.

---

## 6. First test procedure

Use a small station with two or three tracks for the first test.

### Startup and registration

1. Start the game from a full restart.
2. Confirm Redscript compiles successfully.
3. Reach the main menu.
4. Confirm no AWRadioFramework conflict warning appears.
5. When a warning appears, read it and fix the duplicate index or TweakDB record before continuing.

### Radioport

1. Load a save.
2. Open Radioport.
3. Confirm the station appears once.
4. Confirm it is placed according to the visible numeric frequency.
5. Select the station.
6. Confirm the expected track starts.
7. Confirm the station and track notification appears.
8. Confirm the title shown in Radioport is correct.

### Track playback

1. Allow a track to end naturally.
2. Confirm the next shuffled track starts.
3. Confirm tracks do not simply play in the original file order.
4. Test **Skip Song**.
5. Test **Repeat Song**.
6. Confirm the now-playing title updates after Skip and natural track changes.

---

## 7. Duplicate-station protection

AWRadioFramework checks registered stations for:

- Duplicate internal station indexes
- Duplicate TweakDB station record IDs

When a conflict is found:

- The first accepted station remains registered.
- The conflicting station definition is rejected.
- A persistent warning appears on the main menu.
- The warning names both conflicting stations and records.
- The warning remains visible until **OK** is pressed.

After fixing a conflict:

1. Update the affected station.
2. Ensure the station index and record are unique.
3. Rebuild the package when necessary.
4. Fully restart the game.

The warning does not validate every station file. It does not replace checks for:

- Incorrect Audioware paths
- Missing audio files
- Invalid icon resources
- Incorrect track metadata
- Manually mismatched Redscript and TweakXL values
- Incorrect runtime durations

---

## 8. Understanding the generated files

Most users do not need to edit these files. This section exists for station authors who want to inspect or adjust Builder output.

### `audios.yml`

Location:

```text
r6\audioware\YourStation\audios.yml
```

This file maps unique Audioware event IDs to audio files.

Example:

```yaml
version: 1.0.0

sfx:
  nightcitydnb_neon_velocity:
    file: tracks/neon_velocity.flac
    usage: streaming
```

The event ID:

```text
nightcitydnb_neon_velocity
```

must exactly match the corresponding Redscript track ID.

For full songs, keep:

```yaml
usage: streaming
```

Use spaces for indentation, not tabs.

### Station Redscript

Location:

```text
r6\scripts\AWRadioFramework\Radios\YourStation\YourStation.reds
```

The station definition contains values equivalent to:

```reds
let station = AWRadioStationDefinition.Create(
  t"RadioStation.NightCityDNB",
  4287,
  n"98.9 NIGHT CITY DNB",
  1.0
);
```

These values are:

1. TweakDB station record
2. Internal station index
3. Visible station name
4. Gain

A generated track entry contains values equivalent to:

```reds
station.AddTrack(
  AWRadioTrackDefinition.Create(
    n"nightcitydnb_neon_velocity",
    "Nova Static - Neon Velocity",
    223.4
  )
);
```

These values are:

1. Audioware event ID
2. Visible track title
3. Runtime duration in seconds

For Builder v0.2.2 output, the runtime duration is the real audio duration plus `1.000` second.

### TweakXL station record

Location:

```text
r6\tweaks\AWRadioFramework\YourStation\YourStation.yaml
```

A basic station record is equivalent to:

```yaml
RadioStation.NightCityDNB:
  $base: RadioStation.Pop
  displayName: 98.9 NIGHT CITY DNB
  icon: UIIcon.ICEMinor
  index: 4287
```

The record ID and index must match the generated Redscript.

A custom icon uses a separate `UIIcon.*` record that references the resources packaged in the optional archive.

---

## 9. Values that must remain consistent

After using the Builder, consistency is handled automatically. Problems usually appear only after manual editing.

### TweakDB station record

Redscript:

```reds
t"RadioStation.NightCityDNB"
```

TweakXL:

```yaml
RadioStation.NightCityDNB:
```

### Station index

Redscript:

```reds
4287
```

TweakXL:

```yaml
index: 4287
```

### Visible station name

Redscript:

```reds
n"98.9 NIGHT CITY DNB"
```

TweakXL:

```yaml
displayName: 98.9 NIGHT CITY DNB
```

### Audioware event ID

Audioware manifest:

```yaml
nightcitydnb_neon_velocity:
```

Redscript:

```reds
n"nightcitydnb_neon_velocity"
```

Treat internal IDs as case-sensitive. Copy and paste them rather than retyping them.

---

## 10. Safe manual changes after generation

Regenerating through the Builder is preferred. When manually editing output, change only station-specific files.

Safe station-specific paths:

```text
r6\audioware\<Station>\
r6\scripts\AWRadioFramework\Radios\<Station>\
r6\tweaks\AWRadioFramework\<Station>\
archive\pc\mod\<Station>.archive
```

Do not edit:

```text
r6\scripts\AWRadioFramework\Core\
r6\scripts\AWRadioFramework\Integration\
```

### Change a visible station name

Update the same visible name in:

- The generated Redscript
- The generated TweakXL record

Keep the numeric frequency prefix when frequency-based sorting is desired.

### Change a station index

Update the same positive integer in:

- The generated Redscript
- The generated TweakXL record

Use `1000-9999` for a public station release and confirm it does not collide with another station.

### Change station gain

Change the gain value in the Redscript station definition.

Retest against native stations after every gain adjustment.

### Change a track title

Change the visible title in the corresponding Redscript track definition.

This does not require renaming the real audio file or Audioware event ID.

### Replace an audio file

The safest method is to rebuild the station.

When replacing it manually:

- Keep the manifest path correct.
- Keep the event ID consistent.
- Update the runtime duration.

### Add or remove tracks

Rebuilding with the Builder is strongly recommended.

Manual addition requires matching changes in:

- `audios.yml`
- The Redscript track list
- The packaged `tracks` folder

Every manifest event must have one matching Redscript track, and every Redscript track must have one matching manifest event.

---

## 11. Troubleshooting

### The station does not appear

Check:

- AWRadioFramework is installed.
- All required dependencies are installed.
- The station Redscript is under:

  ```text
  r6\scripts\AWRadioFramework\Radios\<Station>\
  ```

- The TweakXL file is under:

  ```text
  r6\tweaks\AWRadioFramework\<Station>\
  ```

- Redscript compiled successfully.
- TweakXL loaded the station record.
- The main menu did not report a duplicate index or TweakDB record.
- The game was fully restarted.

When the package was manually edited, also confirm the record ID, station index, and visible name match between Redscript and TweakXL.

### Only one of two custom stations appears

The second station was probably rejected because both packs use:

- The same internal station index, or
- The same `RadioStation.*` TweakDB record

Read the persistent main-menu warning, fix the conflicting station, then fully restart the game.

### The station appears at the bottom of the list

Confirm the visible station name begins with a numeric frequency followed by a space:

```text
98.9 NIGHT CITY DNB
```

The station index does not control list placement.

### The station appears but no audio plays

Check:

- Audioware loaded successfully.
- `audios.yml` is in the generated station folder.
- Every declared file exists under `tracks`.
- File names and extensions match exactly.
- Audioware event IDs match the Redscript IDs.
- `usage: streaming` is present.
- The files are not DRM-protected.
- The station gain is greater than `0.0`.
- The game was fully restarted.

Audioware logs are normally under:

```text
red4ext\logs
```

Search the relevant Audioware log for the station's event ID or file path.

### The wrong song plays

Check whether:

- The event ID points to the wrong file in `audios.yml`.
- A manually copied entry retained another track's event ID.
- The same event ID is used by more than one track or mod.

Rebuild the station when the generated mapping has become difficult to verify.

### Track title does not update

Check:

- The generated Redscript title is not empty.
- The track has a valid runtime duration.
- The Audioware event ID matches.
- Another mod is not replacing the same Radioport title or notification methods.

### The station icon is missing

Check:

- The optional archive is installed under `archive\pc\mod`.
- The TweakXL icon record exists.
- `atlasResourcePath` matches the actual archive resource.
- `atlasPartName` matches the atlas.
- The Ink atlas and XBM paths are correct.
- TweakXL does not report a non-existent record or flat.

The Builder packages existing icon resources but does not create them.

### Skip Song or Repeat Song does not work

Check:

- Input Loader is installed.
- Mod Settings is installed.
- The bindings under **AW Radio Settings** are not colliding with another action.
- A custom station is active.
- The station is not manually paused.

---

## 13. Uninstalling a station pack

Remove only the files belonging to that station.

Common paths:

```text
Cyberpunk 2077\r6\audioware\<Station>\
Cyberpunk 2077\r6\scripts\AWRadioFramework\Radios\<Station>\
Cyberpunk 2077\r6\tweaks\AWRadioFramework\<Station>\
Cyberpunk 2077\archive\pc\mod\<Station>.archive
```

Do not delete shared parent folders when they still contain AWRadioFramework or other station packs.

Perform a full game restart after uninstalling a station.

---

## 14. Final release checklist

Before publishing a station pack:

- [ ] The package was generated with the current Builder.
- [ ] You have permission to distribute every audio and artwork asset.
- [ ] The internal station name is unique and station-specific.
- [ ] The `RadioStation.*` record is unique.
- [ ] The station index is unique.
- [ ] A public station uses the `1000-9999` range.
- [ ] The visible name begins with a numeric frequency when ordered placement is wanted.
- [ ] Every Audioware event ID has a unique station-specific prefix.
- [ ] Every imported audio file exists in the generated `tracks` folder.
- [ ] Every track has a readable title.
- [ ] Builder-generated runtime durations were not manually increased by another second.
- [ ] Songs use `usage: streaming`.
- [ ] The package contains no AWRadioFramework `Core` or `Integration` scripts.
- [ ] The station appears in Radioport.
- [ ] The station order is correct.
- [ ] Natural track changes were tested.
- [ ] Skip and Repeat were tested.
- [ ] An optional icon archive uses unique resource paths.
- [ ] The generated README lists AWRadioFramework and all required dependencies.
- [ ] The final ZIP installs from the Cyberpunk 2077 game root.

---

## 15. Summary

For most station authors, the complete workflow is:

1. Prepare supported audio files.
2. Create the station in AW Radio Station Builder v0.1
3. Review the station name, public-range index, gain, track titles, and durations.
4. Add an existing optional icon archive when needed.
5. Generate the ready-to-install ZIP.
6. Install it with AWRadioFramework and its dependencies.
7. Fully restart the game.
8. Test Radioport, track changes, controls and so on.
9. Publish only after confirming all of the above.

Manual editing should be the exception, not the default. The Builder exists so station creation does not require hand-maintaining three interdependent files while hoping every identifier remains identical, a pastime humanity had already suffered enough.
