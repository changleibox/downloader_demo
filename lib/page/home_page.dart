/*
 * Copyright (c) 2021 CHANGLEI. All rights reserved.
 */

import 'package:dio/dio.dart';
import 'package:downloader/downloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const _delayedDuration = Duration(seconds: 1);
const _mSize = 1024 * 1024;
const _kSize = 1024;

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
  CancelToken? _cancelToken;

  int? _count;
  int? _total;

  Future<void> _onDownload() async {
    _setProgress(0, 0);
    try {
      _cancelToken?.cancel();
      _cancelToken = CancelToken();
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      await Downloader.asFile(
        'http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8',
        join(directory.path, '$timestamp.mp4'),
        cancelToken: _cancelToken,
        onReceiveProgress: _setProgress,
      );
      await Future<void>.delayed(_delayedDuration);
    } finally {
      _setProgress();
    }
  }

  void _setProgress([int? count, int? total]) {
    _safeSetState(() {
      _count = count;
      _total = total;
    });
  }

  void _onCancel() {
    _safeSetState(() {
      _cancelToken?.cancel();
      _cancelToken = null;
    });
  }

  void _safeSetState(VoidCallback callback) {
    if (!mounted) {
      return;
    }
    setState(callback);
  }

  String? get _message {
    String? message;
    if (_value == 0) {
      message = '准备下载...';
    } else if (_value == 1) {
      message = '下载完成';
    } else if (_value != null) {
      message = '正在下载(${(_value! * 100).toStringAsFixed(0)}%)...';
    }
    return message;
  }

  double? get _value {
    if (_count == null || _total == null) {
      return null;
    }
    return _total == 0 ? 0 : _count! / _total!;
  }

  String _formatSize(int? size) {
    if (size == null) {
      return '--';
    }
    if (size >= _mSize) {
      return '${(size / _mSize).toStringAsFixed(1)}M';
    } else if (size >= _kSize) {
      return '${(size / _kSize).toStringAsFixed(1)}K';
    } else {
      return '${size}B';
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _cancelToken = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget trailing;
    if (_cancelToken == null) {
      trailing = CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        onPressed: _cancelToken == null ? _onDownload : null,
        child: const Text('下载'),
      );
    } else {
      trailing = CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        onPressed: _cancelToken == null ? null : _onCancel,
        child: const Text('取消'),
      );
    }
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: trailing,
      ),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_message ?? '等待下载'),
            const SizedBox(
              height: 8,
            ),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: const ShapeDecoration(
                shape: StadiumBorder(),
              ),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: _value,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            DefaultTextStyle(
              style: const TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatSize(_count)),
                  Text(_formatSize(_total)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
