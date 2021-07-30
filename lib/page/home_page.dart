/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:downloader_demo/widget/task.dart';
import 'package:flutter/cupertino.dart';

/// Created by box on 2021/7/30.
///
/// 首页
class HomePage extends StatefulWidget {
  /// 构造函数
  const HomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  /// 标题
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _urls = List.generate(10, (index) => 'http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8');

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: Builder(builder: (context) {
        final padding = MediaQuery.of(context).padding;
        return ListView.separated(
          padding: const EdgeInsets.all(15) + padding,
          itemCount: _urls.length,
          itemBuilder: (context, index) {
            return Task(
              url: _urls[index],
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 10,
            );
          },
        );
      }),
    );
  }
}
