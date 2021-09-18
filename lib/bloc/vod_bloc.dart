import 'package:jarambahtv/base/stream_parser.dart';
import 'package:jarambahtv/bloc/base_bloc.dart';
import 'package:jarambahtv/channels/vod_stream.dart';
import 'package:jarambahtv/localization/translations.dart';
import 'package:jarambahtv/mobile/vods/movie_desc.dart';
import 'package:jarambahtv/service_locator.dart';
import 'package:jarambahtv/shared_prefs.dart';
import 'package:jarambahtv/tv/vods/tv_vod_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class VodStreamBloc extends BaseStreamBloc<VodStream> {
  VodStreamBloc(List<VodStream> streams, NavigatorState navigator)
      : super(streams, navigator);

  @override
  Map<String, List<VodStream>> parseMap(List<VodStream> streams) {
    return StreamsParser<VodStream>(streams).parseChannels();
  }

  @override
  void onSearch(VodStream stream) => onTap(stream);

  @override
  void saveStreams() {
    final settings = locator<LocalStorageService>();
    settings.saveVods(map[TR_ALL]);
  }

  void onTap(VodStream channel) async {
    final previousFavorite = channel.favorite();
    await navigator.push(
        MaterialPageRoute(builder: (context) => _descriptionPage(channel)));
    if (previousFavorite != channel.favorite()) {
      handleFavorite(channel.favorite(), channel);
    }
    addRecent(channel);
  }

  Widget _descriptionPage(VodStream channel) {
    final device = locator<RuntimeDevice>();
    if (device.hasTouch) {
      return VodDescription(vod: channel);
    } else {
      return TvVodDescription(channel);
    }
  }
}
