# AWRadioFramework Station Creation Guide

## Read this first

This guide explains how to create a custom Cyberpunk 2077 radio station for **AWRadioFramework** without needing to understand programming.

You will edit three small text files:

1. `audios.yml` tells Audioware where your song files are.
2. `MyStation.reds` tells AWRadioFramework the station name, track titles, track order, and the duration of each song.
3. `MyStation.yaml` creates the station record that appears in Cyberpunk 2077.

A custom icon is optional. The station works without one.

Do **not** edit the framework files under:

```text
r6\scripts\AWRadioFramework\Core
r6\scripts\AWRadioFramework\Integration
```

Your station is a separate station pack.

---

# 1. What you need

Install AWRadioFramework and all of its required dependencies:

- RED4ext
- redscript
- Codeware
- TweakXL
- Audioware

Use a plain-text editor such as Notepad++ or Visual Studio Code.

Do not use Microsoft Word. Word enjoys turning normal quotation marks into decorative quotation marks, which is charming until Redscript refuses to compile.

Your music files must be one of these supported formats:

- `.wav`
- `.ogg`
- `.mp3`
- `.flac`

For normal songs, keep `usage: streaming`. Streaming is intended for long audio and avoids loading the whole song into memory at once.

Recommended audio preparation:

- Use stereo audio.
- Use 44.1 kHz or 48 kHz.
- Cyberpunk 2077 commonly uses 48 kHz / 16-bit PCM audio.
- Avoid DRM-protected files.
- Use simple file names containing letters, numbers, and underscores.

Examples:

```text
good_song_name.flac
artist_track_01.mp3
night_drive.wav
```

Avoid:

```text
Track #1 (FINAL!!!).mp3
My Song: Remastered?.flac
```

Spaces may work, but simple file names prevent pointless path errors.

Only distribute songs you have permission to distribute.

---

# 2. Copy the blank template

Inside the creator kit, open:

```text
BLANK_STATION_PACK
```

Copy that entire folder somewhere safe and rename the copied folder to your station pack name.

Example:

```text
MyStationPack
```

Do not copy the blank template into the game yet. It still contains placeholder names.

The finished station will eventually have this structure:

```text
MyStationPack
├─ archive
│  └─ pc
│     └─ mod
│        └─ MyStation.archive              OPTIONAL custom icon
├─ r6
│  ├─ audioware
│  │  └─ MyStation
│  │     ├─ audios.yml
│  │     └─ tracks
│  │        ├─ song_01.flac
│  │        ├─ song_02.mp3
│  │        └─ song_03.ogg
│  ├─ scripts
│  │  └─ AWRadioFramework
│  │     └─ Radios
│  │        └─ MyStation
│  │           └─ MyStation.reds
│  └─ tweaks
│     └─ AWRadioFramework
│        └─ MyStation
│           └─ MyStation.yaml
```

---

# 3. Choose your station details

Fill in `STATION_DETAILS_WORKSHEET.txt` before editing anything.

You need these values:

## Public station name

This is the name players see in Radioport.

Example:

```text
98.9 NIGHT CITY DNB
```

The frequency is only display text. It does not control any real frequency and does not need to match the internal station index.

Practical naming rules:

- Keep it reasonably short because the game UI can truncate long names.
- Letters, numbers, spaces, periods, apostrophes, and hyphens are safest.
- Do not use line breaks.
- Avoid double quotation marks.
- Avoid `#` and `:` unless you understand YAML quoting.
- Use the exact same visible name in both `MyStation.reds` and `MyStation.yaml`.

## Internal station name

This is used only by the files.

Example:

```text
NightCityDNB
```

Rules:

- Use letters and numbers only.
- Underscores are also safe.
- Do not use spaces.
- Do not use hyphens.
- Do not begin with a number.
- Make it unique.

Good examples:

```text
NightCityDNB
SamuraiClassics
DBK_Radio_One
```

Bad examples:

```text
98.9 Radio
My-Radio
My Radio
```

## Station index

This is a unique positive whole number used internally.

Example:

```text
420
```

The same index must appear in both the `.reds` and `.yaml` files.

Rules:

- Do not use a vanilla station index.
- Do not reuse an index from another custom station.
- Use a positive whole number.
- A value between `100` and `9999` is a practical choice.
- The display frequency and station index are unrelated.

## Station gain

This controls the station's base volume before the Radioport volume setting is applied.

Recommended:

```text
1.0
```

Examples:

```text
0.5 = quieter
1.0 = normal
1.2 = slightly louder
2.0 = framework maximum
```

Leave it at `1.0` for the first test.

---

# 4. Prepare your songs

Put every song in:

