# Lone Fungus 简体中文汉化补丁

这是面向 Steam 版 **Lone Fungus 1.1.14** 的非官方简体中文汉化补丁。目前为预览版本，已完成主要正文、字体、主菜单和暂停菜单汉化，但部分以图片形式保存的设置页、背包标签和底部操作提示仍为韩文。

> 本仓库不提供完整游戏 DAT。Release 只包含差分补丁、安装脚本和开源解码工具，必须配合合法取得且哈希匹配的 Steam 原版文件使用。

## 当前状态

版本：`v0.1.0-preview.2`（安装器修复版）

本版修复 Windows PowerShell 5.1 下双击 `install.cmd`、`uninstall.cmd` 时的默认路径错误，沿用 preview.1 的差分补丁和目标 DAT。玩家反馈的中文方框字仍未解决，继续在 [Issue #1](https://github.com/TutuchanXD/Lone-Fungus-Simplified-Chinese-Patch/issues/1) 跟踪。

适配环境：

- Steam AppID：`1674780`
- 游戏版本：`1.1.14`
- Clickteam Fusion build：`295`
- 支持的英文原版 `Lone Fungus.dat` SHA-256：`3D393F2160A5868B51AB07F5EEE246EBF297151F9C841C3AF3F300B2B0818FDB`
- 安装后的中文 `Lone Fungus.dat` SHA-256：`7FB74B7E333B4B274038678D68BA23138A89CB7CC56D5938DAB698470EFB48EA`

已完成：

- 1,093 条事件文本映射，写入 372,140 个结构化字符串槽位。
- 205 个对象段落和 2 个对象可变字符串。
- 4 个内嵌字体条目和 6 个运行时字体句柄，覆盖译文使用的 1,437 个不同字符。
- 主菜单“开始游戏 / 设置 / 退出”的普通和选中状态。
- 暂停菜单“继续游戏 / 设置 / 保存并退出”和地图更新模式相关图片。

尚未完成：

- 部分玩家遇到的中文方框字问题仍在调查，本版不包含字体或游戏资源修复。
- 部分设置页、背包页签、返回/助手模式等烘焙图片仍为韩文。
- 当前译文属于第一轮完整文本回填，仍需长期游戏测试来发现语境、换行、裁切和术语问题。

## 安装

1. 在 Steam 中右键游戏，选择“管理” -> “浏览本地文件”。
2. 退出游戏，并确保任务管理器中没有 `Lone Fungus.exe`。
3. 从 [v0.1.0-preview.2 发布页](https://github.com/TutuchanXD/Lone-Fungus-Simplified-Chinese-Patch/releases/tag/v0.1.0-preview.2) 下载 `Lone-Fungus-Simplified-Chinese-Patch-v0.1.0-preview.2.zip`，不要下载 GitHub 自动生成的 `Source code` 压缩包；源码包不含差分补丁和 `zstd.exe`。
4. 将 ZIP 内的全部文件解压到游戏目录，也就是与 `Lone Fungus.exe`、`Lone Fungus.dat` 同一目录。
5. 双击 `install.cmd`，等待窗口显示 `[OK] Installation completed successfully.`。
6. 从 Steam 正常启动游戏。

**已有 preview.1：**退出游戏后，将新版 ZIP 全部解压并覆盖同名补丁文件，再运行 `install.cmd`。保留现有的 `Lone Fungus.dat` 和 `Lone Fungus.dat.lf-zh-cn.original.bak`，无需先卸载。若 DAT 已是相同的中文目标，安装器会提示已安装；更新后的卸载入口仍可使用。包内差分文件名保留 `preview.1` 是因为其内容未变。

发布页同时提供同名 `.zip.sha256` 文件。下载后可在 PowerShell 中运行：

```powershell
Get-FileHash '.\Lone-Fungus-Simplified-Chinese-Patch-v0.1.0-preview.2.zip' -Algorithm SHA256
```

将输出与 `.zip.sha256` 中的值比较，确认一致后再解压。

安装器会执行以下保护措施：

- 在执行前校验差分补丁和 Zstandard 工具自身的 SHA-256。
- 校验原始 DAT 的 SHA-256；游戏版本不匹配时拒绝继续。
- 将英文原版备份为 `Lone Fungus.dat.lf-zh-cn.original.bak`。
- 在临时文件中重建中文 DAT，校验目标 SHA-256 后才覆盖游戏文件。
- 如果已经安装本版本，直接退出且不重复写入。

安装时建议至少保留 1.5 GB 可用磁盘空间和约 1 GB 可用内存。安装脚本仅支持 Windows PowerShell，不需要额外安装 .NET、Python 或解包软件。

如果脚本提示当前 DAT 不受支持，请先在 Steam 中“验证游戏文件的完整性”，恢复英文原版后重试。验证完整性也会移除已安装的汉化。

## 卸载

退出游戏后双击 `uninstall.cmd`。脚本只会在当前 DAT 等于本补丁目标哈希、且原版备份哈希正确时执行恢复。

也可以直接在 Steam 中验证游戏文件完整性。脚本恢复后会保留原版备份，方便重新安装；确认不再需要后可手动删除该 `.bak` 文件。

## Steam 成就

本补丁只替换 `Lone Fungus.dat`，不修改以下成就链路组件：

- `Lone Fungus.exe`
- `Modules/Steamworks.mfx`
- `Modules/steam_api.dll`
- Steam AppID 和游戏内成就标识

实机启动验证中，Steamworks、Steam API、Steam 客户端和覆盖层模块均正常加载，游戏内也显示了 Steam 覆盖层提示。因此本补丁不会关闭或绕过 Steam 成就，成就应按原游戏逻辑正常解锁和弹窗。

没有使用强制解锁接口测试弹窗，因为该操作会永久改变测试账号。最终端到端确认应通过游玩自然获得一个尚未解锁的成就；已经获得的成就不会重复弹窗，Steam 客户端关闭通知时也不会显示提示。

## 汉化是怎样完成的

游戏由 Clickteam Fusion 构建，文本和大量界面资源都封装在单个 DAT 中。此次流程不是简单替换可见字符串，而是：

1. 使用 NebulaFD/CTFAK 体系解析英文原版和韩文补丁，按帧、对象与事件结构建立可定位的文本映射。
2. 交叉参考英文和韩文语境，以 `gpt-5.6-luna`、`max` 推理强度完成第一轮简体中文翻译，再进行长度、控制符、数字、占位符和韩文残留检查。
3. 将字体替换为采用 SIL OFL 1.1 授权的 Fusion Pixel Font 简体中文字体，以覆盖全部译文字符。
4. 使用 Clickteam 可接受的原生 zlib 字节流回写事件与对象数据，重建对象属性偏移表，并重算保护校验。
5. 对烘焙在图片里的菜单文字，按图片句柄替换 PNG，重建 `ImageBank` 与 `ImageOffsets`。
6. 用独立解析器全量读取 454 个帧、7,232 个对象属性和 17,143 张图片，再在真实 Steam 目录中测试启动、菜单、Steamworks 和覆盖层。

更完整的二进制结构、故障原因和验证记录见 [技术说明](docs/TECHNICAL_NOTES.md)。

## 校验值

Release ZIP 内附 `CHECKSUMS.sha256`，列出包内各文件的校验值；外部 `.zip.sha256` 校验整个 ZIP。核心文件如下（preview.2 沿用 preview.1 的游戏资源）：

| 文件 | SHA-256 |
| --- | --- |
| 英文原版 DAT | `3D393F2160A5868B51AB07F5EEE246EBF297151F9C841C3AF3F300B2B0818FDB` |
| 中文目标 DAT | `7FB74B7E333B4B274038678D68BA23138A89CB7CC56D5938DAB698470EFB48EA` |
| 差分补丁 | `FE7E5EAAFE02A64B7F3148CB0C83ECD4462C59CB3503769CDB09E9342761CAFF` |
| Zstandard 1.5.7 (`zstd.exe`) | `8076AAE03FEAC7C66B319579E82172EED168DEED2A3F25E5E2D3C60F55E84111` |

## 反馈

提交 Issue 时请附上：

- 出现问题的页面或区域。
- 完整截图。
- 预期译文或上下文说明。
- `Get-FileHash '.\Lone Fungus.dat' -Algorithm SHA256` 的输出。

不要上传游戏 DAT、存档或其他完整游戏资源。

## 维护与发布

打包步骤及发布前检查见 [发布指南](docs/RELEASING.md)。安装器回归依据和本版验证边界见 [preview.2 验证记录](docs/RELEASE_VALIDATION_v0.1.0-preview.2.md)。

## 致谢

- Basti Games：Lone Fungus 原作。
- 韩文补丁团队：韩文 DAT 为本项目提供了本地化结构与语境参考。
- TakWolf：Fusion Pixel Font。
- NebulaFD 与 CTFAK 社区：Clickteam Fusion 数据研究与解析工具。

## 版权与授权

Lone Fungus 及其美术、音频、程序和商标归原作者及相应权利人所有。本项目是非官方、非商业的玩家汉化，与 Basti Games、Steam 或 Clickteam 无隶属关系。

仓库中的安装脚本采用 [MIT License](LICENSE-SCRIPTS)。该许可不覆盖游戏资产、差分补丁、译文、字体或其他第三方内容。第三方组件及字体授权见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
