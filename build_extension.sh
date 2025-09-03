#!/bin/bash

# Egret Inspector 扩展自动打包脚本
# 支持自动版本号管理

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印彩色输出
print_info() { echo -e "${BLUE}$1${NC}"; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}$1${NC}"; }
print_error() { echo -e "${RED}$1${NC}"; }

# 显示帮助信息
show_help() {
    cat << EOF
🚀 Egret Inspector 扩展打包工具

用法:
    $0 [选项]

选项:
    -i, --increment TYPE    自动递增版本号
                           TYPE 可以是: major, minor, patch, build
                           例如: -i build (2.5.6.2 -> 2.5.6.3)
                                -i patch (2.5.6.2 -> 2.5.7)
                                -i minor (2.5.6.2 -> 2.6.0)
                                -i major (2.5.6.2 -> 3.0.0)
    
    -v, --version VERSION   设置指定版本号
                           例如: -v 2.6.0
    
    -z, --zip              打包完成后创建 ZIP 文件
    
    --no-clean             不清理旧的打包目录
    
    --version-only          只处理版本号，不进行打包
    
    -h, --help             显示此帮助信息

示例:
    $0                      # 默认：使用当前版本号直接打包
    $0 -z                   # 使用当前版本号打包并创建ZIP
    $0 -i build -z          # 递增构建版本号并打包ZIP
    $0 -v 2.6.0 -z          # 设置版本号为2.6.0并打包ZIP
    $0 --version-only -i patch  # 只递增补丁版本号，不打包

说明:
    - 默认行为：读取 manifest.json 中的版本号直接打包，不修改任何文件
    - 只有在使用 -i 或 -v 参数时才会修改版本号
    - 所有版本号以 manifest.json 为准，其他文件会自动同步
EOF
}

# 函数：获取当前版本号
get_current_version() {
    grep -o '"version": "[^"]*"' manifest.json | grep -o '[0-9.]*'
}

# 函数：递增版本号
increment_version() {
    local current_version="$1"
    local increment_type="$2"
    
    # 分割版本号
    IFS='.' read -ra VERSION_PARTS <<< "$current_version"
    local major=${VERSION_PARTS[0]:-0}
    local minor=${VERSION_PARTS[1]:-0}
    local patch=${VERSION_PARTS[2]:-0}
    local build=${VERSION_PARTS[3]:-0}
    
    case "$increment_type" in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            build=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            build=0
            ;;
        "patch")
            patch=$((patch + 1))
            build=0
            ;;
        "build")
            build=$((build + 1))
            ;;
        *)
            print_error "❌ 无效的递增类型: $increment_type"
            return 1
            ;;
    esac
    
    echo "${major}.${minor}.${patch}.${build}"
}

# 函数：更新版本号（仅在需要时调用）
update_version() {
    local new_version="$1"
    local current_version=$(get_current_version)
    
    print_info "📝 更新版本号 $current_version -> $new_version"
    
    # 更新 manifest.json
    sed -i '' "s/\"version\": \"$current_version\"/\"version\": \"$new_version\"/" manifest.json
    print_success "  ✅ manifest.json"
    
    # 更新面板HTML
    sed -i '' "s/Egret Inspector $current_version/Egret Inspector $new_version/" ipt/panel/index.html
    print_success "  ✅ ipt/panel/index.html"
    
    # 更新 Loader.js 中的版本检查
    sed -i '' "s/var e=\"$current_version\"/var e=\"$new_version\"/" ipt/panel/scripts/Loader.js
    print_success "  ✅ ipt/panel/scripts/Loader.js"
    
    print_success "🎯 版本号更新完成！"
}