```text
r6\audioware\MyStation\tracks
```

You may mix supported formats in one station.

Example:

```text
tracks\neon_velocity.flac
tracks\afterlife_run.mp3
tracks\city_at_3am.ogg
```

## Find each song duration

AWRadioFramework currently requires the duration of every song in seconds.

The test station changes tracks after 12 seconds because its template explicitly says:

```reds
12.0
```

That number is not an Audioware format limit.

### Windows method

1. Right-click the song.
2. Select **Properties**.
3. Open the **Details** tab.
4. Find **Length**.
5. Convert minutes and seconds into total seconds.

Formula:

```text
total seconds = minutes × 60 + seconds
```

Examples:

```text
2:30 = 150 seconds
3:00 = 180 seconds
3:15 = 195 seconds
3:42 = 222 seconds
4:05 = 245 seconds
5:30 = 330 seconds
```

Use a decimal duration when you know it:

```text
222.4
```

A whole number is acceptable for initial testing:

```text
222.0
```

Why accuracy matters:

- Duration too short: the next song starts before the current one finishes.
- Duration too long: the current song ends and the station waits in silence.
- Correct duration: the next song starts at the intended time.

---

# 5. Edit `audios.yml`

Open:

```text
r6\audioware\MyStation\audios.yml.txt
```

When editing is complete, rename it to:

```text
audios.yml
```

The file uses this structure:

```yaml
version: 1.0.0

sfx:
  my_station_track_01:
    file: tracks/song_01.flac
    usage: streaming

  my_station_track_02:
    file: tracks/song_02.mp3
    usage: streaming
```

For every song, you need one block.

## What each line means

```yaml
my_station_track_01:
```

This is the **audio ID**.

Rules:

- It must be unique across the game and every installed mod.
- Use lowercase letters, numbers, and underscores.
- Do not use spaces.
- Give every ID a station-specific prefix.
- It must exactly match the first value in the corresponding `.reds` track entry.

Good:

```text
nightcitydnb_neon_velocity
dbkradio_track_01
samuraiclassics_neverfadeaway
```

Bad:

```text
track1
song
music
```

Generic IDs are much more likely to collide with another mod.

```yaml
file: tracks/song_01.flac
```

This is the path to the real audio file, relative to `audios.yml`.

The file name and extension must match exactly.

```yaml
usage: streaming
```

Leave this unchanged for songs.

## Adding another song

Copy one complete block:

```yaml
  my_station_track_03:
    file: tracks/song_03.ogg
    usage: streaming
```

Keep the indentation exactly as shown:

- Two spaces before the audio ID.
- Four spaces before `file`.
- Four spaces before `usage`.
- Do not use tabs.

## Removing a song

Delete its complete block from `audios.yml`.

You must also delete the matching track block from `MyStation.reds`.

---

# 6. Edit `MyStation.reds`

Open:

```text
r6\scripts\AWRadioFramework\Radios\MyStation\MyStation.reds.txt
```

When editing is complete, rename it to:

```text
MyStation.reds
```

## Station definition

This block creates the station:

```reds
let station = AWRadioStationDefinition.Create(
  t"RadioStation.MyStation",
  120,
  n"104.2 MY STATION",
  1.0
);
```

Change each value carefully.

### Record name

```reds
t"RadioStation.MyStation"
```

Replace `MyStation` with your unique internal station name.

Example:

```reds
t"RadioStation.NightCityDNB"
```

This must exactly match the record name in `MyStation.yaml`.

### Station index

```reds
120
```

Replace it with your chosen unique station index.

Example:

```reds
420
```

This must exactly match the `index` value in `MyStation.yaml`.

### Visible station name

```reds
n"104.2 MY STATION"
```

Replace the text inside the quotation marks.

Example:

```reds
n"98.9 NIGHT CITY DNB"
```

Do not remove:

```text
n"
"
```

### Station gain

```reds
1.0
```

Leave this at `1.0` for the first test.

## Track definition

Every song needs one block:

```reds
station.AddTrack(
  AWRadioTrackDefinition.Create(
    n"my_station_track_01",
    "Artist - Song Title",
    222.0
  )
);
```

### Audio ID

```reds
n"my_station_track_01"
```

This must exactly match the audio ID in `audios.yml`.

Example manifest ID:

```yaml
nightcitydnb_neon_velocity:
```

Matching Redscript ID:

```reds
n"nightcitydnb_neon_velocity"
```

Treat IDs as case-sensitive. Copy and paste rather than retyping.

### Track title

```reds
"Artist - Song Title"
```

This is the title displayed by the radio UI.

Example:

```reds
"Nova Static - Neon Velocity"
```

The title does not need to match the file name.

