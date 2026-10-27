# 安装器修复版发布指南

preview.2 沿用现有的手工 ZIP + SHA-256 + GitHub 预发布方式，不增加自动发布工作流。`tools/package_release.py` 只负责把已发布的差分文件、解码工具与当前仓库的脚本和文档组成新包，不生成或读取游戏 DAT。玩家安装补丁仍不需要 Python。

## 打包

维护者需要 Python 3.11 或更新版本。

1. 从 preview.1 发布页下载完整 Release ZIP。不要使用 `Source code`。
2. 确认当前检出待发布的 preview.2 源码，运行：

```console
python tools/package_release.py --base-zip /path/to/Lone-Fungus-Simplified-Chinese-Patch-v0.1.0-preview.1.zip --output-dir dist
```

Windows 下可将路径改为带引号的本机绝对路径。

脚本先验证旧 ZIP 的 SHA-256 为 `A6B120FA9B9F3F44EFB1FC4EAD7E2C0B60096DACA4D8C08D5645E7ACE8122B46`，再从中只读取既有 `.zstpatch` 和 `zstd.exe`。两项内容均需通过固定哈希检查，其余文件只从脚本中列出的仓库文件清单读取。PS1/CMD 统一为 CRLF；ZIP 条目顺序、时间和权限固定，同一 Python/zlib 环境中重复打包应得到相同字节。

输出为 `Lone-Fungus-Simplified-Chinese-Patch-v0.1.0-preview.2.zip` 和同名 `.zip.sha256`，ZIP 内另含重新计算的 `CHECKSUMS.sha256`。为防止覆盖已有候选包，输出文件已存在时脚本会退出；复核时可指定另一个输出目录。

## 发布前复核

- 检查 ZIP 的完整文件清单及包内、包外校验值。不得加入 DAT、DAT 备份、临时重建文件、游戏 EXE、Modules、存档或完整游戏资源。
- 确认包内 `install.ps1`、`uninstall.ps1` 与 PR #2 合并后的脚本一致，manifest 版本为 preview.2。
- 差分文件沿用原名 `LoneFungus.zh-CN.v0.1.0-preview.1.zstpatch`，SHA-256 和目标 DAT 不变。不要仅为版本号改名后漏改安装器。
- 如具备 Windows PowerShell 5.1，运行 `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests/Test-DefaultGameDirectory.ps1`。测试不需要游戏资源。
- 如具备正版且哈希匹配的英文 DAT，在独立副本上完成安装、重复安装、卸载、重复卸载并核对 DAT 哈希。游戏显示测试需在完整 Steam 环境中单独执行。
- 区分本轮实际执行的检查与 PR #2 已有记录；不能将历史通过记录写成重新实测通过。

## GitHub 发布

1. 确认待发布提交和下载说明，创建 `v0.1.0-preview.2` 标签，指向该提交；不要移动 preview.1 标签或替换其资产。
2. 新建 **Pre-release**，标题为“Lone Fungus 简体中文汉化补丁 v0.1.0-preview.2”。正文使用仓库根目录的 `RELEASE_NOTES_v0.1.0-preview.2.md`。
3. 上传新 ZIP 与 `.zip.sha256`；核对上传后的文件大小和 SHA-256 后发布。
4. 从公开下载地址重新下载 ZIP 与校验文件，确认与本地候选包相同，且 ZIP 文件完整可读。
5. 确认 README 指向新版本，Issue #1 继续开放。本次仅修复安装器，不应使用关闭该 issue 的提交或 PR 关键字，也不能宣称方框字已修复。

预发布版本可能不会成为 GitHub `/releases/latest` 的目标，因此下载说明使用明确的 preview.2 标签链接。
