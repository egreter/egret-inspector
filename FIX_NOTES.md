# Egret Inspector - Manifest V3 修复说明

## 🔧 已修复的问题

### 1. CSP (Content Security Policy) 违规
**问题**: `Refused to execute inline script because it violates the following Content Security Policy directive`

**解决方案**: 
- 将 `innerHTML` 脚本注入改为使用 Blob URL 方式
- 添加了 eval 作为回退方案（在页面上下文中是安全的）
- 确保符合 Manifest V3 的 CSP 要求

### 2. 废弃 API 使用
**问题**: `chrome.extension.getURL` 在 Manifest V3 中已废弃

**解决方案**:
- 更新为使用 `chrome.runtime.getURL`
- 保留了向后兼容的回退方案

### 3. 脚本加载失败
**问题**: `GET http://127.0.0.1:7200/injectScripts.min.js net::ERR_ABORTED 404`

**解决方案**:
- 修复了 URL 格式化函数
- 添加了详细的错误处理和日志
- 确保脚本从扩展包而不是本地服务器加载

## 📋 修复内容详情

### contentScripts.min.js 修改
1. **URL 格式化函数**:
   ```javascript
   // 修改前
   if (t && t.extension && t.extension.getURL) return t.extension.getURL;
   
   // 修改后
   if (t && t.runtime && t.runtime.getURL) return t.runtime.getURL;
   if (t && t.extension && t.extension.getURL) return t.extension.getURL; // 向后兼容
   ```

2. **脚本注入方法**:
   ```javascript
   // 修改前 (违反 CSP)
   e.innerHTML = t;
   
   // 修改后 (符合 CSP)
   var blob = new Blob([t], { type: 'application/javascript' });
   var url = URL.createObjectURL(blob);
   e.src = url;
   ```

3. **错误处理**:
   ```javascript
   o.onerror = function(err) {
     console.error('Failed to load Egret Inspector script:', scriptUrl, err);
   };
   o.onload = function() {
     console.log('Egret Inspector script loaded successfully:', scriptUrl);
   };
   ```

### manifest.json 修改
- 明确指定了 `web_accessible_resources` 中的具体资源
- 确保 `injectScripts.min.js` 可以被内容脚本访问

## 🧪 测试步骤

1. **加载扩展**:
   ```bash
   # 在 Chrome 中访问
   chrome://extensions/
   # 开启开发者模式，加载已解压的扩展程序
   ```

2. **测试页面**:
   - 打开 `test.html` 文件
   - 按 F12 打开开发者工具
   - 查看 Egret 标签页是否出现

3. **检查控制台**:
   - 应该看到 "Egret Inspector script loaded successfully" 消息
   - 应该看到 "Egret DevTool started successfully!" 消息
   - 不应该有 CSP 错误

## 🎯 验证成功的标志

✅ **扩展正常加载**: Chrome 扩展页面显示扩展已启用  
✅ **无 CSP 错误**: 控制台中没有 CSP 违规错误  
✅ **脚本正常加载**: 能看到脚本加载成功的日志  
✅ **DevTools 集成**: F12 中能看到 Egret 标签页  
✅ **功能正常**: 能在 Egret 标签页中看到调试界面  

## 🚨 如果仍有问题

### 检查清单:
1. 确认 Chrome 版本支持 Manifest V3
2. 检查扩展是否正确加载（无错误）
3. 确认页面中有 Egret 游戏运行
4. 查看浏览器控制台的错误信息
5. 检查 Chrome 扩展权限是否正确设置

### 调试步骤:
1. 打开 `chrome://extensions/`
2. 点击扩展的 "详细信息"
3. 开启 "收集错误"
4. 重新加载页面并检查错误日志

## 📞 技术支持

如果修复后仍有问题，请提供：
- Chrome 版本号
- 完整的控制台错误信息
- 扩展错误日志
- 使用的 Egret 游戏版本
