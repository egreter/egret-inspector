#!/bin/bash

# 版本管理脚本
# 用于统一管理 Egret Inspector 扩展的版本号

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

# 函数：获取当前版本号
get_current_version() {
    grep -o '"version": "[^"]*"' manifest.json | grep -o '[0-9.]*'
}

# 函数：验证版本号格式
validate_version() {
    local version="$1"
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        print_error "❌ 无效的版本号格式: $version"
        print_info "支持的格式: x.y.z 或 x.y.z.w (如: 2.5.6 或 2.5.6.1)"
        return 1
    fi
    return 0
}

# 函数：更新所有文件中的版本号
update_all_versions() {
    local new_version="$1"
    local current_version=$(get_current_version)
    
    if [ "$current_version" = "$new_version" ]; then
        print_warning "⚠️  版本号未改变: $new_version"
        return 0
    fi
    
    print_info "📝 更新版本号: $current_version -> $new_version"
    
    # 备份文件
    cp manifest.json manifest.json.bak
    cp ipt/panel/index.html ipt/panel/index.html.bak
    cp ipt/panel/scripts/Loader.js ipt/panel/scripts/Loader.js.bak
    
    # 更新 manifest.json
    if sed -i '' "s/\"version\": \"$current_version\"/\"version\": \"$new_version\"/" manifest.json; then
        print_success "  ✅ manifest.json"
    else
        print_error "  ❌ 更新 manifest.json 失败"
        return 1
    fi
    
    # 更新面板HTML
    if sed -i '' "s/Egret Inspector $current_version/Egret Inspector $new_version/" ipt/panel/index.html; then
        print_success "  ✅ ipt/panel/index.html"
    else
        print_error "  ❌ 更新 ipt/panel/index.html 失败"
        return 1
    fi
    
    # 更新 Loader.js 中的版本检查
    if sed -i '' "s/var e=\"$current_version\"/var e=\"$new_version\"/" ipt/panel/scripts/Loader.js; then
        print_success "  ✅ ipt/panel/scripts/Loader.js"
    else
        print_error "  ❌ 更新 ipt/panel/scripts/Loader.js 失败"
        return 1
    fi
    
    # 删除备份文件
    rm -f manifest.json.bak ipt/panel/index.html.bak ipt/panel/scripts/Loader.js.bak
    
    print_success "🎯 版本号更新完成！"
    return 0
}

# 函数：恢复备份
restore_backup() {
    if [ -f manifest.json.bak ]; then
        mv manifest.json.bak manifest.json
        print_info "已恢复 manifest.json"
    fi
    if [ -f ipt/panel/index.html.bak ]; then
        mv ipt/panel/index.html.bak ipt/panel/index.html
        print_info "已恢复 ipt/panel/index.html"
    fi
    if [ -f ipt/panel/scripts/Loader.js.bak ]; then
        mv ipt/panel/scripts/Loader.js.bak ipt/panel/scripts/Loader.js
        print_info "已恢复 ipt/panel/scripts/Loader.js"
    fi
}

# 函数：自动递增版本号
increment_version() {
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
            print_error "❌ 无效的递增类型: $1"
            print_info "支持的类型: major, minor, patch, build"
            return 1
            ;;
    esac
    
    local new_version=$(IFS=.; echo "${version_parts[*]}")
    echo "$new_version"
}

# 函数：显示版本历史
show_version_history() {
    print_info "📚 版本历史 (基于 git 标签):"
    if command -v git >/dev/null 2>&1 && [ -d .git ]; then
        git tag -l "v*" --sort=-version:refname | head -10 | while read tag; do
            local date=$(git log -1 --format=%ai "$tag" 2>/dev/null | cut -d' ' -f1)
            echo "  📦 $tag ($date)"
        done
    else
        print_warning "  Git 仓库未找到或 git 命令不可用"
    fi
}

# 函数：创建版本标签
create_version_tag() {
    local version="$1"
    if command -v git >/dev/null 2>&1 && [ -d .git ]; then
        print_info "🏷️  创建 Git 标签: v$version"
        git add -A
        git commit -m "chore: bump version to $version" 2>/dev/null
        git tag "v$version"
        print_success "  ✅ 标签创建成功"
    else
        print_warning "  Git 仓库未找到，跳过标签创建"
    fi
}

# 主程序
case "$1" in
    "show"|"current"|"")
        current=$(get_current_version)
        print_info "📦 当前版本: $current"
        ;;
    "set")
        if [ -z "$2" ]; then
            print_error "❌ 请指定版本号"
            echo "用法: $0 set <version>"
            exit 1
        fi
        if validate_version "$2"; then
            if update_all_versions "$2"; then
                print_success "✅ 版本设置成功: $2"
            else
                print_error "❌ 版本设置失败"
                restore_backup
                exit 1
            fi
        else
            exit 1
        fi
        ;;
    "increment"|"inc")
        if [ -z "$2" ]; then
            print_error "❌ 请指定递增类型"
            echo "用法: $0 increment <major|minor|patch|build>"
            exit 1
        fi
        new_version=$(increment_version "$2")
        if [ $? -eq 0 ]; then
            if update_all_versions "$new_version"; then
                print_success "✅ 版本递增成功: $new_version"
            else
                print_error "❌ 版本递增失败"
                restore_backup
                exit 1
            fi
        else
            exit 1
        fi
        ;;
    "tag")
        current=$(get_current_version)
        create_version_tag "$current"
        ;;
    "history")
        show_version_history
        ;;
    "help"|"--help"|"-h")
        echo "Egret Inspector 版本管理工具"
        echo ""
        echo "用法:"
        echo "  $0 [命令] [参数]"
        echo ""
        echo "命令:"
        echo "  show, current        显示当前版本号"
        echo "  set <version>        设置指定版本号"
        echo "  increment <type>     递增版本号"
        echo "    type: major, minor, patch, build"
        echo "  tag                  为当前版本创建 Git 标签"
        echo "  history              显示版本历史"
        echo "  help                 显示此帮助信息"
        echo ""
        echo "示例:"
        echo "  $0 show              # 显示当前版本"
        echo "  $0 set 2.5.7         # 设置版本为 2.5.7"
        echo "  $0 inc patch         # 递增补丁版本"
        echo "  $0 inc build         # 递增构建版本"
        echo "  $0 tag               # 创建当前版本的标签"
        echo ""
        echo "版本号格式:"
        echo "  x.y.z       (如: 2.5.6)"
        echo "  x.y.z.w     (如: 2.5.6.1)"
        ;;
    *)
        print_error "❌ 未知命令: $1"
        echo "使用 '$0 help' 查看帮助信息"
        exit 1
        ;;
esac
