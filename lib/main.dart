/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:dio/dio.dart';
import 'package:downloader/downloader.dart';
import 'package:downloader_demo/page/home_page.dart';
import 'package:flutter/cupertino.dart';

void main() {
  Downloader.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));
  runApp(const DemoApp());
}

/// App
class DemoApp extends StatelessWidget {
  /// 构造函数
  const DemoApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'Downloader Demo',
      home: HomePage(
        title: '下载管理器',
      ),
    );
  }
}