Keep titles reasonably short because the UI can truncate long text.

Avoid double quotation marks inside the title.

### Duration

```reds
222.0
```

This is the song duration in seconds.

It controls when the framework advances to the next track.

## Adding more songs

Copy the entire track block and change all three values:

```reds
station.AddTrack(
  AWRadioTrackDefinition.Create(
    n"nightcitydnb_afterlife_run",
    "Chrome Pulse - Afterlife Run",
    245.0
  )
);
```

Put track blocks in the order you want them to play.

The framework plays:

```text
Track 1
Track 2
Track 3
...
Last track
Track 1 again
```

There is currently no shuffle mode.

## Provider names

The template contains:

```reds
public abstract class MyStationFactory
public class MyStationProvider
```

Replace `MyStation` with your internal station name.

Example:

```reds
public abstract class NightCityDNBFactory
public class NightCityDNBProvider
```

Also change the module name at the top:

```reds
module MyRadioStation
```

Example:

```reds
module NightCityDNB
```

The provider must build the matching factory:

```reds
framework.RegisterStation(
  NightCityDNBFactory.Build()
);
```

The completed example in this kit shows all of these changes together.

---

# 7. Edit `MyStation.yaml`

Choose one template:

```text
MyStation_NO_CUSTOM_ICON.yaml.txt
MyStation_CUSTOM_ICON.yaml.txt
```

Rename the chosen file to:

```text
MyStation.yaml
```

Delete the unused template from your station pack.

## Option A: no custom icon

This is the easiest choice for the first test:

```yaml
RadioStation.MyStation:
  $base: RadioStation.Pop
  displayName: 104.2 MY STATION
  icon: UIIcon.ICEMinor
  index: 120
```

Change:

```text
RadioStation.MyStation
104.2 MY STATION
120
```

The record name, display name, and index must match `MyStation.reds`.

## Option B: custom icon

Use this only when you have a working `.archive` containing an `.inkatlas` and `.xbm`.

Example:

```yaml
UIIcon.MyStation:
  $base: UIIcon.ICEMinor
  atlasResourcePath: base\my_station\icons\my_station.inkatlas
  atlasPartName: icon_part

RadioStation.MyStation:
  $base: RadioStation.Pop
  displayName: 104.2 MY STATION
  icon: UIIcon.MyStation
  index: 120
```

You must change:

- `UIIcon.MyStation`
- `RadioStation.MyStation`
- `displayName`
- `index`
- `atlasResourcePath`
- `atlasPartName`

The icon archive belongs in:

```text
archive\pc\mod
```

The resource path and atlas part must match the contents of the archive exactly.

For release, use unique internal depot paths. Do not use generic paths such as:

```text
base\icon\radio.xbm
```

Use something specific:

```text
base\my_mod_name\radio_icons\my_station.xbm
```

This avoids another mod overwriting the same resource path.

---

# 8. Rename folders and files

For neatness, rename the three `MyStation` folders to your internal station name.

Example:

```text
r6\audioware\NightCityDNB
r6\scripts\AWRadioFramework\Radios\NightCityDNB
r6\tweaks\AWRadioFramework\NightCityDNB
```

Rename the files:

```text
MyStation.reds → NightCityDNB.reds
MyStation.yaml → NightCityDNB.yaml
```

The file names themselves are not used as station IDs, but consistent naming makes troubleshooting much easier.

The final files must not end in `.txt`.

Correct:

```text
audios.yml
NightCityDNB.reds
NightCityDNB.yaml
```

Wrong:

```text
audios.yml.txt
NightCityDNB.reds.txt
NightCityDNB.yaml.txt
```

Windows may hide known file extensions. In File Explorer, enable:

```text
View → Show → File name extensions
```

---

# 9. Install the station pack

Your station pack folder should contain `r6` and optionally `archive`.

Copy those folders into the Cyberpunk 2077 game root.

Example game root:

```text
Cyberpunk 2077
├─ archive
├─ bin
├─ engine
├─ r6
└─ red4ext
```

Merge the folders when Windows asks.

Perform a **full game restart** after changing:

- `audios.yml`
- audio files
- `.reds`
- `.yaml`
- icon archives

Audioware builds its audio bank during game startup. Returning to the main menu is not enough.

---

# 10. First test procedure

Use a small test station first, ideally two or three songs.

1. Start the game.
2. Check for Redscript compilation errors.
3. Load a save.
4. Open Radioport.
5. Confirm the station appears.
6. Select the station.
7. Confirm the correct first song starts.
8. Confirm the displayed title is correct.
9. Wait for the exact song transition.
10. Test Radioport volume.
11. Test short Z press on foot.
12. Mount a vehicle.
13. Confirm no native station plays over the custom station.
14. Test short R press.
15. Exit the vehicle.
16. Confirm playback and the on-foot button state transfer correctly.
17. Let the last song finish and confirm the station returns to track 1.

