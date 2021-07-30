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

/// Created by box on 2021/7/31.
///
/// 下载进程
class Task extends StatefulWidget {
  /// 下载进程
  const Task({
    Key? key,
    required this.url,
  }) : super(key: key);

  /// 文件链接
  final String url;

  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> with AutomaticKeepAliveClientMixin<Task> {
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
        widget.url,
        join(directory.path, '$timestamp.mp4'),
        cancelToken: _cancelToken,
        onReceiveProgress: _setProgress,
      );
      _cancelToken = null;
    } finally {
      await Future<void>.delayed(_delayedDuration);
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
      message = '正在下载...';
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
      return '--M';
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget trailing;
    if (_cancelToken == null) {
      trailing = CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        minSize: 0,
        onPressed: _cancelToken == null ? _onDownload : null,
        child: const Icon(
          CupertinoIcons.play_arrow_solid,
          size: 16,
        ),
      );
    } else {
      trailing = CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        minSize: 0,
        onPressed: _cancelToken == null ? null : _onCancel,
        child: const Icon(
          CupertinoIcons.clear,
          size: 16,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _message ?? '等待下载',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (_value != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Text(
                    '(${(_value! * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.separator,
                    width: 0,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: trailing,
              ),
            ],
          ),
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
              value: _value ?? 0,
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
    );
  }
}