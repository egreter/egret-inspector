# Egret Inspector - 项目升级完成

## 📋 升级总结

✅ **成功将 Egret Inspector 从 Manifest V2 升级到 Manifest V3**

### 🔄 主要更改

1. **manifest.json**
   - `manifest_version`: 2 → 3
   - `background.scripts` → `background.service_worker`
   - `permissions` 重构为 `permissions` + `host_permissions`
   - `web_accessible_resources` 格式更新
   - 添加 `scripting` 权限
   - 版本号更新为 2.5.6

2. **background.js**（新增）
   - 完全重写为 Service Worker 兼容格式
   - 使用 `chrome.scripting.executeScript` 替代废弃的 `chrome.tabs.executeScript`
   - 保持所有原有通信功能

3. **版本信息更新**
   - 更新面板中的版本展示
   - 更新版本检查逻辑

4. **文档更新**
   - 完全重写 README.md
   - 新增 INSTALL_GUIDE.md
   - 添加升级验证脚本

### 🗂️ 文件结构

```
egret-inspector/
├── manifest.json          # ✅ 升级到 V3
├── background.js           # 🆕 Service Worker
├── devtools.html          # ✅ 保持不变
├── devtoolinit.js         # ✅ 保持不变
├── contentScripts.min.js  # ✅ 保持不变
├── injectScripts.min.js   # ✅ 保持不变
├── icon.png              # ✅ 保持不变
├── ipt/
│   ├── panel/
│   │   ├── index.html     # ✅ 更新版本信息
│   │   ├── scripts/
│   │   │   └── Loader.js  # ✅ 更新版本检查
│   │   └── style/
│   │       └── devtool.css # ✅ 保持不变
│   └── lib/
│       └── jquery-2.1.1.min.js # ✅ 保持不变
├── docs/                  # ✅ 保持不变
├── README.md             # 🔄 完全重写
├── INSTALL_GUIDE.md      # 🆕 安装指南
└── verify_upgrade.sh     # 🆕 验证脚本
```

### 🎯 保持的功能

✅ 所有原有核心功能完整保留：
- DevTools 面板集成
- 显示对象树查看
- 属性实时编辑
- 性能监控（FPS）
- 高亮显示功能
- 搜索功能
- 上下文菜单
- 所有调试工具

### 🛡️ 安全性改进

- 移除不必要的权限（`system.cpu`, `nativeMessaging`）
- 使用更精确的 `host_permissions`
- 采用 Service Worker 架构提高稳定性

### 🔧 兼容性

- ✅ 支持最新版 Chrome
- ✅ 兼容 Manifest V3 要求
- ✅ 向后兼容所有 Egret 5.0+ 项目

### 📦 安装方式

1. 开启 Chrome 开发者模式
2. 加载已解压的扩展程序
3. 选择项目文件夹
4. 在 DevTools 中使用 Egret 标签页

### ⚡ 立即可用

项目已完成升级，可以立即在最新版 Chrome 中使用！

---

**升级完成时间**: 2025年
**目标版本**: Manifest V3  
**状态**: ✅ 完成并验证通过