# 函数：同步其他文件的版本号（不修改 manifest.json）
sync_version_to_other_files() {
    local manifest_version=$(get_current_version)
    
    print_info "🔄 同步版本号到其他文件: $manifest_version"
    
    # 检查并更新面板HTML中的版本显示
    local html_version=$(grep -o "Egret Inspector [0-9.]*" ipt/panel/index.html | grep -o "[0-9.]*" || echo "")
    if [ "$html_version" != "$manifest_version" ]; then
        if [ -n "$html_version" ]; then
            sed -i '' "s/Egret Inspector $html_version/Egret Inspector $manifest_version/" ipt/panel/index.html
        else
            # 如果没找到版本号，尝试其他模式
            sed -i '' "s/Egret Inspector [0-9.]*/Egret Inspector $manifest_version/" ipt/panel/index.html
        fi
        print_success "  ✅ 同步到 ipt/panel/index.html"
    fi
    
    # 检查并更新 Loader.js 中的版本检查
    local js_version=$(grep -o 'var e="[0-9.]*"' ipt/panel/scripts/Loader.js | grep -o "[0-9.]*" || echo "")
    if [ "$js_version" != "$manifest_version" ]; then
        if [ -n "$js_version" ]; then
            sed -i '' "s/var e=\"$js_version\"/var e=\"$manifest_version\"/" ipt/panel/scripts/Loader.js
        else
            # 如果没找到版本号，尝试其他模式
            sed -i '' "s/var e=\"[0-9.]*\"/var e=\"$manifest_version\"/" ipt/panel/scripts/Loader.js
        fi
        print_success "  ✅ 同步到 ipt/panel/scripts/Loader.js"
    fi
}

# 函数：自动递增版本号
auto_increment_version() {
    local current_version=$(get_current_version)
    local version_parts=(${current_version//./ })
    
    case "$1" in
        "major")
            version_parts[0]=$((version_parts[0] + 1))
            version_parts[1]=0
            version_parts[2]=0
            if [ ${#version_parts[@]} -gt 3 ]; then version_parts[3]=0; fi
            ;;
        "minor")
            version_parts[1]=$((version_parts[1] + 1))
            version_parts[2]=0
            if [ ${#version_parts[@]} -gt 3 ]; then version_parts[3]=0; fi
            ;;
        "patch")
            version_parts[2]=$((version_parts[2] + 1))
            if [ ${#version_parts[@]} -gt 3 ]; then version_parts[3]=0; fi
            ;;
        "build")
            if [ ${#version_parts[@]} -eq 3 ]; then
                version_parts[3]=1
            else
                version_parts[3]=$((version_parts[3] + 1))
            fi
            ;;
        *)
            print_error "❌ 无效的版本类型: $1"
            print_info "支持的类型: major, minor, patch, build"
            return 1
            ;;
    esac
    
    local new_version=$(IFS=.; echo "${version_parts[*]}")
    update_version "$new_version"
    echo "$new_version"
}

# 解析命令行参数
increment_type=""
set_version=""
create_zip=false
clean_build=true
only_version=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--increment)
            increment_type="$2"
            shift 2
            ;;
        -v|--version)
            set_version="$2"
            shift 2
            ;;
        -z|--zip)
            create_zip=true
            shift
            ;;
        --no-clean)
            clean_build=false
            shift
            ;;
        --version-only)
            only_version=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# 获取当前版本
current_version=$(get_current_version)
print_info "📖 当前版本: $current_version"

# 版本处理逻辑
should_update_version=false
new_version="$current_version"

if [ -n "$set_version" ]; then
    # 用户指定了版本号
    new_version="$set_version"
    should_update_version=true
    print_info "🎯 设置版本号为: $new_version"
elif [ -n "$increment_type" ]; then
    # 用户要求自动递增版本号
    new_version=$(increment_version "$current_version" "$increment_type")
    should_update_version=true
    print_info "📈 自动递增版本号: $current_version -> $new_version"
else
    # 默认行为：使用当前版本，不修改
    print_info "📋 使用当前版本号: $current_version（不修改文件）"
fi

# 只处理版本号，不打包
if [ "$only_version" = true ]; then
    if [ "$should_update_version" = true ]; then
        update_version "$new_version"
        print_success "🎉 版本号处理完成！"
    else
        print_info "💡 没有版本号变更需要处理"
    fi
    exit 0
