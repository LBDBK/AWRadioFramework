module AWRadioFramework

public class AWNativeRadioSkipUnlockCallback extends DelayCallback {
  public func Call() -> Void {
    let service = AWNativeRadioSkipService.Get();

    if IsDefined(service) {
      service.Unlock();
    }
  }
}

public class AWNativeRadioSkipService extends ScriptableService {
  private let m_locked: Bool;
  private let m_station: CName;
  private let m_playlistSize: Int32;
  private let m_order: array<Int32>;
  private let m_orderPosition: Int32;
  private let m_lastSkippedTrackTitle: String;

  public static func Get() -> ref<AWNativeRadioSkipService> {
    return GameInstance
      .GetScriptableServiceContainer()
      .GetService(
        n"AWRadioFramework.AWNativeRadioSkipService"
      ) as AWNativeRadioSkipService;
  }

  public func Unlock() -> Void {
    this.m_locked = false;
  }

  private func GetStationNameByIndex(index: Int32) -> CName {
    if Equals(index, 0) {
      return n"radio_station_02_aggro_ind";
    }

    if Equals(index, 1) {
      return n"radio_station_03_elec_ind";
    }

    if Equals(index, 2) {
      return n"radio_station_04_hiphop";
    }

    if Equals(index, 3) {
      return n"radio_station_07_aggro_techno";
    }

    if Equals(index, 4) {
      return n"radio_station_09_downtempo";
    }

    if Equals(index, 5) {
      return n"radio_station_01_att_rock";
    }

    if Equals(index, 6) {
      return n"radio_station_05_pop";
    }

    if Equals(index, 7) {
      return n"radio_station_10_latino";
    }

    if Equals(index, 8) {
      return n"radio_station_11_metal";
    }

    if Equals(index, 9) {
      return n"radio_station_06_minim_techno";
    }

    if Equals(index, 10) {
      return n"radio_station_08_jazz";
    }

    if Equals(index, 11) {
      return n"radio_station_12_growl_fm";
    }

    if Equals(index, 12) {
      return n"radio_station_13_dark_star";
    }

    if Equals(index, 13) {
      return n"radio_station_14_impulse_fm";
    }

    return n"";
  }

