# 版本管理和打包工具使用指南

## 🚀 快速开始

现在你有两个强大的工具来管理版本和打包：

### 1. 版本管理工具 (`version.sh`)
专门用于管理版本号，支持自动同步更新所有相关文件。

### 2. 增强打包工具 (`build_extension.sh`)  
集成了版本管理功能的打包工具，支持版本控制和自动打包。

## 📋 常用操作示例

### 方式1: 使用集成的打包工具（推荐）

```bash
# 1. 使用当前版本打包
./build_extension.sh

# 2. 递增构建版本号并打包（推荐用于日常开发）
./build_extension.sh -i build

# 3. 递增补丁版本号并打包并创建ZIP
./build_extension.sh -i patch -z

# 4. 设置新版本号并打包
./build_extension.sh -v 2.6.0

# 5. 递增主版本号并打包（重大更新时）
./build_extension.sh -i major -z

# 6. 查看帮助
./build_extension.sh --help
```

### 方式2: 分步操作（精确控制）

```bash
# 1. 先管理版本号
./version.sh inc build        # 递增构建版本
# 或
./version.sh set 2.5.7       # 设置指定版本

# 2. 再打包（使用更新后的版本）
./build_extension.sh -z      # 打包并创建ZIP
```

## 🔧 版本管理工具详细说明

### 查看当前版本
```bash
./version.sh show
# 或
./version.sh current
# 或直接运行
./version.sh
```

### 设置版本号
```bash
# 设置为指定版本
./version.sh set 2.5.7
./version.sh set 2.6.0.1
```

### 自动递增版本号
```bash
# 递增构建版本（最常用）
./version.sh inc build     # 2.5.6 -> 2.5.6.1

# 递增补丁版本
./version.sh inc patch     # 2.5.6.1 -> 2.5.7

# 递增次版本号
./version.sh inc minor     # 2.5.7 -> 2.6.0

# 递增主版本号
./version.sh inc major     # 2.6.0 -> 3.0.0
```

### Git 集成
```bash
# 为当前版本创建Git标签
./version.sh tag

# 查看版本历史
./version.sh history
```

## 📦 打包工具详细说明

### 基本打包
```bash
# 使用当前版本号打包
./build_extension.sh
```

### 版本控制打包
```bash
# 设置版本号并打包
./build_extension.sh --version 2.5.7
./build_extension.sh -v 2.5.7

# 递增版本号并打包
./build_extension.sh --increment build
./build_extension.sh -i patch
./build_extension.sh -i minor
./build_extension.sh -i major
```

### 自动化选项
```bash
# 打包完成后自动创建ZIP文件
./build_extension.sh -z
./build_extension.sh --zip

# 不清理旧的打包目录
./build_extension.sh --no-clean

# 组合使用
./build_extension.sh -i build -z    # 递增版本+打包+创建ZIP
```

## 🎯 推荐的工作流程

### 日常开发
```bash
# 每次构建时递增构建版本号
./build_extension.sh -i build -z
```

### 功能发布
```bash
# 递增补丁版本号
./build_extension.sh -i patch -z
```

### 重要更新
```bash
# 递增次版本号
./build_extension.sh -i minor -z
```

### 重大版本
```bash
# 递增主版本号
./build_extension.sh -i major -z

# 可选：创建Git标签
./version.sh tag
```

## 📋 版本号规则

### 格式
- **标准格式**: `x.y.z` (如: 2.5.6)
- **构建格式**: `x.y.z.w` (如: 2.5.6.1)

### 含义
- **主版本 (x)**: 重大更新，可能包含不兼容的变更
- **次版本 (y)**: 新功能添加，向后兼容
- **补丁版本 (z)**: Bug 修复，向后兼容  
- **构建版本 (w)**: 日常构建，小修改

## 🔄 自动同步的文件

版本号变更时，以下文件会自动同步更新：

1. **manifest.json** - Chrome 扩展配置
2. **ipt/panel/index.html** - 面板页面显示
3. **ipt/panel/scripts/Loader.js** - 版本检查逻辑

## ⚠️ 注意事项

1. **备份**: 工具会自动创建备份，如果更新失败会自动恢复
2. **格式**: 版本号必须符合 semantic versioning 格式
3. **Git**: 如果项目是Git仓库，可以使用 `version.sh tag` 创建版本标签
4. **测试**: 每次版本更新后建议先测试功能是否正常

## 🚀 示例场景

### 场景1: 快速迭代开发
```bash
# 修改代码后
./build_extension.sh -i build -z    # 2.5.6.1 -> 2.5.6.2
```

### 场景2: 发布新功能
```bash
# 新功能完成后
./build_extension.sh -i minor -z    # 2.5.6.2 -> 2.6.0
./version.sh tag                     # 创建版本标签
```

### 场景3: 修复重要Bug
```bash
# Bug修复后
./build_extension.sh -i patch -z    # 2.6.0 -> 2.6.1
```

### 场景4: 重大版本发布
```bash
# 重大更新
./build_extension.sh -i major -z    # 2.6.1 -> 3.0.0
./version.sh tag                     # 创建版本标签
```

这样你就可以轻松管理版本号，不需要手动去修改每个文件了！🎉
