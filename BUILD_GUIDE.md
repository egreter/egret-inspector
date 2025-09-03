# 🚀 Egret Inspector 构建指南

## 📋 构建脚本使用说明

### 基本用法

```bash
# 1. 默认打包（推荐日常使用）
./build_extension.sh

# 2. 默认打包 + 自动创建ZIP
./build_extension.sh -z

# 3. 递增版本号 + 打包 + 创建ZIP（发布新版本时）
./build_extension.sh -i build -z
```

### 🔧 详细参数说明

| 参数 | 功能 | 示例 |
|------|------|------|
| **无参数** | 使用当前版本号直接打包，不修改任何文件 | `./build_extension.sh` |
| `-z, --zip` | 打包后自动创建ZIP文件 | `./build_extension.sh -z` |
| `-i, --increment TYPE` | 自动递增版本号并打包 | `./build_extension.sh -i build` |
| `-v, --version VERSION` | 设置指定版本号 | `./build_extension.sh -v 2.6.0` |
| `--version-only` | 只处理版本号，不打包 | `./build_extension.sh --version-only -i patch` |
| `--no-clean` | 不清理旧的打包目录 | `./build_extension.sh --no-clean` |
| `-h, --help` | 显示帮助信息 | `./build_extension.sh --help` |

### 📈 版本号递增类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `build` | 构建版本号 +1 | 2.5.6.2 → 2.5.6.3 |
| `patch` | 补丁版本号 +1，构建版本重置为0 | 2.5.6.2 → 2.5.7.0 |
| `minor` | 次版本号 +1，补丁和构建版本重置为0 | 2.5.6.2 → 2.6.0.0 |
| `major` | 主版本号 +1，其他版本重置为0 | 2.5.6.2 → 3.0.0.0 |

### 🎯 常用工作流程

#### 📦 日常开发打包
```bash
# 修改代码后，使用当前版本号打包测试
./build_extension.sh
```

#### 🔄 发布小更新
```bash
# 递增构建版本号并创建ZIP文件
./build_extension.sh -i build -z
```

#### 🚀 发布大版本
```bash
# 递增次版本号并创建ZIP文件  
./build_extension.sh -i minor -z
```

#### 🛠️ 只更新版本号
```bash
# 只递增版本号，不打包（适合准备发布前）
./build_extension.sh --version-only -i patch
```

### 📁 输出说明

- **打包目录**: `../egret-inspector-v[版本号]/`
- **ZIP文件**: `../egret-inspector-v[版本号].zip`
- **版本管理**: 以 `manifest.json` 为准，其他文件自动同步

### ✨ 核心特性

1. **智能版本管理**: 默认不修改版本号，只在明确指定时才更新
2. **版本同步**: 自动同步 `manifest.json`、`index.html`、`Loader.js` 中的版本号
3. **自动打包**: 复制所有必要文件到独立目录
4. **文件验证**: 确保所有必需文件都已正确复制
5. **ZIP创建**: 可选择性创建用于Chrome Web Store的ZIP文件

### 🔍 故障排除

如果遇到问题，可以：

1. 检查语法：`bash -n build_extension.sh`
2. 查看帮助：`./build_extension.sh --help`
3. 只更新版本号测试：`./build_extension.sh --version-only -i build`

### 📝 版本号规则

采用四段式版本号：`主版本.次版本.补丁版本.构建版本`
- 例如：`2.5.6.4` 表示第2个主版本，第5个次版本，第6个补丁版本，第4个构建版本
- 所有版本号变更都会自动同步到相关文件中

---

*此脚本专为 Egret Inspector Chrome 扩展设计，支持 Manifest V3 标准。*
