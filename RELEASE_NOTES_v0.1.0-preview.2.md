# Lone Fungus 简体中文汉化补丁 v0.1.0-preview.2

这是 preview.1 的安装器修复版，适配 Steam 版 `Lone Fungus 1.1.14`（AppID `1674780`），继续作为预发布版本提供。

## 本次修复

- 纳入已合并的 PR #2，修复 Windows PowerShell 5.1 下双击 `install.cmd` 或 `uninstall.cmd` 时因默认目录为空而出现“路径的形式不合法”的问题。
- 更新下载、升级和 SHA-256 校验说明，重新生成包内校验清单。
- 差分补丁、Zstandard 工具和中文目标 DAT 与 preview.1 相同，译文、字体和游戏资源未修改。

**中文方框字仍未解决，继续在 Issue #1 跟踪。本版不包含字体显示修复。**

部分设置页、背包页签及底部提示仍为韩文。

## 下载与安装

1. 在本页 Assets 中下载 `Lone-Fungus-Simplified-Chinese-Patch-v0.1.0-preview.2.zip` 及同名 `.zip.sha256`。不要下载 `Source code`，它不含差分文件和解码工具。
2. 用 PowerShell 的 `Get-FileHash` 计算 ZIP 的 SHA-256，与 `.zip.sha256` 中的值核对。
3. 退出游戏，将 ZIP 内全部文件解压到与 `Lone Fungus.exe`、`Lone Fungus.dat` 相同的目录。
4. 双击 `install.cmd`，等待 `[OK] Installation completed successfully.` 后从 Steam 启动游戏。若已安装相同中文 DAT，会提示 `[OK] This patch is already installed.`。

已有 preview.1 时，可直接用新版 ZIP 覆盖同名补丁文件，无需先卸载。保留现有 DAT 和 `Lone Fungus.dat.lf-zh-cn.original.bak`。包内 `.zstpatch` 文件名保留 preview.1，是因为差分内容未变。

卸载时退出游戏后运行 `uninstall.cmd`，或通过 Steam 验证游戏文件完整性。玩家无需安装 Python、.NET 或解包工具。

ZIP SHA-256：`26FAA69485E8B0679E21F1B15FCC8C17AFDD30E376CD0198F839869A3FDA8E6C`。

## 验证与边界

- PR #2 已记录 Windows PowerShell 5.1 默认/显式目录 4 项通过，以及安装、重复安装、卸载、重复卸载 4 项通过；安装和还原 DAT 的哈希符合预期。
- 本轮复核脚本与该修复提交一致，17 项 ZIP 条目、16 项包内校验值、CRC 和外部 ZIP 校验均通过；两次独立打包逐字节一致，错误基包拒绝和防覆盖检查通过。本轮未重新执行 Windows 实机回归或 Steam 显示测试。
- 本次发布不包含完整游戏 DAT、DAT 备份、游戏 EXE、Modules 或存档，只提供差分、开源解码工具、脚本和文档。
- 英文原版 DAT SHA-256：`3D393F2160A5868B51AB07F5EEE246EBF297151F9C841C3AF3F300B2B0818FDB`。
- 中文目标 DAT SHA-256：`7FB74B7E333B4B274038678D68BA23138A89CB7CC56D5938DAB698470EFB48EA`。

详细验证记录见 `docs/RELEASE_VALIDATION_v0.1.0-preview.2.md`。本补丁为非官方、非商业玩家汉化，适配范围和第三方授权见 README 及 `THIRD_PARTY_NOTICES.md`。
