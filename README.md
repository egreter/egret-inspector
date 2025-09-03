## Egret 白鹭开发Chrome插件（Manifest V3 升级版）

### 🚀 最新更新：2025年 - Manifest V3 兼容版本
- **版本**: 2.5.6.1
- **支持**: 最新版 Chrome（Manifest V3）
- **状态**: ✅ 已修复新版 Chrome 中扩展被禁用的问题

### ⚡ 主要改进
- 🔧 升级到 Manifest V3，完全兼容最新版 Chrome
- 🛡️ 修复了新版 Chrome 中扩展被禁用/无法使用的问题
- 🚫 **修复了 CSP 违规问题**: 解决了 "Refused to execute inline script" 错误
- 🔄 **更新了废弃 API**: 使用 `chrome.runtime.getURL` 替代 `chrome.extension.getURL`
- 📦 **修复了脚本加载失败**: 解决了 404 错误和资源加载问题
- 🎯 保持所有原有功能不变
- 📦 优化了权限配置，提高安全性
- 🔄 使用 Service Worker 替代传统 background scripts

### 📋 快速安装指南

#### 1. 克隆项目
```shell
git clone https://github.com/rontian/egret-inspector.git
```

#### 2. 安装扩展
1. 打开 Chrome 浏览器
2. 访问 `chrome://extensions/`
3. 开启右上角的"开发者模式"
4. 点击"加载已解压的扩展程序"
5. 选择项目文件夹

#### 3. 使用扩展
1. 打开包含 Egret 游戏的页面
2. 按 F12 打开开发者工具
3. 在开发者工具中找到 "Egret" 标签页
4. 开始调试你的 Egret 应用！

### 🎮 功能特性

- **📊 显示对象树**: 查看 Egret 游戏中的显示对象层级结构
- **🔧 属性面板**: 实时查看和编辑选中对象的属性
- **📈 性能监控**: 实时 FPS 监控和性能分析
- **🎯 智能高亮**: 鼠标悬停或点击时高亮游戏中的对象
- **🚫 点击保护**: 调试时防止误触游戏对象
- **🔍 搜索功能**: 快速查找特定的显示对象

### 🛠️ 技术升级详情

#### Manifest V3 兼容性改进
- 将 `manifest_version` 从 2 升级到 3
- 背景脚本改为 Service Worker 架构
- 更新权限声明格式 (`host_permissions`)
- 使用新的 `chrome.scripting` API
- 优化 `web_accessible_resources` 配置

#### 权限优化
- 移除不必要的权限（`system.cpu`, `nativeMessaging`）
- 采用更精确的权限控制
- 提高扩展安全性

### 🐛 常见问题解决

#### Q: 扩展无法加载？
A: 确保已开启"开发者模式"，检查控制台是否有错误信息

#### Q: DevTools 中没有 Egret 标签？
A: 确认扩展正确加载后，刷新页面并重新打开开发者工具

#### Q: 出现 CSP 错误？
A: 本版本已修复 CSP 问题。如仍有问题，请检查是否使用了最新的修复版本

#### Q: 脚本加载失败 (404 错误)？
A: 本版本已修复脚本路径问题。确保使用 `chrome.runtime.getURL` 而不是废弃的 API

#### Q: 功能无法正常工作？
A: 确认页面包含 Egret 游戏，查看控制台错误信息，参考 `FIX_NOTES.md` 进行调试

### 📊 支持的 Egret 版本
- ✅ Egret 5.0+
- ✅ 支持所有基于 Egret 引擎的游戏和应用
- ✅ 兼容最新版 Chrome 浏览器

### 🔧 开发者说明

此版本是对原始 Egret Inspector 的 Manifest V3 升级，主要解决了新版 Chrome 中扩展被禁用的问题。所有核心功能保持不变，确保开发者可以继续正常使用此调试工具。

#### 主要架构
```
Service Worker (background.js)
    ↕️
DevTools Page (devtoolinit.js)
    ↕️
Content Script (contentScripts.min.js)
    ↕️
Inject Script (injectScripts.min.js)
    ↕️
Egret Game Context
```

### 📝 更新历史

**v2.5.6 (2025)** - Manifest V3 升级版
- 完整升级到 Manifest V3
- 修复新版 Chrome 兼容性问题
- 优化权限配置

**v2.5.5 (2021)** - 原始修复版
- 修复 `this.addChild is not a function` 错误
- 支持 Chrome 87+

### 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

### 📄 许可证

基于原始 EgretInspector 项目，保持相同的开源许可证。