#!/bin/bash

# Egret Inspector 升级验证脚本

echo "🔍 Egret Inspector - Manifest V3 升级验证"
echo "========================================"

# 检查 manifest.json
echo "📋 检查 manifest.json..."
if [ -f "manifest.json" ]; then
    manifest_version=$(grep -o '"manifest_version": [0-9]*' manifest.json | grep -o '[0-9]*')
    if [ "$manifest_version" = "3" ]; then
        echo "✅ Manifest 版本: V3"
    else
        echo "❌ Manifest 版本错误: V$manifest_version"
        exit 1
    fi
    
    # 检查 service worker
    if grep -q '"service_worker"' manifest.json; then
        echo "✅ Service Worker 配置: 正确"
    else
        echo "❌ Service Worker 配置: 缺失"
        exit 1
    fi
    
    # 检查权限
    if grep -q '"host_permissions"' manifest.json; then
        echo "✅ Host Permissions: 正确"
    else
        echo "❌ Host Permissions: 缺失"
        exit 1
    fi
else
    echo "❌ manifest.json 文件不存在"
    exit 1
fi

# 检查 background.js
echo "📄 检查 background.js..."
if [ -f "background.js" ]; then
    if grep -q "chrome.scripting.executeScript" background.js; then
        echo "✅ 新 API 使用: chrome.scripting"
    else
        echo "⚠️  警告: 未找到新的 scripting API"
    fi
    echo "✅ Service Worker 文件: 存在"
else
    echo "❌ background.js 文件不存在"
    exit 1
fi

# 检查原有文件
echo "📁 检查原有文件..."
required_files=("devtools.html" "devtoolinit.js" "contentScripts.min.js" "injectScripts.min.js" "icon.png")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file: 存在"
    else
        echo "❌ $file: 缺失"
    fi
done

# 检查面板文件
echo "🎛️  检查面板文件..."
panel_files=("ipt/panel/index.html" "ipt/panel/scripts/Loader.js" "ipt/panel/style/devtool.css")
for file in "${panel_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file: 存在"
    else
        echo "❌ $file: 缺失"
    fi
done

# 检查版本号
echo "🏷️  检查版本号..."
version=$(grep -o '"version": "[^"]*"' manifest.json | grep -o '[0-9.]*')
echo "📦 当前版本: $version"

# 检查是否有废弃的 API 使用
echo "🔍 检查废弃 API..."
deprecated_count=0

# 检查 chrome.extension.getURL
if grep -r "chrome\.extension\.getURL" contentScripts.min.js 2>/dev/null | grep -v "// 向后兼容"; then
    echo "⚠️  发现 chrome.extension.getURL 使用"
    deprecated_count=$((deprecated_count + 1))
fi

# 检查 innerHTML 脚本注入
if grep -r "innerHTML.*=" contentScripts.min.js 2>/dev/null | grep -v "console\|log"; then
    echo "⚠️  发现潜在的 innerHTML CSP 问题"
    deprecated_count=$((deprecated_count + 1))
fi

# 检查新 API 使用
if grep -q "runtime\.getURL" contentScripts.min.js; then
    echo "✅ 使用新的 chrome.runtime.getURL API"
else
    echo "❌ 未找到新的 runtime API"
    deprecated_count=$((deprecated_count + 1))
fi

# 检查 Blob URL 使用
if grep -q "createObjectURL.*blob" contentScripts.min.js; then
    echo "✅ 使用 Blob URL 避免 CSP 问题"
else
    echo "❌ 未找到 CSP 修复"
    deprecated_count=$((deprecated_count + 1))
fi

if [ $deprecated_count -eq 0 ]; then
    echo "✅ 所有 API 和 CSP 问题已修复"
else
    echo "⚠️  发现 $deprecated_count 个潜在问题"
fi

echo ""
echo "🎉 升级验证完成！"
echo "📖 请查看 INSTALL_GUIDE.md 了解安装说明"
echo "📚 请查看 README.md 了解更新详情"
