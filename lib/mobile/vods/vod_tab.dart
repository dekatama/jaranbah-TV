import 'package:jarambahtv/base/vods/constants.dart';
import 'package:jarambahtv/base/vods/vod_card_favorite_pos.dart';
import 'package:jarambahtv/bloc/vod_bloc.dart';
import 'package:jarambahtv/channels/vod_stream.dart';
import 'package:jarambahtv/localization/translations.dart';
import 'package:jarambahtv/mobile/base_tab.dart';
import 'package:jarambahtv/mobile/vods/vod_edit_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/vods/vod_card.dart';

class VodTab extends StatefulWidget {
  final VodStreamBloc bloc;

  const VodTab(Key key, this.bloc) : super(key: key);

  @override
  VodVideoAppState createState() => VodVideoAppState();
}

class VodVideoAppState extends IStreamBaseListPage<VodStream, VodTab> {
  @override
  VodStreamBloc get bloc => widget.bloc;

  @override
  String noRecent() {
    return AppLocalizations.of(context).translate(TR_RECENT_VOD);
  }

  @override
  String noFavorite() {
    return AppLocalizations.of(context).translate(TR_FAVORITE_VOD);
  }

  @override
  Widget listBuilder(List<VodStream> channels) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: CARD_WIDTH + 2 * EDGE_INSETS,
                    crossAxisSpacing: EDGE_INSETS,
                    mainAxisSpacing: EDGE_INSETS,
                    childAspectRatio: 2 / 3),
                itemCount: channels.length,
                itemBuilder: (BuildContext context, int index) =>
                    tile(index, channels))));
  }

  Widget tile(int index, List<VodStream> channels) {
    final channel = channels[index];
    return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: EDGE_INSETS, vertical: EDGE_INSETS * 1.5),
        child: Stack(children: <Widget>[
          VodCard(
              iconLink: channel.icon(),
              duration: channel.duration(),
              interruptTime: channel.interruptTime(),
              width: CARD_WIDTH,
              onPressed: () {
                bloc.onTap(channel);
              }),
          VodFavoriteButton(
              width: 72,
              height: 36,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        width: 36,
                        child: FavoriteStarButton(channel.favorite(),
                            onFavoriteChanged: (bool value) {
                          handleFavorite(value, channel);
                        })),
                    SizedBox(
                        width: 36,
                        child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              onEdit(channel);
                            }))
                  ]))
        ]));
  }

  void onEdit(VodStream stream) {
    final List<String> oldGroups = [];
    oldGroups.addAll(stream.groups());
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VodEditPage(stream);
    })).then((value) {
      if (value != null) {
        if (value.id() == null) {
          delete(value);
        } else {
          edit(value, oldGroups);
        }
      }
    });
  }
}
