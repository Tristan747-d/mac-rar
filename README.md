# mac-rar

一个让 macOS 访达原生支持右键解压 RAR 的轻量方案。无需常驻后台、无需付费软件。

![界面示意](https://img.shields.io/badge/macOS-14%2B-black) ![引擎](https://img.shields.io/badge/engine-unrar%207.11-blue)

## 解决什么问题

macOS 自带归档实用工具**不支持 RAR**，右键没有任何解压选项。本方案通过访达快速操作（Quick Action）补上这个坑。

## 特性

- **右键即解**：访达中右键 RAR 文件 → 快速操作 → 解压 RAR
- **RAR5 支持**：UnRAR 7.11 官方引擎，最新 RAR5 压缩算法无损解压（实测微信传输的 38MB 相机原片包）
- **双引擎兜底**：unrar 失败时自动降级到 7z，覆盖老式 RAR 及其他压缩格式
- **防呆设计**：遇到改名的假压缩包（如图片改 .rar）会弹窗提示并清理空目录，不再默默产出 0 字节文件
- **中文友好**：正确处理中文文件名与子目录
- **解压位置**：压缩包同目录下的「文件名 — 解压」文件夹，完成后有提示音

## 安装

```bash
git clone https://github.com/Tristan747-d/mac-rar.git
cd mac-rar
./scripts/install.sh
```

安装脚本会自动：
1. 下载并编译 UnRAR 7.11 到 `~/bin/unrar`（可选装 `p7zip` 作为兜底）
2. 将 `解压 RAR.workflow` 安装到 `~/Library/Services/`
3. 注册一个微型 UTI 声明 app，把 `.rar` 扩展名绑回 `com.rarlab.rar-archive`
4. 刷新 LaunchServices / pbs 缓存并重启访达

## 原理

| 组件 | 作用 |
|---|---|
| `解压 RAR.workflow` | Automator 快速操作，内嵌 Run Shell Script 调用 unrar |
| `RARFixer.app` | 极简 app，仅用于声明 `.rar` 的 UTI 映射 |

**关键坑位记录**（macOS 26 实测）：

1. **`.rar` 没有 UTI 认领**：系统不会把 `.rar` 归入 `public.archive`，`mdls` 只给动态 UTI `dyn.ah62d4rv4ge81e2pw`。声明 `NSSendFileTypes = public.archive` 的服务永远匹配不上 RAR 文件。必须有一个 app 通过 `UTImportedTypeDeclarations` 认领 `.rar`（macOS 上 rarlab 官方工具不提供此声明）。
2. **p7zip 17.05 解不了新 RAR5**：对 RAR5 新压缩算法报 `Unsupported Method`，静默输出 0 字节文件。必须用 rarlab 官方 unrar（≥ 7.x）。
3. **document.wflow 的位置**：必须在 `Contents/Resources/` 下且包含完整 Automator action 元数据，`pbs -flush` 后才能被识别。

## 文件结构

```
mac-rar/
├── 解压 RAR.workflow/        # 访达快速操作
│   └── Contents/
│       ├── Info.plist
│       └── Resources/document.wflow
├── RARFixer.app/             # UTI 声明用微型 app
│   └── Contents/
│       ├── Info.plist
│       └── MacOS/RARFixer
└── scripts/
    └── install.sh
```

## 卸载

```bash
rm -rf ~/Library/Services/解压\ RAR.workflow
rm -rf ~/Library/Application\ Support/RARFix
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f ~/Library/Application\ Support/RARFix/RARFixer.app 2>/dev/null
/System/Library/CoreServices/pbs -flush
```

## 许可

MIT（workflow / 脚本部分）。UnRAR 源码遵循其 [自有许可](https://www.rarlab.com/license.htm)（免费使用，不可用于重建 RAR 压缩算法）。
