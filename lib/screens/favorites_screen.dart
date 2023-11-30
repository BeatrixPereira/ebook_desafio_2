import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import '../models/book.dart';
import '../widgets/book_tile.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Book> favoriteBooks;
  final String defaultPath;

  FavoritesScreen(this.favoriteBooks, {super.key, required this.defaultPath});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Dio dio = Dio();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: widget.favoriteBooks.length,
        itemBuilder: (context, index) {
          return BookTile(
            book: widget.favoriteBooks[index],
            onDownloadPressed: () => download(widget.favoriteBooks[index]),
            onReadPressed: () => _openBook(widget.favoriteBooks[index]),
            onFavoritePressed: () {},
            isFavorite: true,
            defaultPath: widget.defaultPath,
          );
        },
      ),
    );
  }

  Future<void> download(Book book) async {
    if (Platform.isAndroid || Platform.isIOS) {
      String? firstPart;
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      final allInfo = deviceInfo.data;
      if (allInfo['version']["release"].toString().contains(".")) {
        int indexOfFirstDot = allInfo['version']["release"].indexOf(".");
        firstPart = allInfo['version']["release"].substring(0, indexOfFirstDot);
      } else {
        firstPart = allInfo['version']["release"];
      }
      int intValue = int.parse(firstPart!);
      if (intValue >= 13) {
        await _downloadBook(book);
      } else {
        if (await Permission.storage.isGranted) {
          await Permission.storage.request();
          await _downloadBook(book);
        } else {
          await _downloadBook(book);
        }
      }
    } else {
      loading = false;
    }
  }

  Future<void> _downloadBook(Book book) async {
    Fluttertoast.showToast(
        msg: 'Baixando Livro', toastLength: Toast.LENGTH_SHORT);
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    String path = appDocDir!.path + '/${book.title}.epub';

    File file = File(path);

    if (!File(path).existsSync()) {
      await file.create();
      await dio.download(
        book.download_url,
        path,
        deleteOnError: true,
        onReceiveProgress: (receivedBytes, totalBytes) {
          setState(() {
            loading = true;
          });
        },
      ).whenComplete(() {
        setState(() {
          loading = false;
        });
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _openBook(Book book) async {
    Fluttertoast.showToast(msg: 'Carregando Ebook, aguarde...');
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    String path = appDocDir!.path + '/${book.title}.epub';

    VocsyEpub.setConfig(
      themeColor: Theme.of(context).primaryColor,
      identifier: "iosBook",
      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
      allowSharing: true,
      enableTts: true,
      nightMode: true,
    );

    // get current locator
    VocsyEpub.locatorStream.listen((locator) {
      print('LOCATOR: $locator');
    });

    VocsyEpub.open(
      path,
    );
  }
}