  private func GetStationSongs(index: Int32) -> array<CName> {
    let songs: array<CName>;

    if Equals(index, 0) {
      ArrayPush(songs, n"mus_radio_02_aggro_ind_resist_and_disorder");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_kill_the_messenger");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_makes_me_feel_better");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_dead_pilot");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_comeclose");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_black_terminal_vox_upgrade");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_reaktion");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_with_her");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_never_stop_me");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_violence");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_pain");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_night_city_aliens");
      ArrayPush(songs, n"mus_radio_02_aggroind_cyber_caca");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_cyber_tabla");
      ArrayPush(songs, n"mus_radio_02_aggro_ind_pig_dinner");

      return songs;
    }

    if Equals(index, 1) {
      ArrayPush(songs, n"mus_radio_03_elec_ind_dirty_roses");
      ArrayPush(songs, n"mus_radio_03_elec_ind_worlds");
      ArrayPush(songs, n"mus_radio_03_elec_ind_x");
      ArrayPush(songs, n"mus_radio_03_elec_ind_maniak");
      ArrayPush(songs, n"mus_radio_03_electind_be_machine");
      ArrayPush(songs, n"mus_radio_03_electind_cyberpunk07");
      ArrayPush(songs, n"mus_radio_03_elec_ind_run");
      ArrayPush(songs, n"mus_radio_03_elec_ind_ppgame05");
      ArrayPush(songs, n"mus_radio_03_elec_ind_ppgame18");
      ArrayPush(songs, n"mus_radio_03_elec_ind_killkill");
      ArrayPush(songs, n"mus_radio_03_elec_ind_flying_heads");
      ArrayPush(songs, n"mus_radio_03_electind_cyberpunk03_");
      ArrayPush(songs, n"mus_radio_03_elect_ind_brain_damaged");
      ArrayPush(songs, n"mus_radio_03_elec_ind_neuron");

      return songs;
    }

    if Equals(index, 2) {
      ArrayPush(songs, n"mus_radio_04_hiphop_the_god_machines");
      ArrayPush(songs, n"mus_radio_04_hiphop_blouses_blue");
      ArrayPush(songs, n"mus_radio_04_hiphop_problem_kids");
      ArrayPush(songs, n"mus_radio_04_hiphop_bigger_man");
      ArrayPush(songs, n"mus_radio_04_hiphop_go_blaze");
      ArrayPush(songs, n"mus_radio_04_hiphop_dishonor");
      ArrayPush(songs, n"mus_radio_04_hiphop_frost");
      ArrayPush(songs, n"mus_radio_04_hiphop_hs_bully");
      ArrayPush(songs, n"mus_radio_04_hiphop_nbomdanalog");
      ArrayPush(songs, n"mus_radio_04_hiphop_suicide");
      ArrayPush(songs, n"mus_radio_04_hiphop_day_of_dead");
      ArrayPush(songs, n"mus_radio_04_hiphop_bruzez");
      ArrayPush(songs, n"mus_radio_04_hiphop_clip_boss");
      ArrayPush(songs, n"mus_radio_04_hiphop_plucku");
      ArrayPush(songs, n"mus_radio_04_hiphop_goodmorn");
      ArrayPush(songs, n"mus_radio_04_hiphop_run_the_block");
      ArrayPush(songs, n"mus_radio_04_hiphop_gr4ves");
      ArrayPush(songs, n"mus_radio_04_hiphop_warning_shots");
      ArrayPush(songs, n"mus_radio_04_hiphop_yugen_blakrok");
      ArrayPush(songs, n"mus_radio_04_hiphop_no_save_point");
      ArrayPush(songs, n"mus_radio_04_hiphop_ccc_flacko_loco");
      ArrayPush(songs, n"mus_radio_04_hiphop_nose_bleed");
      ArrayPush(songs, n"mus_radio_04_hiphop_ccc");

      return songs;
    }

    if Equals(index, 3) {
      ArrayPush(songs, n"mus_radio_07_aggro_techno_bios");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_drained");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_subvert");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_follow_the_white_crow");
      ArrayPush(songs, n"mus_radio_08_aggro_techno_fake_spook");
      ArrayPush(songs, n"mus_radio_08_aggro_techno_move_dat");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_jam");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_acid");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_really_heavy_groove");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_stoczterdziescitrzy");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_zero_acid");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_cdpmetal_vascular");
      ArrayPush(songs, n"mus_radio_08_aggro_techno_cyberpunk02");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_cannibalismus");
      ArrayPush(songs, n"mus_radio_07_aggro_techno_stack_overflow");

      return songs;
    }

    if Equals(index, 4) {
      ArrayPush(songs, n"mus_radio_09_downtempo_isometric_air");
      ArrayPush(songs, n"mus_radio_09_downtempo_real_window");
      ArrayPush(songs, n"mus_radio_09_downtempo_practical_heart");
      ArrayPush(songs, n"mus_radio_09_downtempo_antagonistic");
      ArrayPush(songs, n"mus_radio_09_downtempo_simple_pleasures");
      ArrayPush(songs, n"mus_radio_09_downtempo_chodze");
      ArrayPush(songs, n"mus_radio_09_downtempo_cyberpunk05");
      ArrayPush(songs, n"mus_radio_09_downtempo_cyberpunk06");
      ArrayPush(songs, n"mus_radio_09_downtempo_cyberpunk08");
      ArrayPush(songs, n"mus_radio_09_downtempo_le_stessa_causa");
      ArrayPush(songs, n"mus_radio_09_downtempo_dub_dub_mix_ambient");
      ArrayPush(songs, n"mus_radio_09_downtempo_miami_suicide");
      ArrayPush(songs, n"mus_radio_09_downtempo_slippery_stabs");
      ArrayPush(songs, n"mus_radio_09_downtempo_ashes_and_diamonds");
      ArrayPush(songs, n"mus_radio_09_downtempo_cdprojekt2_uferlos");
      ArrayPush(songs, n"mus_radio_09_downtempo_demo4");
      ArrayPush(songs, n"mus_radio_09_downtempo_demo7");

      return songs;
    }

    if Equals(index, 5) {
      ArrayPush(songs, n"mus_radio_01_att_rock_suffer_me");
      ArrayPush(songs, n"mus_radio_01_att_rock_heaven_ho");
      ArrayPush(songs, n"mus_radio_01_att_rock_i_will_follow");
      ArrayPush(songs, n"mus_radio_01_attrock_likewise");
      ArrayPush(songs, n"mus_radio_01_att_rock_friday_night_fire_night");
      ArrayPush(songs, n"mus_radio_01_att_rock_trauma");
      ArrayPush(songs, n"mus_radio_01_att_rock_mstr01");
      ArrayPush(songs, n"mus_radio_01_att_rock_never_fade_away");
      ArrayPush(songs, n"mus_radio_01_att_rock_black_dog");
      ArrayPush(songs, n"mus_radio_01_att_rock_chippin_in");
      ArrayPush(songs, n"mus_radio_01_att_rock_the_ballad");
      ArrayPush(songs, n"mus_radio_01_attrock_summer_of_2069");
      ArrayPush(songs, n"mus_radio_01_att_rock_no_convenient_apocalypse");
      ArrayPush(songs, n"mus_radio_01_attrock_to_the_fullest");
      ArrayPush(songs, n"mus_radio_01_attrock_so_it_goes");

      return songs;
    }

    if Equals(index, 6) {
      ArrayPush(songs, n"mus_radio_05_pop_whos_ready");
      ArrayPush(songs, n"mus_radio_05_pop_cirque_du_soleil");
      ArrayPush(songs, n"mus_radio_05_pop_major_crimes");
      ArrayPush(songs, n"mus_radio_05_pop_night_city");
      ArrayPush(songs, n"mus_radio_05_pop_i_want_to_stay_at_your_house");
      ArrayPush(songs, n"mus_radio_05_pop_hole_in_the_sun");
      ArrayPush(songs, n"mus_radio_05_pop_history");
      ArrayPush(songs, n"mus_radio_05_pop_ponpon_shit");
      ArrayPush(songs, n"mus_radio_05_pop_crust_punk");
      ArrayPush(songs, n"mus_radio_05_pop_heres_a_thought");
      ArrayPush(songs, n"mus_radio_05_pop_4aem");
      ArrayPush(songs, n"mus_radio_05_pop_delicate_weapon");
      ArrayPush(songs, n"mus_radio_05_pop_shygirl");
      ArrayPush(songs, n"mus_radio_05_pop_user_friendly");
      ArrayPush(songs, n"mus_radio_05_pop_off_the_leash");

      return songs;
    }

    if Equals(index, 7) {
      ArrayPush(songs, n"mus_radio_10_latino_bamo");
      ArrayPush(songs, n"mus_radio_10_latino_daggafrica");
      ArrayPush(songs, n"mus_radio_10_latino_dinero");
      ArrayPush(songs, n"mus_radio_10_latino_serpant");
      ArrayPush(songs, n"mus_radio_10_latino_barrio");
      ArrayPush(songs, n"mus_radio_10_latino_tatted_on_my_face");
      ArrayPush(songs, n"mus_radio_10_latino_hood");
      ArrayPush(songs, n"mus_radio_10_latino_cumbia");
      ArrayPush(songs, n"mus_radio_10_latino_muertothrash");
      ArrayPush(songs, n"mus_radio_10_latino_only_son");
      ArrayPush(songs, n"mus_radio_10_latino_westcoast_till_i_die");

      return songs;
    }

    if Equals(index, 8) {
      ArrayPush(songs, n"mus_radio_11_metal_finis");
      ArrayPush(songs, n"mus_radio_11_metal_theaccursed");
      ArrayPush(songs, n"mus_radio_11_metal_march30");
      ArrayPush(songs, n"mus_radio_11_metal_acid_breather");
      ArrayPush(songs, n"mus_radio_11_metal_2");
      ArrayPush(songs, n"mus_radio_11_metal_the_loop");
      ArrayPush(songs, n"mus_radio_11_metal_scum");
      ArrayPush(songs, n"mus_radio_11_metal_fueled_by_poison");
      ArrayPush(songs, n"mus_radio_11_metal_kevin");
      ArrayPush(songs, n"mus_radio_11_metal_future_drags");
      ArrayPush(songs, n"mus_radio_11_metal_zurawie");
      ArrayPush(songs, n"mus_radio_11_metal_abandoned_land");
      ArrayPush(songs, n"mus_radio_11_metal_black_concrete");
      ArrayPush(songs, n"mus_radio_11_metal_i_wont_let_you_go");

      return songs;
    }

    if Equals(index, 9) {
      ArrayPush(songs, n"mus_radio_06_minim_tech_pilling_in_my_head");
      ArrayPush(songs, n"mus_radio_06_minim_tech_delirium2");
      ArrayPush(songs, n"mus_radio_06_minim_tech_harm_sweaty_pit");
      ArrayPush(songs, n"mus_radio_06_minim_tech_my_lullaby_for_you");
      ArrayPush(songs, n"mus_radio_06_minim_tech_surprise_me");

      return songs;
    }

    if Equals(index, 10) {
      ArrayPush(songs, n"mus_radio_08_jazz_black_satin_what_if_agharta");
      ArrayPush(songs, n"mus_radio_08_jazz_bitches_brew");
      ArrayPush(songs, n"mus_radio_08_jazz_generique");
      ArrayPush(songs, n"mus_radio_08_jazz_impressions");
      ArrayPush(songs, n"mus_radio_08_jazz_solo_dancer");
      ArrayPush(songs, n"mus_radio_08_jazz_laura");
      ArrayPush(songs, n"mus_radio_08_jazz_you_dont_know_what_love_is");
      ArrayPush(songs, n"mus_radio_08_jazz_round_midnight");
      ArrayPush(songs, n"mus_radio_08_jazz_dark_prince");

      return songs;
    }

    if Equals(index, 11) {
      ArrayPush(songs, n"mus_radio_12_afterlife");
      ArrayPush(songs, n"mus_radio_12_candyshell");
      ArrayPush(songs, n"mus_radio_12_ch");
      ArrayPush(songs, n"mus_radio_12_do_or_die");
      ArrayPush(songs, n"mus_radio_12_flatline");
      ArrayPush(songs, n"mus_radio_12_fumes");
      ArrayPush(songs, n"mus_radio_12_killshot");
      ArrayPush(songs, n"mus_radio_12_kiroshi");
      ArrayPush(songs, n"mus_radio_12_lit");
      ArrayPush(songs, n"mus_radio_12_skin_on_flesh");
      ArrayPush(songs, n"mus_radio_12_slipstream");
      ArrayPush(songs, n"mus_radio_12_stars_die");
      ArrayPush(songs, n"mus_radio_12_to_heaven");

      return songs;
    }

    if Equals(index, 12) {
      ArrayPush(songs, n"mus_radio_13_dstar_27fuckdemons");
      ArrayPush(songs, n"mus_radio_13_dstar_backxwash");
      ArrayPush(songs, n"mus_radio_13_dstar_chokehold");
      ArrayPush(songs, n"mus_radio_13_dstar_cykoarctic");
      ArrayPush(songs, n"mus_radio_13_dstar_hagop");
      ArrayPush(songs, n"mus_radio_13_dstar_julek1");
      ArrayPush(songs, n"mus_radio_13_dstar_julek2");
      ArrayPush(songs, n"mus_radio_13_dstar_kyberpunk");
      ArrayPush(songs, n"mus_radio_13_dstar_minionsex");
      ArrayPush(songs, n"mus_radio_13_dstar_mzuzu");
      ArrayPush(songs, n"mus_radio_13_dstar_roller");
      ArrayPush(songs, n"mus_radio_13_dstar_zuukuka");
      ArrayPush(songs, n"mus_radio_13_dstar_drk");

      return songs;
    }

    if Equals(index, 13) {
      ArrayPush(songs, n"mus_radio_14impls_djset_pyramid_edit");

      return songs;
    }

    return songs;
  }

  private func FindStationIndexBySong(song: CName) -> Int32 {
    let index = 0;
    let songIndex: Int32;
    let songs: array<CName>;

    if Equals(song, n"") {
      return -1;
    }

    while index < 14 {
      songs = this.GetStationSongs(index);
      songIndex = 0;

      while songIndex < ArraySize(songs) {
        if Equals(songs[songIndex], song) {
          return index;
        }

        songIndex += 1;
      }

      index += 1;
    }

    return -1;
  }

  private func GetCurrentNativeSong(
    player: wref<PlayerPuppet>,
    mounted: Bool
  ) -> CName {
    let blackboard: ref<IBlackboard>;
    let pocketRadio: ref<PocketRadio>;
    let vehicle: wref<VehicleObject>;

    if !IsDefined(player) {
      return n"";
    }

    if !mounted {
      pocketRadio = player.GetPocketRadio();

      if !IsDefined(pocketRadio)
        || !pocketRadio.IsActive() {
        return n"";
      }

      return pocketRadio.GetTrackName();
    }

    vehicle = GetMountedVehicle(player);

    if !IsDefined(vehicle) {
      return n"";
    }

    blackboard = vehicle.GetBlackboard();

    if !IsDefined(blackboard)
      || !blackboard.GetBool(
        GetAllBlackboardDefs()
          .Vehicle
          .VehRadioState
      ) {
      return n"";
    }

    return vehicle.GetRadioReceiverTrackName();
  }

  private func GetActiveNativeStationIndex(
    player: wref<PlayerPuppet>,
    mounted: Bool,
    currentSong: CName
  ) -> Int32 {
    let blackboard: ref<IBlackboard>;
    let index: Int32;
    let pocketRadio: ref<PocketRadio>;
    let vehicle: wref<VehicleObject>;

    if !IsDefined(player) {
      return -1;
    }

    pocketRadio = player.GetPocketRadio();

    if !mounted {
      if !IsDefined(pocketRadio)
        || !pocketRadio.IsActive() {
        return -1;
      }

      index = pocketRadio.GetStation();

      if index >= 0 && index < 14 {
        return index;
      }

      return this.FindStationIndexBySong(currentSong);
    }

    vehicle = GetMountedVehicle(player);

    if !IsDefined(vehicle) {
      return -1;
    }

    blackboard = vehicle.GetBlackboard();

    if !IsDefined(blackboard)
      || !blackboard.GetBool(
        GetAllBlackboardDefs()
          .Vehicle
          .VehRadioState
      ) {
      return -1;
    }

    index = Cast<Int32>(vehicle.GetCurrentRadioIndex());

    if index >= 0 && index < 14 {
      return index;
    }

    return this.FindStationIndexBySong(currentSong);
  }

  private func GetSongDisplayTitle(song: CName) -> String {
    if Equals(song, n"mus_radio_02_aggro_ind_resist_and_disorder") {
      return "The Cartesian Duelists - Resist and Disorder";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_kill_the_messenger") {
      return "The Cartesian Duelists - Kill the Messenger";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_makes_me_feel_better") {
      return "Slavoj McAllister - Makes Me Feel Better";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_dead_pilot") {
      return "Keine - Dead Pilot";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_comeclose") {
      return "Keine - Come Close";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_black_terminal_vox_upgrade") {
      return "Upgrade - Black Terminal";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_reaktion") {
      return "Alexei Brayko - Reaktion";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_with_her") {
      return "Ego Affliciton - With Her";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_never_stop_me") {
      return "Den of Degenerates - Never Stop Me";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_violence") {
      return "The Red Glare - Violence";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_pain") {
      return "The Red Glare - Pain";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_night_city_aliens") {
      return "Homeshool Dropouts - Night City Aliens";
    }

    if Equals(song, n"mus_radio_02_aggroind_cyber_caca") {
      return "Tainted Overlord - Selva Pulsátil";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_cyber_tabla") {
      return "Tainted Overlord - A Caça";
    }

    if Equals(song, n"mus_radio_02_aggro_ind_pig_dinner") {
      return "N1v3z - Pig Dinner";
    }

    if Equals(song, n"mus_radio_03_elec_ind_dirty_roses") {
      return "Perilous Futur - Dirty Roses";
    }

    if Equals(song, n"mus_radio_03_elec_ind_worlds") {
      return "The Unresolved - Worlds";
    }

    if Equals(song, n"mus_radio_03_elec_ind_x") {
      return "The Unresolved - X";
    }

    if Equals(song, n"mus_radio_03_elec_ind_maniak") {
      return "Doctor Berserk - Maniak";
    }

    if Equals(song, n"mus_radio_03_electind_be_machine") {
      return "Generating Dependencies - Be Machine";
    }

    if Equals(song, n"mus_radio_03_electind_cyberpunk07") {
      return "Lick Switch - Like a Miracle";
    }

    if Equals(song, n"mus_radio_03_elec_ind_run") {
      return "Kings of Collapse - Run";
    }

    if Equals(song, n"mus_radio_03_elec_ind_ppgame05") {
      return "Reviscerator - Glitched Revelation";
    }

    if Equals(song, n"mus_radio_03_elec_ind_ppgame18") {
      return "Reviscerator - Yellow Box";
    }

    if Equals(song, n"mus_radio_03_elec_ind_killkill") {
      return "The Bait - KillKill";
    }

    if Equals(song, n"mus_radio_03_elec_ind_flying_heads") {
      return "Ashes Potts - Flyinghead";
    }

    if Equals(song, n"mus_radio_03_electind_cyberpunk03_") {
      return "Yards of the Moon - Volcano the Sailor";
    }

    if Equals(song, n"mus_radio_03_elect_ind_brain_damaged") {
      return "Cyber Coorayber - Brain-Damaged";
    }

    if Equals(song, n"mus_radio_03_elec_ind_neuron") {
      return "Auer - Neuron";
    }

    if Equals(song, n"mus_radio_04_hiphop_the_god_machines") {
      return "Kill Trigger feat. Paul Senai, Kakow - The God Machines";
    }

    if Equals(song, n"mus_radio_04_hiphop_blouses_blue") {
      return "NC3 - Blouses Blue";
    }

    if Equals(song, n"mus_radio_04_hiphop_problem_kids") {
      return "Young Kenny - Problem Kids";
    }

    if Equals(song, n"mus_radio_04_hiphop_bigger_man") {
      return "Droox - Bigger Man";
    }

    if Equals(song, n"mus_radio_04_hiphop_go_blaze") {
      return "One feat. G'Natt - Go Blaze";
    }

    if Equals(song, n"mus_radio_04_hiphop_dishonor") {
      return "Ichibanchi - Dishonor";
    }

    if Equals(song, n"mus_radio_04_hiphop_frost") {
      return "Yamete - Frost";
    }

    if Equals(song, n"mus_radio_04_hiphop_hs_bully") {
      return "UMVN feat. Imp Ra - High School Bully";
    }

    if Equals(song, n"mus_radio_04_hiphop_nbomdanalog") {
      return "DAPxFLEM - NBOMdANALOG";
    }

    if Equals(song, n"mus_radio_04_hiphop_suicide") {
      return "Code 137 - Suicide";
    }

    if Equals(song, n"mus_radio_04_hiphop_day_of_dead") {
      return "HAPS - Day of Dead";
    }

    if Equals(song, n"mus_radio_04_hiphop_bruzez") {
      return "Knixit - Bruzez";
    }

    if Equals(song, n"mus_radio_04_hiphop_clip_boss") {
      return "Sugarcoob feat. Anak Konda - Clip Boss";
    }

    if Equals(song, n"mus_radio_04_hiphop_plucku") {
      return "3XB feat. Gun-Fu - Pluck U";
    }

    if Equals(song, n"mus_radio_04_hiphop_goodmorn") {
      return "Pazoozu - Hello Good Morning";
    }

    if Equals(song, n"mus_radio_04_hiphop_run_the_block") {
      return "Bez Tatami feat. Gully Foyle - Run the Block";
    }

    if Equals(song, n"mus_radio_04_hiphop_gr4ves") {
      return "Kyubik - Gr4ves";
    }

    if Equals(song, n"mus_radio_04_hiphop_warning_shots") {
      return "Laputan Machine - Warningshots";
    }

    if Equals(song, n"mus_radio_04_hiphop_yugen_blakrok") {
      return "Gorgon Madonna - Metamorphosis";
    }

    if Equals(song, n"mus_radio_04_hiphop_no_save_point") {
      return "Yankee and the Brave - No Save Point";
    }

    if Equals(song, n"mus_radio_04_hiphop_ccc_flacko_loco") {
      return "Telo$ - Flacko Loko";
    }

    if Equals(song, n"mus_radio_04_hiphop_nose_bleed") {
      return "Pecero - Nose Bleed";
    }

    if Equals(song, n"mus_radio_04_hiphop_ccc") {
      return "Cacimbo - CCC";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_bios") {
      return "Error - Bios";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_drained") {
      return "Sao Mai - Drained";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_subvert") {
      return "Spoon Eater - Subvert";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_follow_the_white_crow") {
      return "Nablus - Follow the White Crow";
    }

    if Equals(song, n"mus_radio_08_aggro_techno_fake_spook") {
      return "Ioshrine - Fake Spook";
    }

    if Equals(song, n"mus_radio_08_aggro_techno_move_dat") {
      return "[Flesh]Reactor - Move .Dat";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_jam") {
      return "Cutex - La Canopée";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_acid") {
      return "Yards of the Moon - 1101 Break";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_really_heavy_groove") {
      return "Retinal Scam - Across the Floor";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_stoczterdziescitrzy") {
      return "Retinal Scam - Gridflow";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_zero_acid") {
      return "Skin<>Drifter - Undertow Velocity";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_cdpmetal_vascular") {
      return "Tar Hawk - Vascular";
    }

    if Equals(song, n"mus_radio_08_aggro_techno_cyberpunk02") {
      return "Tinnitus - On My Way To Hell";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_cannibalismus") {
      return "Bullet in the Head - Cannibalismus";
    }

    if Equals(song, n"mus_radio_07_aggro_techno_stack_overflow") {
      return "Blue Stahli & Clockwork OS - Stackoverflow";
    }

    if Equals(song, n"mus_radio_09_downtempo_isometric_air") {
      return "Quantum Lovers - Isometric Air";
    }

    if Equals(song, n"mus_radio_09_downtempo_real_window") {
      return "Quantum Lovers - Real Window";
    }

    if Equals(song, n"mus_radio_09_downtempo_practical_heart") {
      return "Quantum Lovers - Practical Heart";
    }

    if Equals(song, n"mus_radio_09_downtempo_antagonistic") {
      return "Pacific Avenue - Antagonistic";
    }

    if Equals(song, n"mus_radio_09_downtempo_simple_pleasures") {
      return "Jänsens - Simple Pleasures";
    }

    if Equals(song, n"mus_radio_09_downtempo_chodze") {
      return "Muchomorr - Chooze";
    }

    if Equals(song, n"mus_radio_09_downtempo_cyberpunk05") {
      return "Lick Switch - Midnight Eye";
    }

    if Equals(song, n"mus_radio_09_downtempo_cyberpunk06") {
      return "Lick Switch - Blurred";
    }

    if Equals(song, n"mus_radio_09_downtempo_cyberpunk08") {
      return "Lick Switch - The Other Room";
    }

    if Equals(song, n"mus_radio_09_downtempo_le_stessa_causa") {
      return "Sonoris Causa - La Stessa Causa";
    }

    if Equals(song, n"mus_radio_09_downtempo_dub_dub_mix_ambient") {
      return "Left Unsaid - Retrogenesis";
    }

    if Equals(song, n"mus_radio_09_downtempo_miami_suicide") {
      return "Talk To Us - Miami Suicide";
    }

    if Equals(song, n"mus_radio_09_downtempo_slippery_stabs") {
      return "Talk To Us - Slippery Stabs";
    }

    if Equals(song, n"mus_radio_09_downtempo_ashes_and_diamonds") {
      return "Wormview - Ashes and Diamonds";
    }

    if Equals(song, n"mus_radio_09_downtempo_cdprojekt2_uferlos") {
      return "Mona Mitchell - Ice Maddox";
    }

    if Equals(song, n"mus_radio_09_downtempo_demo4") {
      return "Flatlander Woman - Lithium";
    }

    if Equals(song, n"mus_radio_09_downtempo_demo7") {
      return "Flatlander Woman - Slag";
    }

    if Equals(song, n"mus_radio_01_att_rock_suffer_me") {
      return "Brutus Backlash - SufferMe";
    }

    if Equals(song, n"mus_radio_01_att_rock_heaven_ho") {
      return "XerzeX - Heave Ho";
    }

    if Equals(song, n"mus_radio_01_att_rock_i_will_follow") {
      return "Beached Tarantula - I Will Follow";
    }

    if Equals(song, n"mus_radio_01_attrock_likewise") {
      return "IBDY - LikeWise";
    }

    if Equals(song, n"mus_radio_01_att_rock_friday_night_fire_night") {
      return "The Rubicones - Friday Night Fire Fight";
    }

    if Equals(song, n"mus_radio_01_att_rock_trauma") {
      return "The Rubicones - Trauma";
    }

    if Equals(song, n"mus_radio_01_att_rock_mstr01") {
      return "Cutthroat - Sustain/Decay";
    }

    if Equals(song, n"mus_radio_01_att_rock_never_fade_away") {
      return "Samurai - Never Fade Away";
    }

    if Equals(song, n"mus_radio_01_att_rock_black_dog") {
      return "Samurai - Black Dog";
    }

    if Equals(song, n"mus_radio_01_att_rock_chippin_in") {
      return "Samurai - Chippin' In";
    }

    if Equals(song, n"mus_radio_01_att_rock_the_ballad") {
      return "Samurai - The Ballad of Buck Ravers";
    }

    if Equals(song, n"mus_radio_01_attrock_summer_of_2069") {
      return "Blood and Ice - Summer of 2069";
    }

    if Equals(song, n"mus_radio_01_att_rock_no_convenient_apocalypse") {
      return "Kruschev's Ghosts - No Convenient Apocalypse";
    }

    if Equals(song, n"mus_radio_01_attrock_to_the_fullest") {
      return "Artifical Kids - To the Fullest";
    }

    if Equals(song, n"mus_radio_01_attrock_so_it_goes") {
      return "Fingers and the Outlaws - So It Goes";
    }

    if Equals(song, n"mus_radio_05_pop_whos_ready") {
      return "IBDY - Who's Ready for Tomorrow";
    }

    if Equals(song, n"mus_radio_05_pop_cirque_du_soleil") {
      return "Neon Haze - Circus Minimus";
    }

    if Equals(song, n"mus_radio_05_pop_major_crimes") {
      return "Window Weather - Major Crimes";
    }

    if Equals(song, n"mus_radio_05_pop_night_city") {
      return "Artemis Delta - Night City";
    }

    if Equals(song, n"mus_radio_05_pop_i_want_to_stay_at_your_house") {
      return "Hallie Coggins - I Want to Stay at Your House";
    }

    if Equals(song, n"mus_radio_05_pop_hole_in_the_sun") {
      return "Point Break Candy - Hole In The Sun";
    }

    if Equals(song, n"mus_radio_05_pop_history") {
      return "Trash Generation - History";
    }

    if Equals(song, n"mus_radio_05_pop_ponpon_shit") {
      return "Us Cracks - Ponpon Shit";
    }

    if Equals(song, n"mus_radio_05_pop_crust_punk") {
      return "IBDY - Crustpunk";
    }

    if Equals(song, n"mus_radio_05_pop_heres_a_thought") {
      return "IBDY - Here's a Thought";
    }

    if Equals(song, n"mus_radio_05_pop_4aem") {
      return "Lizzy Wizzy - 4ÆM";
    }

    if Equals(song, n"mus_radio_05_pop_delicate_weapon") {
      return "Lizzy Wizzy - Delicate Weapon";
    }

    if Equals(song, n"mus_radio_05_pop_shygirl") {
      return "Clockwork Venus - BM";
    }

    if Equals(song, n"mus_radio_05_pop_user_friendly") {
      return "Us Cracks feat. Kerry Eurodyne - User Friendly";
    }

    if Equals(song, n"mus_radio_05_pop_off_the_leash") {
      return "Us Cracks - Off the Leash";
    }

    if Equals(song, n"mus_radio_10_latino_bamo") {
      return "Kartel Sonoro - Bamo";
    }

    if Equals(song, n"mus_radio_10_latino_daggafrica") {
      return "Kartel Sonoro - Daggafrica";
    }

    if Equals(song, n"mus_radio_10_latino_dinero") {
      return "7 Facas - Dinero";
    }

    if Equals(song, n"mus_radio_10_latino_serpant") {
      return "7 Facas - Serpant";
    }

    if Equals(song, n"mus_radio_10_latino_barrio") {
      return "Big Machete - Barrio";
    }

    if Equals(song, n"mus_radio_10_latino_tatted_on_my_face") {
      return "Don Mara - Tatted On My Face";
    }

    if Equals(song, n"mus_radio_10_latino_hood") {
      return "ChickyChickas - Hood";
    }

    if Equals(song, n"mus_radio_10_latino_cumbia") {
      return "Papito Gringo - Muévelo / Cumbia";
    }

    if Equals(song, n"mus_radio_10_latino_muertothrash") {
      return "FKxU - Muerto Thrash";
    }

    if Equals(song, n"mus_radio_10_latino_only_son") {
      return "ChickyChickas - Only Son";
    }

    if Equals(song, n"mus_radio_10_latino_westcoast_till_i_die") {
      return "DJ CholoZ - Westcoast Til I Die";
    }

    if Equals(song, n"mus_radio_11_metal_finis") {
      return "V3rm1n - Finis";
    }

    if Equals(song, n"mus_radio_11_metal_theaccursed") {
      return "Dread Soul - The Accursed";
    }

    if Equals(song, n"mus_radio_11_metal_march30") {
      return "Bacillus - March 30";
    }

    if Equals(song, n"mus_radio_11_metal_acid_breather") {
      return "Forlorn Scourge - Acid Breather";
    }

    if Equals(song, n"mus_radio_11_metal_2") {
      return "Nuclear Aura - Witches of the Harz Mountains";
    }

    if Equals(song, n"mus_radio_11_metal_the_loop") {
      return "Weles - The Loop";
    }

    if Equals(song, n"mus_radio_11_metal_scum") {
      return "Hysteria - Scum";
    }

    if Equals(song, n"mus_radio_11_metal_fueled_by_poison") {
      return "Inferno Corps - Fueled by Poison";
    }

    if Equals(song, n"mus_radio_11_metal_kevin") {
      return "Inferno Corps - Kevin";
    }

    if Equals(song, n"mus_radio_11_metal_future_drags") {
      return "heXXXer - Future Drugs";
    }

    if Equals(song, n"mus_radio_11_metal_zurawie") {
      return "Wydech - Żurawie";
    }

    if Equals(song, n"mus_radio_11_metal_abandoned_land") {
      return "Fist of Satan - Abandoned Land";
    }

    if Equals(song, n"mus_radio_11_metal_black_concrete") {
      return "Fist of Satan - Black Concrete";
    }

    if Equals(song, n"mus_radio_11_metal_i_wont_let_you_go") {
      return "Shattered Void - I Won't Let You Go";
    }

    if Equals(song, n"mus_radio_06_minim_tech_pilling_in_my_head") {
      return "Bara Nova - Pilling in My Head";
    }

    if Equals(song, n"mus_radio_06_minim_tech_delirium2") {
      return "Bara Nova - Delirium 2";
    }

    if Equals(song, n"mus_radio_06_minim_tech_harm_sweaty_pit") {
      return "Bara Nova - Harm Sweaty Pit";
    }

    if Equals(song, n"mus_radio_06_minim_tech_my_lullaby_for_you") {
      return "Bara Nova - My Lullaby for You";
    }

    if Equals(song, n"mus_radio_06_minim_tech_surprise_me") {
      return "Bara Nova - Surprise Me, I'm Surprised Today";
    }

    if Equals(song, n"mus_radio_08_jazz_black_satin_what_if_agharta") {
      return "Miles Davis - Black Satin / What If / Agharta Prelude Dub";
    }

    if Equals(song, n"mus_radio_08_jazz_bitches_brew") {
      return "Miles Davis - Bitches Brew";
    }

    if Equals(song, n"mus_radio_08_jazz_generique") {
      return "Miles Davis - Ascenseur Pour L'Échafaud - Générique";
    }

    if Equals(song, n"mus_radio_08_jazz_impressions") {
      return "John Coltrane - Impressions";
    }

    if Equals(song, n"mus_radio_08_jazz_solo_dancer") {
      return "Charles Mingus - The Black Saint and the Sinner Lady - Solo Dancer";
    }

    if Equals(song, n"mus_radio_08_jazz_laura") {
      return "Dexter Gordon - Sophisticated Giant - Laura";
    }

    if Equals(song, n"mus_radio_08_jazz_you_dont_know_what_love_is") {
      return "Chet Baker - You Don't Know What Love Is";
    }

    if Equals(song, n"mus_radio_08_jazz_round_midnight") {
      return "Thelonius Monk - 'Round Midnight";
    }

    if Equals(song, n"mus_radio_08_jazz_dark_prince") {
      return "John McLaughlin - Dark Prince";
    }

    if Equals(song, n"mus_radio_12_afterlife") {
      return "Thai McGrath (ft. JustCosplaySings) - Afterlife";
    }

    if Equals(song, n"mus_radio_12_candyshell") {
      return "Spirit Machines - Candy Shell";
    }

    if Equals(song, n"mus_radio_12_ch") {
      return "Haru Nemuri - Samayoeru mama yuke";
    }

    if Equals(song, n"mus_radio_12_do_or_die") {
      return "NoWorld - Do or Die";
    }

    if Equals(song, n"mus_radio_12_flatline") {
      return "Red Dead Roadkill - Flatline";
    }

    if Equals(song, n"mus_radio_12_fumes") {
      return "Aleyna Moon, Shrinjay Ghosh - FUMES";
    }

    if Equals(song, n"mus_radio_12_killshot") {
      return "Frost, Justtjokay, Dubbygotbars, Knyvez - Killshot";
    }

    if Equals(song, n"mus_radio_12_kiroshi") {
      return "D.O.H. - Look Through My Kiroshis";
    }

    if Equals(song, n"mus_radio_12_lit") {
      return "Entolim - LIT";
    }

    if Equals(song, n"mus_radio_12_skin_on_flesh") {
      return "Skin on Flesh - El Tiempo";
    }

    if Equals(song, n"mus_radio_12_slipstream") {
      return "Kiba - Slipstream";
    }

    if Equals(song, n"mus_radio_12_stars_die") {
      return "Coeur Noir - Let the Stars Die";
    }

    if Equals(song, n"mus_radio_12_to_heaven") {
      return "St. Aurora - Going to Heaven";
    }

    if Equals(song, n"mus_radio_13_dstar_27fuckdemons") {
      return "OLO Y - Pierwszy raz naprawdę";
    }

    if Equals(song, n"mus_radio_13_dstar_backxwash") {
      return "BADPANNINI - Headrush";
    }

    if Equals(song, n"mus_radio_13_dstar_chokehold") {
      return "Mr. Kipper - Choke Hold";
    }

    if Equals(song, n"mus_radio_13_dstar_cykoarctic") {
      return "BWANA MUNGU - CykoArctic";
    }

    if Equals(song, n"mus_radio_13_dstar_hagop") {
      return "No Strings Attached - Orbital Insertion";
    }

    if Equals(song, n"mus_radio_13_dstar_julek1") {
      return "DJ papergekko - NUCLEAR DREAMLAND";
    }

    if Equals(song, n"mus_radio_13_dstar_julek2") {
      return "DJ papergekko - Bigger Crimes";
    }

    if Equals(song, n"mus_radio_13_dstar_kyberpunk") {
      return "Her Mashewski - fabrica KOSMOS";
    }

    if Equals(song, n"mus_radio_13_dstar_minionsex") {
      return "Mightonauts - Minion Sex";
    }

    if Equals(song, n"mus_radio_13_dstar_mzuzu") {
      return "Łotr - Memories of Mzuzu";
    }

    if Equals(song, n"mus_radio_13_dstar_roller") {
      return "Mr. Kipper - Rolla";
    }

    if Equals(song, n"mus_radio_13_dstar_zuukuka") {
      return "ECKO FREQUENCY - Zuuka";
    }

    if Equals(song, n"mus_radio_13_dstar_drk") {
      return "Walt Air - dRk";
    }

    if Equals(song, n"mus_radio_14impls_djset_pyramid_edit") {
      return "DJSET";
    }

    return "";
  }

  public func GetLastSkippedTrackTitle() -> String {
    return this.m_lastSkippedTrackTitle;
  }
  private func RebuildOrder(
    songs: array<CName>,
    currentSong: CName
  ) -> Void {
    let count = ArraySize(songs);
    let i = 0;
    let randomIndex: Int32;
    let temporaryIndex: Int32;

    ArrayClear(this.m_order);

    while i < count {
      ArrayPush(this.m_order, i);
      i += 1;
    }

    i = count - 1;

    while i > 0 {
      randomIndex = RandRange(0, i);
      temporaryIndex = this.m_order[i];
      this.m_order[i] = this.m_order[randomIndex];
      this.m_order[randomIndex] = temporaryIndex;
      i -= 1;
    }

    if count > 1
      && NotEquals(currentSong, n"")
      && Equals(songs[this.m_order[0]], currentSong) {
      temporaryIndex = this.m_order[0];
      this.m_order[0] = this.m_order[1];
      this.m_order[1] = temporaryIndex;
    }

    this.m_orderPosition = 0;
  }

  private func GetNextSong(
    station: CName,
    songs: array<CName>,
    currentSong: CName
  ) -> CName {
    let count = ArraySize(songs);
    let nextIndex: Int32;
    let temporaryIndex: Int32;

    if count < 1 {
      return n"";
    }

    if NotEquals(this.m_station, station)
      || NotEquals(this.m_playlistSize, count)
      || this.m_orderPosition >= ArraySize(this.m_order) {
      this.m_station = station;
      this.m_playlistSize = count;
      this.RebuildOrder(songs, currentSong);
    }

    nextIndex = this.m_order[this.m_orderPosition];

    if count > 1 && Equals(songs[nextIndex], currentSong) {
      if this.m_orderPosition + 1 < ArraySize(this.m_order) {
        temporaryIndex = this.m_order[this.m_orderPosition];
        this.m_order[this.m_orderPosition] =
          this.m_order[this.m_orderPosition + 1];
        this.m_order[this.m_orderPosition + 1] = temporaryIndex;
        nextIndex = this.m_order[this.m_orderPosition];
      } else {
        this.RebuildOrder(songs, currentSong);
        nextIndex = this.m_order[0];
      }
    }

    this.m_orderPosition += 1;

    return songs[nextIndex];
  }

  private func Lock() -> Void {
    let callback = new AWNativeRadioSkipUnlockCallback();

    this.m_locked = true;

    GameInstance
      .GetDelaySystem(GetGameInstance())
      .DelayCallback(
        callback,
        1.0,
        false
      );
  }

  public func TrySkip(player: wref<PlayerPuppet>) -> Bool {
    let audioSystem = GameInstance.GetAudioSystem(
      player.GetGame()
    );
    let currentSong: CName;
    let mounted: Bool;
    let nextSong: CName;
    let playlist: array<CName>;
    let station: CName;
    let stationIndex: Int32;

    if this.m_locked
      || !IsDefined(player)
      || !IsDefined(audioSystem) {
      return false;
    }

    mounted = IsDefined(GetMountedVehicle(player));
    currentSong = this.GetCurrentNativeSong(
      player,
      mounted
    );
    stationIndex = this.GetActiveNativeStationIndex(
      player,
      mounted,
      currentSong
    );
    station = this.GetStationNameByIndex(stationIndex);

    if stationIndex < 0 || Equals(station, n"") {

      return false;
    }

    playlist = this.GetStationSongs(stationIndex);

    if Equals(ArraySize(playlist), 0) {

      return false;
    }

    nextSong = this.GetNextSong(
      station,
      playlist,
      currentSong
    );

    if Equals(nextSong, n"") {

      return false;
    }

    this.m_lastSkippedTrackTitle =
      this.GetSongDisplayTitle(nextSong);

    audioSystem.RequestSongOnRadioStation(
      station,
      nextSong
    );

    this.Lock();

    return true;
  }
}