fi

# 检查并同步其他文件的版本号（确保一致性）
sync_version_to_other_files

# 如果需要更新版本号，执行更新
if [ "$should_update_version" = true ]; then
    update_version "$new_version"
fi

# 开始打包过程
print_info "🔧 开始打包 Egret Inspector 扩展..."
print_info "======================================"

# 使用最终版本号
FINAL_VERSION="$new_version"
PACKAGE_NAME="egret-inspector-v${FINAL_VERSION}"
PACKAGE_DIR="../${PACKAGE_NAME}"

# 清理旧的打包目录
if [ "$clean_build" = true ] && [ -d "$PACKAGE_DIR" ]; then
    print_info "🗑️  清理旧的打包目录..."
    rm -rf "$PACKAGE_DIR"
fi

# 创建新的打包目录
mkdir -p "$PACKAGE_DIR"

# 复制必需的核心文件
print_info "📁 复制核心文件..."
cp manifest.json "$PACKAGE_DIR/" && print_success "  ✅ manifest.json"
cp background.js "$PACKAGE_DIR/" && print_success "  ✅ background.js"
cp contentScripts.min.js "$PACKAGE_DIR/" && print_success "  ✅ contentScripts.min.js"
cp devtools.html "$PACKAGE_DIR/" && print_success "  ✅ devtools.html"
cp devtoolinit.js "$PACKAGE_DIR/" && print_success "  ✅ devtoolinit.js"
cp injectScripts.min.js "$PACKAGE_DIR/" && print_success "  ✅ injectScripts.min.js"
cp icon.png "$PACKAGE_DIR/" && print_success "  ✅ icon.png"

# 复制面板文件
print_info "🎛️  复制面板文件..."
mkdir -p "$PACKAGE_DIR/ipt/lib"
mkdir -p "$PACKAGE_DIR/ipt/panel/scripts"
mkdir -p "$PACKAGE_DIR/ipt/panel/style"

cp ipt/lib/jquery-2.1.1.min.js "$PACKAGE_DIR/ipt/lib/" && print_success "  ✅ ipt/lib/jquery-2.1.1.min.js"
cp ipt/panel/index.html "$PACKAGE_DIR/ipt/panel/" && print_success "  ✅ ipt/panel/index.html"
cp ipt/panel/scripts/Loader.js "$PACKAGE_DIR/ipt/panel/scripts/" && print_success "  ✅ ipt/panel/scripts/Loader.js"
cp ipt/panel/style/devtool.css "$PACKAGE_DIR/ipt/panel/style/" && print_success "  ✅ ipt/panel/style/devtool.css"
cp ipt/panel/style/refresh.png "$PACKAGE_DIR/ipt/panel/style/" && print_success "  ✅ ipt/panel/style/refresh.png"

# 创建版本信息文件
print_info "📋 创建版本信息..."
cat > "$PACKAGE_DIR/VERSION.txt" << EOF
Egret Inspector - Chrome Extension
===================================

Version: $FINAL_VERSION
Manifest: V3
Build Date: $(date '+%Y-%m-%d %H:%M:%S')
Build Host: $(hostname)
Compatible: Chrome 88+, Egret 5.0+

Features:
- DevTools integration for Egret games
- Display object tree inspection
- Real-time property editing  
- Performance monitoring (FPS)
- Object highlighting
- Search functionality

Changelog v$FINAL_VERSION:
- Upgraded to Manifest V3
- Fixed CSP violation errors  
- Updated deprecated APIs (chrome.extension -> chrome.runtime)
- Improved error handling
- Full compatibility with latest Chrome browsers
- Enhanced script loading mechanism
- Automated version management

