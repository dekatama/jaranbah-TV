import 'package:jarambahtv/channels/istream.dart';
import 'package:jarambahtv/localization/translations.dart';
import 'package:jarambahtv/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

abstract class IStreamSearchDelegate<T extends IStream> extends SearchDelegate {
  final List<T> streams;
  final String hint;

  IStreamSearchDelegate(this.streams, this.hint)
      : super(searchFieldLabel: hint);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theming.of(context).theme;
    final color = Theming.of(context).onPrimary();
    return theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme
            .copyWith(hintStyle: TextStyle(color: color.withOpacity(0.7))),
        textTheme:
            theme.textTheme.copyWith(headline6: TextStyle(color: color)));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = streams.where(resultsCriteria);
    if (query.isEmpty || results.isEmpty) {
      return _NothingFound();
    }

    return list(results.toList());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = streams.where(suggestionsCriteria);
    if (query.isEmpty || results.isEmpty) {
      return _NothingFound();
    }

    return list(results.toList());
  }

  bool resultsCriteria(T s) => s.displayName().toLowerCase().contains(query);

  bool suggestionsCriteria(T s) =>
      s.displayName().toLowerCase().contains(query);

  Widget list(List<T> results);
}

class _NothingFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: NonAvailableBuffer(
            icon: Icons.search,
            message: AppLocalizations.of(context).translate(TR_SEARCH_EMPTY)));
  }
}
