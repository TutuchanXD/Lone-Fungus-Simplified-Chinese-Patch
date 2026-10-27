# preview.2 发布验证记录

核对日期：2026-10-28。安装器修复基线：PR #2 合并提交 `8543ee3f572bfda9cd2f652748b9ab730f8de2d2`。

## 已有回归依据

[PR #2](https://github.com/TutuchanXD/Lone-Fungus-Simplified-Chinese-Patch/pull/2) 记录：

- Windows PowerShell 5.1 下，安装和卸载脚本的默认目录、显式目录共 4 项通过。脚本路径含空格，从不同工作目录启动。
- 使用发布包和英文原版 DAT 的独立副本运行安装、重复安装、卸载、重复卸载，4 项均通过。
- 安装后 DAT SHA-256 为 `7FB74B7E333B4B274038678D68BA23138A89CB7CC56D5938DAB698470EFB48EA`；卸载后为 `3D393F2160A5868B51AB07F5EEE246EBF297151F9C841C3AF3F300B2B0818FDB`。

上述为 PR 中的已有验证记录，不是本轮重新执行的测试。该 PR 的自动审查摘要停留在 running，不能据此声称自动代码审查已完成或通过。仓库未发现 GitHub Actions 运行记录。

## 本轮包检查

- 从原 Release 下载 preview.1 ZIP，计算所得 SHA-256 与 GitHub 资产摘要和发布说明一致：`A6B120FA9B9F3F44EFB1FC4EAD7E2C0B60096DACA4D8C08D5645E7ACE8122B46`。
- 旧包内 `CHECKSUMS.sha256` 列出的 14 个文件逐一通过校验；四个安装、卸载入口与 preview.1 标签一致（忽略换行形式）。
- preview.2 包内两个 PS1 脚本与合并提交的脚本一致（按仓库属性使用 CRLF）；两个 CMD 入口未修改。
- 差分补丁与解码工具逐字节复用，哈希分别为 `FE7E5EAAFE02A64B7F3148CB0C83ECD4462C59CB3503769CDB09E9342761CAFF` 和 `8076AAE03FEAC7C66B319579E82172EED168DEED2A3F25E5E2D3C60F55E84111`。
- 新包按固定清单制作，重算包内 `CHECKSUMS.sha256` 和外部 ZIP 校验文件。完整 DAT、备份、临时文件、游戏 EXE、Modules 和存档均不在发布清单内。

## 本轮验证边界

本轮打包环境为 Linux，未提供 Windows PowerShell 5.1 或英文原版 DAT，因此未重跑 Windows 默认路径测试、四步完整安装回归或 Steam 游戏显示测试。发布依据是已合并修复的历史回归记录，以及本轮对脚本、工具和差分内容的逐项一致性检查。

差分补丁和中文目标 DAT 未变化。玩家报告的中文方框字尚未解决，根因尚未确认，继续由 [Issue #1](https://github.com/TutuchanXD/Lone-Fungus-Simplified-Chinese-Patch/issues/1) 跟踪。安装器修复不能作为字体显示问题通过验收的依据。