Installation:
1. Open Chrome Extensions (chrome://extensions/)
2. Enable Developer Mode
3. Click "Load unpacked extension"
4. Select this folder
5. Open DevTools (F12) in any Egret game page
6. Look for "Egret" tab in DevTools

Support:
- Egret Engine 5.0+
- Chrome 88+
- All Egret-based games and applications

Build Information:
- Package: $PACKAGE_NAME
- Build Script: build_extension.sh
- Auto Version Management: Enabled
EOF

# 验证必需文件
print_info "🔍 验证打包文件..."
REQUIRED_FILES=(
    "manifest.json"
    "background.js" 
    "contentScripts.min.js"
    "devtools.html"
    "devtoolinit.js"
    "injectScripts.min.js"
    "icon.png"
    "ipt/lib/jquery-2.1.1.min.js"
    "ipt/panel/index.html"
    "ipt/panel/scripts/Loader.js"
    "ipt/panel/style/devtool.css"
    "ipt/panel/style/refresh.png"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$PACKAGE_DIR/$file" ]; then
        print_error "  ❌ 缺失文件: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -eq 0 ]; then
    print_success "  ✅ 所有必需文件都已复制"
else
    print_error "  ❌ 发现 $MISSING_FILES 个缺失文件"
    exit 1
fi

# 计算统计信息
PACKAGE_SIZE=$(du -sh "$PACKAGE_DIR" | cut -f1)
FILE_COUNT=$(find "$PACKAGE_DIR" -type f | wc -l | tr -d ' ')
DIR_COUNT=$(find "$PACKAGE_DIR" -type d | wc -l | tr -d ' ')

print_success ""
print_success "✅ 打包完成!"
print_info "======================================"
print_info "📦 包名称: $PACKAGE_NAME"
print_info "📦 输出目录: $PACKAGE_DIR"
print_info "📊 包大小: $PACKAGE_SIZE"
print_info "📄 文件数量: $FILE_COUNT 个文件"
print_info "📁 目录数量: $DIR_COUNT 个目录"
print_info "🏷️  版本号: $FINAL_VERSION"

# 自动创建ZIP文件
if [ "$create_zip" = true ]; then
    print_info ""
    print_info "📦 创建ZIP文件..."
    cd ../
    ZIP_NAME="${PACKAGE_NAME}.zip"
    if [ -f "$ZIP_NAME" ]; then
        rm "$ZIP_NAME"
        print_warning "  🗑️  删除旧的ZIP文件"
    fi
    zip -r "$ZIP_NAME" "${PACKAGE_NAME}/" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        ZIP_SIZE=$(du -sh "$ZIP_NAME" | cut -f1)
        print_success "  ✅ ZIP文件创建成功: $ZIP_NAME ($ZIP_SIZE)"
    else
        print_error "  ❌ ZIP文件创建失败"
    fi
    cd egret-inspector
fi

print_info ""
print_info "🏗️  文件结构:"
tree "$PACKAGE_DIR" 2>/dev/null || find "$PACKAGE_DIR" -type f | sed 's|[^/]*/||g' | sort

print_info ""
print_success "🚀 下一步操作:"
print_info "======================================"
if [ "$create_zip" = false ]; then
    print_info "选项1 - 创建ZIP文件用于Chrome Web Store:"
    print_info "  cd ../ && zip -r ${PACKAGE_NAME}.zip ${PACKAGE_NAME}/"
    print_info "  或运行: $0 -z (自动创建ZIP)"
    print_info ""
fi
print_info "选项2 - 直接使用文件夹:"
print_info "  1. 打开 Chrome 扩展页面 (chrome://extensions/)"
print_info "  2. 开启开发者模式"  
print_info "  3. 点击'加载已解压的扩展程序'"
print_info "  4. 选择目录: $PACKAGE_DIR"
print_info ""
print_info "选项3 - 测试扩展:"
print_info "  1. 先按选项2加载扩展"
print_info "  2. 打开任何网页，按F12"
print_info "  3. 查看是否有'Egret'标签页"
print_info ""
print_success "🎉 扩展已准备就绪!"
