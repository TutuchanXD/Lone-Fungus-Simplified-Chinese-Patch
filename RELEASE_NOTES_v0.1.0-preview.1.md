# Lone Fungus 简体中文汉化补丁 v0.1.0-preview.1

适配 Steam 版 `Lone Fungus 1.1.14`，AppID `1674780`。

这是首个公开预览版，已完成主要正文、简体中文字体、主菜单和暂停菜单汉化。部分设置页、背包页签及底部提示仍为韩文，后续版本会继续处理这些烘焙图片。

## 安装

1. 下载 `Lone-Fungus-Simplified-Chinese-Patch-v0.1.0-preview.1.zip`。
2. 将压缩包内全部文件解压到与 `Lone Fungus.exe` 同一目录。
3. 退出游戏后双击 `install.cmd`。
4. 从 Steam 正常启动游戏。

安装器只接受 SHA-256 为 `3D393F2160A5868B51AB07F5EEE246EBF297151F9C841C3AF3F300B2B0818FDB` 的英文原版 DAT，并会自动备份、重建和校验中文 DAT。无需安装 .NET、Python 或解包工具。

## 重要说明

- Release 不包含完整游戏 DAT，只提供约 94 MiB 的差分补丁。
- Release ZIP SHA-256：`A6B120FA9B9F3F44EFB1FC4EAD7E2C0B60096DACA4D8C08D5645E7ACE8122B46`。
- 中文目标 DAT SHA-256：`7FB74B7E333B4B274038678D68BA23138A89CB7CC56D5938DAB698470EFB48EA`。
- 补丁未修改 EXE、Steamworks、Steam API、AppID 或成就标识；Steam 覆盖层已通过实机验证。
- 卸载时双击 `uninstall.cmd`，也可以通过 Steam 验证游戏文件完整性。
- 这是非官方、非商业玩家汉化，使用前请阅读仓库 README 中的适配范围和版权说明。
