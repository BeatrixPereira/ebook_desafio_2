import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/book.dart';

class BookTile extends StatelessWidget {
  final Book book;
  final Function() onDownloadPressed;
  final Function() onReadPressed;
  final Function() onFavoritePressed;
  final bool isFavorite;
  final String defaultPath;

  BookTile({
    required this.book,
    required this.onDownloadPressed,
    required this.onReadPressed,
    required this.onFavoritePressed,
    required this.isFavorite,
    required this.defaultPath,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return GestureDetector(
      onTap: () async {
        if (isFileDownloaded(getFilePath(book))) {
          await onReadPressed();
        } else {
          await onDownloadPressed();
          onReadPressed();
        }
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                book.cover_url,
                fit: BoxFit.contain,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    isFileDownloaded(getFilePath(book))
                        ? Icons.check_box
                        : Icons.download,
                    color: Colors.blue,
                  ),
                  onPressed: onDownloadPressed,
                ),
                IconButton(
                  icon: Icon(
                      isFavorite
                          ? Icons.bookmark_added
                          : Icons.bookmark_add_outlined,
                      color: Colors.red),
                  onPressed: onFavoritePressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool isFileDownloaded(String filePath) {
    return File(filePath).existsSync();
  }

  String getFilePath(Book book) {
    String path = '$defaultPath/${book.title}.epub';
    return path;
  }
}
