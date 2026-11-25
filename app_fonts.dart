/// SF（San Francisco）字体接入
///
/// 关键事实：iOS 设备本身就内置 SF，Flutter 在 iOS 上默认就渲染 SF 字形，
/// 系统族名是 '.SF UI Text'（小字号）/ '.SF UI Display'（20pt 以上）。
/// 之前用的 'SF Pro Text' / 'SF Pro Display' 是下载字体包里的名字，
/// iOS 系统字体表里没有这两个族名，所以那些回退项从未命中。
///
/// 因此 useSystemSF = true（默认）时：
///   - iOS 真机 / 模拟器：100% 原生 SF 字形，不需要打包任何字体文件
///   - Android / Windows / Web：找不到该族名，自动忽略并回退系统字体，不会报错
///
/// 只有在“要在 Windows 本机 flutter run 预览也看到 SF”，或“要跨平台完全一致”时，
/// 才需要自备字体文件并把 useBundledSF 打开（见 README 第六节）。
class AppFonts {
  /// 使用 iOS 系统内置 SF（推荐，零体积、零授权风险）
  static const bool useSystemSF = true;

  /// 使用打包进 assets/fonts 的 SF 字体（需自行准备字体文件）
  static const bool useBundledSF = false;

  /// 正文字体：iOS 上为 SF Text（小字号专用）
  static const String? family = useBundledSF
      ? 'SFProText'
      : (useSystemSF ? '.SF UI Text' : null);

  /// 大号数字字体：iOS 上为 SF Display（20pt 以上专用）
  static const String? displayFamily = useBundledSF
      ? 'SFProDisplay'
      : (useSystemSF ? '.SF UI Display' : null);

  /// 中文回退：SF 不含中文字形，交回系统苹方
  static const List<String> fallback = <String>[
    'PingFang SC',
    'Heiti SC',
    'STHeiti',
  ];
}
