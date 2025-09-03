# Egret Inspector - Chrome 扩展安装指南

## 版本信息
- **版本**: 2.5.6
- **支持**: Manifest V3 (最新版 Chrome)
- **更新内容**: 升级到 Manifest V3，兼容最新版 Chrome 浏览器

## 安装步骤

### 1. 开启开发者模式
1. 打开 Chrome 浏览器
2. 访问 `chrome://extensions/`
3. 在右上角开启"开发者模式"

### 2. 加载扩展
1. 点击"加载已解压的扩展程序"
2. 选择此项目文件夹
3. 确认加载

### 3. 验证安装
1. 按 F12 打开开发者工具
2. 在开发者工具的标签页中应该能看到 "Egret" 选项卡
3. 如果看到了，说明安装成功

## 使用说明

### 基本功能
- **显示对象树**: 查看 Egret 游戏中的显示对象层级结构
- **属性面板**: 查看和编辑选中对象的属性
- **性能监控**: 实时监控游戏 FPS
- **高亮显示**: 鼠标悬停或点击时高亮游戏中的对象

### 控制选项
- **阻止点击**: 防止在调试时误点击游戏对象
- **高亮划过对象**: 鼠标悬停时高亮显示对象
- **选中点击对象**: 点击时选中并高亮对象

## 主要更新内容

### Manifest V3 升级
- 将 `manifest_version` 从 2 升级到 3
- 将 background scripts 转换为 service worker
- 更新权限声明格式
- 使用新的 `chrome.scripting` API 替代废弃的 `chrome.tabs.executeScript`
- 调整 `web_accessible_resources` 格式

### 权限优化
- 移除了不必要的 `system.cpu` 和 `nativeMessaging` 权限
- 将宽泛的 `*://*/*` 权限分离为 `host_permissions`
- 添加了 `scripting` 权限以支持脚本注入

### 兼容性改进
- 保持所有原有功能不变
- 确保与最新版 Chrome 完全兼容
- 修复了扩展被禁用的问题

## 故障排除

### 扩展无法加载
1. 确认已开启开发者模式
2. 检查是否有错误提示
3. 确认 manifest.json 文件完整

### DevTools 中没有 Egret 标签
1. 确认扩展已正确加载
2. 刷新页面重试
3. 重新开启开发者工具

### 功能无法正常工作
1. 确认页面中有 Egret 游戏
2. 查看控制台是否有错误
3. 尝试刷新页面

## 技术说明

### 主要文件说明
- `manifest.json`: 扩展配置文件 (已升级到 V3)
- `background.js`: Service Worker 背景脚本 (新)
- `devtools.html` & `devtoolinit.js`: DevTools 页面
- `contentScripts.min.js`: 内容脚本
- `injectScripts.min.js`: 注入脚本
- `ipt/panel/`: DevTools 面板页面

### 架构说明
扩展采用多层架构：
1. **Service Worker**: 处理扩展间通信
2. **DevTools Page**: 注册 DevTools 面板
3. **Content Script**: 与页面通信
4. **Inject Script**: 在页面上下文中运行，访问 Egret 对象
5. **Panel**: 提供用户界面

## 开发者信息

此扩展是对原始 Egret Inspector 的 Manifest V3 升级版本，保持了所有原有功能的同时，确保了与最新版 Chrome 的兼容性。

## 支持的 Egret 版本
- Egret 5.0+
- 支持所有基于 Egret 引擎的游戏和应用
