import 'dart:async';
import 'dart:developer';

import 'package:fastotv_dart/commands_info/channel_info.dart';
import 'package:fastotv_dart/commands_info/epg_info.dart';
import 'package:fastotv_dart/commands_info/meta_url.dart';
import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:fastotv_dart/commands_info/stream_base_info.dart';
import 'package:fastotv_dart/epg_parser.dart';
import 'package:jarambahtv/channels/istream.dart';
import 'package:jarambahtv/constants.dart';
import 'package:jarambahtv/service_locator.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class LiveStream extends IStream {
  static const int MAX_PROGRAMS_COUNT = 100;
  final ChannelInfo _channelInfo;
  String _epgUrl;
  bool _requested = false;

  LiveStream(ChannelInfo channel, String epg)
      : _channelInfo = channel,
        _epgUrl = epg;

  @override
  String id() {
    return _channelInfo.id;
  }

  @override
  void setId(String value) {
    _channelInfo.id = value;
  }

  @override
  String primaryUrl() {
    return _channelInfo.primaryLink();
  }

  @override
  void setPrimaryUrl(String value) {
    _channelInfo.epg.urls[0] = value;
  }

  @override
  String displayName() {
    return _channelInfo.displayName();
  }

  @override
  void setDisplayName(String value) {
    _channelInfo.epg.display_name = value;
  }

  @override
  List<String> groups() {
    return _channelInfo.groups;
  }

  @override
  void setGroups(List<String> value) {
    _channelInfo.groups = value;
  }

  String epgUrl() {
    return _epgUrl;
  }

  void setEpgUrl(String value) {
    _epgUrl = value;
  }

  @override
  String icon() {
    return _channelInfo.epg.icon;
  }

  @override
  void setIcon(String value) {
    _channelInfo.epg.icon = value;
  }

  @override
  int iarc() {
    return _channelInfo.iarc;
  }

  @override
  void setIarc(int value) {
    _channelInfo.iarc = value;
  }

  @override
  bool favorite() {
    return _channelInfo.favorite;
  }

  @override
  void setFavorite(bool value) {
    _channelInfo.favorite = value;
  }

  @override
  int recentTime() {
    return _channelInfo.recent;
  }

  @override
  void setRecentTime(int value) {
    _channelInfo.recent = value;
  }

  Future<void> requestProgrammes() async {
    if (_requested) {
      return _channelInfo.epg.programs;
    }
    _requested = true;
    return _httpRequest();
  }

  ProgrammeInfo findProgrammeByTime(int time) {
    return _channelInfo.epg.findProgrammeByTime(time);
  }

  List<ProgrammeInfo> programs() {
    return _channelInfo.epg.programs;
  }

  void setRequested(bool requested) {
    _requested = requested;
    if (!_requested) {
      _channelInfo.epg.programs = [];
    }
  }

  // private:
  Future<void> _httpRequest() async {
    final Completer<void> initializingCompleter = Completer<void>();

    initializingCompleter.complete(null);
    if (_epgUrl.isEmpty) {
      return initializingCompleter.future;
    }

    final epgId = _channelInfo.epg.id;
    if (epgId?.isEmpty ?? true) {
      return initializingCompleter.future;
    }

    try {
      final response = await http.get(Uri.parse('$_epgUrl/$epgId.xml'));
      if (response.statusCode != 200) {
        return initializingCompleter.future;
      }
      _channelInfo.epg.programs = parseXmlContent(response.body);
      if (_channelInfo.epg.programs.length > MAX_PROGRAMS_COUNT) {
        final _timeManager = locator<TimeManager>();
        final int curUtc = await _timeManager.realTime();
        final last = _sliceLastByTime(_channelInfo.epg.programs, curUtc);
        if (last.length > MAX_PROGRAMS_COUNT) {
          last.length = MAX_PROGRAMS_COUNT;
        }
        _channelInfo.epg.programs = last;
      }
      return initializingCompleter.future;
    } catch (e) {
      log('Programs request error: ' + '$e');
      return initializingCompleter.future;
    }
  }

  static List<ProgrammeInfo> _sliceLastByTime(
      List<ProgrammeInfo> origin, int time) {
    for (int i = 0; i < origin.length; ++i) {
      final pr = origin[i];
      if (time >= pr.start && time <= pr.stop) {
        return origin.sublist(i);
      }
    }

    return <ProgrammeInfo>[];
  }

  static const EPG_URL_FIELD = 'epg_url';
  static const REQUESTED_FEILD = 'requested';

  LiveStream.empty()
      : _channelInfo = ChannelInfo(
            const Uuid().v1(),
            <String>[],
            0,
            false,
            0,
            0,
            false,
            EpgInfo('', [''], '', '', []),
            true,
            true,
            null,
            0,
            <MetaUrl>[],
            true),
        _epgUrl = EPG_URL,
        _requested = false;

  LiveStream.fromJson(Map<String, dynamic> json)
      : _channelInfo = ChannelInfo(
            json[StreamBaseInfo.ID_FIELD],
            json[StreamBaseInfo.GROUPS_FIELD].cast<String>(),
            json[StreamBaseInfo.IARC_FIELD],
            json[StreamBaseInfo.FAVORITE_FIELD],
            json[StreamBaseInfo.RECENT_FIELD],
            0,
            false,
            EpgInfo(json[StreamBaseInfo.ID_FIELD], [json[EpgInfo.URLS_FIELD]],
                json[EpgInfo.DISPLAY_NAME_FIELD], json[EpgInfo.ICON_FIELD], []),
            true,
            true,
            null,
            0,
            <MetaUrl>[],
            true),
        _epgUrl = json[EPG_URL_FIELD] ?? EPG_URL,
        _requested = false;

  Map<String, dynamic> toJson() => {
        StreamBaseInfo.ID_FIELD: id(),
        StreamBaseInfo.GROUPS_FIELD: groups(),
        StreamBaseInfo.IARC_FIELD: iarc(),
        StreamBaseInfo.FAVORITE_FIELD: favorite(),
        StreamBaseInfo.RECENT_FIELD: recentTime(),
        EpgInfo.URLS_FIELD: primaryUrl(),
        EpgInfo.DISPLAY_NAME_FIELD: displayName(),
        EpgInfo.ICON_FIELD: icon(),
        REQUESTED_FEILD: _requested,
        EPG_URL_FIELD: epgUrl()
      };
}
