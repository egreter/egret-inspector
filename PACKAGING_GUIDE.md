# Egret Inspector - 扩展打包指南

## 📦 必需文件清单

### 核心扩展文件 ✅
```
egret-inspector-v2.5.6/
├── manifest.json              # 扩展配置文件 (必需)
├── background.js             # Service Worker (必需)
├── contentScripts.min.js     # 内容脚本 (必需)
├── devtools.html            # DevTools 页面 (必需)
├── devtoolinit.js          # DevTools 初始化脚本 (必需)
├── injectScripts.min.js    # 注入脚本 (必需)
└── icon.png                # 扩展图标 (必需)
```

### 面板文件 ✅
```
ipt/
├── lib/
│   └── jquery-2.1.1.min.js    # jQuery 库 (必需)
└── panel/
    ├── index.html              # 面板主页面 (必需)
    ├── scripts/
    │   └── Loader.js          # 面板脚本 (必需)
    └── style/
        ├── devtool.css        # 面板样式 (必需)
        └── refresh.png        # 刷新按钮图标 (必需)
```

## 🗑️ 不需要的文件

### 开发和文档文件 ❌
```
❌ .DS_Store                    # macOS 系统文件
❌ .git/                       # Git 版本控制
❌ .gitignore                  # Git 忽略文件
❌ README.md                   # 项目说明文档
❌ INSTALL_GUIDE.md            # 安装指南
❌ FIX_NOTES.md               # 修复说明
❌ UPGRADE_SUMMARY.md         # 升级总结
❌ FINAL_CHECKLIST.md         # 检查清单
❌ docs/                      # 文档图片文件夹
❌ test.html                  # 测试页面
❌ verify_upgrade.sh          # 验证脚本
```

### 备份和临时文件 ❌
```
❌ contentScripts-fixed.js      # 开发时创建的修复版本
❌ contentScripts.min.js.backup # 备份文件
```

## 🔧 自动打包脚本

让我为你创建一个自动打包脚本:

### build_extension.sh
```bash
#!/bin/bash

# 创建打包目录
PACKAGE_NAME="egret-inspector-v2.5.6"
PACKAGE_DIR="../${PACKAGE_NAME}"

echo "🔧 开始打包 Egret Inspector 扩展..."

# 清理旧的打包目录
if [ -d "$PACKAGE_DIR" ]; then
    rm -rf "$PACKAGE_DIR"
fi

# 创建新的打包目录
mkdir -p "$PACKAGE_DIR"

# 复制必需的核心文件
echo "📁 复制核心文件..."
cp manifest.json "$PACKAGE_DIR/"
cp background.js "$PACKAGE_DIR/"
cp contentScripts.min.js "$PACKAGE_DIR/"
cp devtools.html "$PACKAGE_DIR/"
cp devtoolinit.js "$PACKAGE_DIR/"
cp injectScripts.min.js "$PACKAGE_DIR/"
cp icon.png "$PACKAGE_DIR/"

# 复制面板文件
echo "🎛️  复制面板文件..."
mkdir -p "$PACKAGE_DIR/ipt/lib"
mkdir -p "$PACKAGE_DIR/ipt/panel/scripts"
mkdir -p "$PACKAGE_DIR/ipt/panel/style"

cp ipt/lib/jquery-2.1.1.min.js "$PACKAGE_DIR/ipt/lib/"
cp ipt/panel/index.html "$PACKAGE_DIR/ipt/panel/"
cp ipt/panel/scripts/Loader.js "$PACKAGE_DIR/ipt/panel/scripts/"
cp ipt/panel/style/devtool.css "$PACKAGE_DIR/ipt/panel/style/"
cp ipt/panel/style/refresh.png "$PACKAGE_DIR/ipt/panel/style/"

# 创建版本信息文件
echo "📋 创建版本信息..."
cat > "$PACKAGE_DIR/VERSION.txt" << EOF
Egret Inspector - Chrome Extension
Version: 2.5.6
Manifest: V3
Build Date: $(date '+%Y-%m-%d %H:%M:%S')
Compatible: Chrome 88+, Egret 5.0+

Changelog:
- Upgraded to Manifest V3
- Fixed CSP violation errors
- Updated deprecated APIs
- Improved error handling
- Full compatibility with latest Chrome
EOF

# 计算文件大小
PACKAGE_SIZE=$(du -sh "$PACKAGE_DIR" | cut -f1)
FILE_COUNT=$(find "$PACKAGE_DIR" -type f | wc -l)

echo "✅ 打包完成!"
echo "📦 输出目录: $PACKAGE_DIR"
echo "📊 包大小: $PACKAGE_SIZE"
echo "📄 文件数量: $FILE_COUNT 个文件"
echo ""
echo "🚀 下一步操作:"
echo "1. 压缩为 ZIP: cd ../ && zip -r ${PACKAGE_NAME}.zip ${PACKAGE_NAME}/"
echo "2. 或直接加载文件夹到 Chrome 扩展"
```

## 📋 打包步骤

### 方法1: 使用自动脚本
```bash
# 1. 运行打包脚本
chmod +x build_extension.sh
./build_extension.sh

# 2. 创建 ZIP 文件（可选）
cd ../
zip -r egret-inspector-v2.5.6.zip egret-inspector-v2.5.6/
```

### 方法2: 手动打包
```bash
# 1. 创建打包目录
mkdir ../egret-inspector-v2.5.6

# 2. 复制必需文件
cp manifest.json background.js contentScripts.min.js devtools.html devtoolinit.js injectScripts.min.js icon.png ../egret-inspector-v2.5.6/

# 3. 复制面板文件
cp -r ipt ../egret-inspector-v2.5.6/

# 4. 创建 ZIP（可选）
cd ../
zip -r egret-inspector-v2.5.6.zip egret-inspector-v2.5.6/
```

## 🎯 最终打包结构

```
egret-inspector-v2.5.6/
├── manifest.json              # 652 bytes
├── background.js             # ~4.2 KB  
├── contentScripts.min.js     # ~11.8 KB
├── devtools.html            # 234 bytes
├── devtoolinit.js          # 1.8 KB
├── injectScripts.min.js    # ~98 KB
├── icon.png                # ~2.1 KB
├── VERSION.txt             # 版本信息
└── ipt/
    ├── lib/
    │   └── jquery-2.1.1.min.js    # ~84 KB
    └── panel/
        ├── index.html              # ~3.2 KB
        ├── scripts/
        │   └── Loader.js          # ~42 KB
        └── style/
            ├── devtool.css        # ~6.8 KB
            └── refresh.png        # ~0.6 KB
```

**总大小**: 约 255 KB  
**文件数量**: 11 个文件

## 🚀 发布选项

### Chrome Web Store 发布
1. 将打包好的文件夹压缩为 ZIP
2. 登录 [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole/)
3. 上传 ZIP 文件
4. 填写扩展信息
5. 提交审核

### 本地安装分发
1. 直接分发打包后的文件夹
2. 用户通过开发者模式加载
3. 或分发 ZIP 文件供用户解压后加载

## ⚠️ 注意事项

1. **不要包含**: 任何 `.git`、`.DS_Store`、备份文件、文档文件
2. **测试**: 打包后先在本地测试功能是否正常
3. **版本**: 确保 `manifest.json` 中的版本号正确
4. **权限**: 确保所有必需文件都有正确的权限配置