---

# 11. Troubleshooting

## The station does not appear

Check:

- The `.yaml` file no longer ends in `.txt`.
- The `.reds` file no longer ends in `.txt`.
- The record name matches in both files.
- The station index matches in both files.
- The station index is not already used.
- Redscript compiled successfully.
- TweakXL loaded the YAML.

## The station appears but no song plays

Check:

- `audios.yml` is in the correct station folder.
- The audio file exists in the declared `tracks` path.
- The audio format is `.wav`, `.ogg`, `.mp3`, or `.flac`.
- The audio ID matches exactly between `audios.yml` and `.reds`.
- `usage: streaming` is indented correctly.
- The file is not DRM-protected.
- The game was fully restarted.

Audioware validation logs are under:

```text
red4ext\logs
```

Look for an Audioware log file and search for your audio ID.

## A song changes after 12 seconds

The track still has:

```reds
12.0
```

Replace it with the real duration in seconds.

## The next song starts too early

The duration in `.reds` is shorter than the real song.

## There is silence before the next song

The duration in `.reds` is longer than the real song.

## The wrong title appears

Change the second value in the matching track block:

```reds
"Artist - Song Title"
```

## The wrong file plays

The audio ID points to the wrong file in `audios.yml`, or two entries were copied without changing the ID.

## The station is rejected

AWRadioFramework rejects:

- Negative station indexes.
- Stations with no tracks.
- Duplicate station indexes.
- Duplicate station record IDs.

## Another mod breaks the station

Check for collisions in:

- Station index.
- `RadioStation.*` record name.
- `UIIcon.*` record name.
- Audioware audio IDs.
- Icon archive depot paths.

Every internal name should have a unique prefix.

---

# 12. Current framework behaviour and limitations

Current behaviour:

- Pause and resume preserve the current track position.
- Radioport volume affects the custom station.
- On-foot and vehicle radio transfers are supported.
- Station and track titles use the native radio UI.
- Custom station icons are supported through a TweakXL `UIIcon` record and an archive.

Current limitations:

- Song duration is entered manually.
- No web-stream support yet.
- No independent always-running broadcast timeline.
- Very long station and track names may be truncated by the game UI.
- Changes require a full game restart.

---

# 13. Final release checklist

Before sharing a station pack:

- [ ] You have permission to distribute every audio file.
- [ ] All audio IDs have a unique station-specific prefix.
- [ ] The station record name is unique.
- [ ] The UI icon record name is unique.
- [ ] The station index is unique.
- [ ] The same station index appears in `.reds` and `.yaml`.
- [ ] The same record name appears in `.reds` and `.yaml`.
- [ ] Every manifest audio ID has one matching `.reds` track.
- [ ] Every `.reds` track has one matching manifest audio ID.
- [ ] Every declared audio file exists.
- [ ] Every song duration has been tested.
- [ ] Audio files use `.wav`, `.ogg`, `.mp3`, or `.flac`.
- [ ] Songs use `usage: streaming`.
- [ ] No template file still ends in `.txt`.
- [ ] The station works on foot.
- [ ] The station works in a vehicle.
- [ ] Mount and unmount do not start a second native station.
- [ ] Volume, pause, resume, title, equalizer, and icon were tested.
- [ ] The pack does not include or overwrite AWRadioFramework core scripts.
- [ ] The pack documentation lists AWRadioFramework and its dependencies.

---

# 14. The four values that must match

Most station problems come from one of these values not matching.

## Station record

`MyStation.reds`:

```reds
t"RadioStation.NightCityDNB"
```

`MyStation.yaml`:

```yaml
RadioStation.NightCityDNB:
```

## Station index

`MyStation.reds`:

```reds
420
```

`MyStation.yaml`:

```yaml
index: 420
```

## Visible station name

`MyStation.reds`:

```reds
n"98.9 NIGHT CITY DNB"
```

`MyStation.yaml`:

```yaml
displayName: 98.9 NIGHT CITY DNB
```

## Audio ID

`audios.yml`:

```yaml
nightcitydnb_neon_velocity:
```

`MyStation.reds`:

```reds
n"nightcitydnb_neon_velocity"
```

# 15. Completed example

Open:

```text
EXAMPLE_FINISHED_STATION
```

It contains a complete three-track example named:

```text
98.9 NIGHT CITY DNB
```

The example audio files are not included. Its purpose is to show exactly how all identifiers, names, paths, titles, and durations correspond across the three configuration files.
