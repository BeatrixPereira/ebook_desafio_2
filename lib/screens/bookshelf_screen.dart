import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:ebook_desafio/services/favorites_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/book_tile.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'favorites_screen.dart';

class BookshelfScreen extends StatefulWidget {
  @override
  _BookshelfScreenState createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  late ApiService apiService;
  late StorageService storageService;
  late List<Book> books;
  bool loading = false;
  Dio dio = Dio();
  late List<String> favorites;
  List<Book> favoriteBooks = [];
  late String defaultPath;

  @override
  void initState() {
    super.initState();
    apiService = ApiService('https://escribo.com/books.json');
    storageService = StorageService();
    books = [];
    favorites = [];
  }

  Future<void> _loadBooks() async {
    final loadedBooks = await apiService.fetchBooks();
    books = loadedBooks;
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

  Future<void> onFavoritePressed(Book book) async {
    favorites = await FavoritesService.getFavorites();

    if (favorites.contains(book.id.toString())) {
      await FavoritesService.removeFavorite(book.id.toString());
      favoriteBooks.remove(book);
      Fluttertoast.showToast(msg: 'Livro removido dos favoritos');
    } else {
      await FavoritesService.addFavorite(book.id.toString());
      favoriteBooks.add(book);
      Fluttertoast.showToast(msg: 'Livro adicionado aos favoritos');
    }
    favorites = await FavoritesService.getFavorites();
    setState(() {});
  }

  int _calculateCrossAxisCount() {
    double screenWidth = ScreenUtil().screenWidth;

    if (screenWidth > 600) {
      return 4; // Em telas largas, exibe 4 colunas
    } else {
      return 2; // Em telas estreitas, exibe 2 colunas
    }
  }

  Widget _buildGridView() {
    return SingleChildScrollView(
      child: GridView.builder(
        physics:
            BouncingScrollPhysics(), // Use ClampingScrollPhysics() se preferir um efeito de rolagem diferente
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _calculateCrossAxisCount(),
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: books.length,
        shrinkWrap:
            true, // Isso faz com que o widget GridView tenha apenas a altura necessária para seus filhos
        itemBuilder: (context, index) {
          return AbsorbPointer(
            absorbing: loading,
            child: BookTile(
              defaultPath: defaultPath,
              book: books[index],
              onDownloadPressed: () => download(books[index]),
              onReadPressed: () => _openBook(books[index]),
              onFavoritePressed: () => onFavoritePressed(books[index]),
              isFavorite: favorites.contains(books[index].id.toString()),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return FutureBuilder(
        future: _loadMethods(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Estante Virtual'),
              actions: [
                IconButton(
                  icon: Icon(Icons.bookmark),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavoritesScreen(
                                favoriteBooks,
                                defaultPath: defaultPath,
                              )),
                    );
                  },
                ),
              ],
            ),
            body: _buildGridView(),
          );
        });
  }

  Future<void> _loadPath() async {
    Directory? appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    defaultPath = appDocDir!.path;
  }

  Future<void> _loadFavorites() async {
    favoriteBooks = [];
    favorites = await FavoritesService.getFavorites();

    for (String? id in favorites) {
      if (id != null) {
        Book? favoriteBook;

        for (Book book in books) {
          if (book.id.toString() == id) {
            favoriteBook = book;
            break;
          }
        }

        if (favoriteBook != null) {
          favoriteBooks.add(favoriteBook);
        }
      }
    }
  }

  Future<void> _loadMethods() async {
    await _loadBooks();
    await _loadPath();
    await _loadFavorites();
  }
}
