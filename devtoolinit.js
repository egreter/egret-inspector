// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// The function below is executed in the context of the inspected page.
var page_getProperties = function() {
	var data = egret ? egret.MainContext.instance : {};
	// Make a shallow copy with a null prototype, so that sidebar does not
	// expose prototype.
	var props = Object.getOwnPropertyNames(data);
	var copy = {
		__proto__: null
	};
	for (var i = 0; i < props.length; ++i)
		copy[props[i]] = data[props[i]];
	return copy;
};
chrome.devtools.panels.elements.createSidebarPane("Egret Properties", function(sidebar) {
	function updateElementProperties() {
		sidebar.setExpression("(" + page_getProperties.toString() + ")()");
	}
	updateElementProperties();
	chrome.devtools.panels.elements.onSelectionChanged.addListener(updateElementProperties);
});
//(function () {    var t = window.setInterval(function () { var a = egret && (window.clearInterval(t) || egret.devtool.start()); console.log("waiting") }, 100);egret && egret.devtool && (window.clearInterval(t) || egret.devtool.start());})();
chrome.devtools.panels.create("Egret", "icon.png", "ipt/panel/index.html", function(panel) {
	var connected = false;
	var lastNavigation = 0;

	// 提取初始化逻辑为单独函数
	function initializeEgretInspector() {

		chrome.devtools.inspectedWindow.eval(`
            (function() {

                
                // 检查egret对象和devtool是否存在
                if (typeof egret === 'undefined') {

                    return;
                }
                
                if (!egret.devtool) {

                    return;
                }
                
                if (!egret.devtool.start) {

                    return;
                }
                
                var attempts = 0;
                var maxAttempts = 50; // 5秒超时
                var intervalId = setInterval(function() {
                    attempts++;

                    
                    if (egret && egret.devtool && egret.devtool.start) {
                        clearInterval(intervalId);

                        try {
                            egret.devtool.start();
                            console.log('[Egret调试器] 调试器启动成功');
                        } catch(e) {
                            console.error('[Egret调试器] 启动失败:', e);
                        }
                    } else if (attempts >= maxAttempts) {
                        clearInterval(intervalId);
                        console.error('[Egret调试器] 超时: 无法启动egret.devtool.start');
                    }
                }, 100);
            })();
        `);
	}

	// 监听页面导航事件，当检测到页面刷新时重置连接状态并主动重新初始化
	chrome.devtools.network.onNavigated.addListener(function(url) {

		var currentTime = Date.now();
		// 防止重复触发，间隔小于1秒的导航事件认为是同一次
		if (currentTime - lastNavigation > 1000) {
			connected = false;
			console.log('[Egret调试器] 由于页面刷新，重置连接状态');

			// 延迟执行初始化，等待页面脚本加载完成
			// 使用多个延迟尝试，确保初始化成功
			setTimeout(function() {

				initializeEgretInspector();
			}, 500);

			setTimeout(function() {

				initializeEgretInspector();
			}, 1500);

			setTimeout(function() {

				initializeEgretInspector();
			}, 3000);
		}
		lastNavigation = currentTime;
	});

	panel.onShown.addListener(function(w) {

		// 移除connected限制，每次面板显示都尝试初始化
		// 这样可以确保页面刷新后面板能正常工作
		initializeEgretInspector();
		connected = true;

		// 每次面板显示时都发送这个消息，确保状态同步
		backgroundPageConnection.postMessage({
			toDevTool: true,
			toggleMask: true,
			devToolHidden: false
		});
		connected = true;
	});
	panel.onHidden.addListener(function(w) {
		backgroundPageConnection.postMessage({
			toDevTool: true,
			toggleMask: true,
			devToolHidden: true
		});
	});
	var backgroundPageConnection = chrome.runtime.connect({
		name: btoa("for" + String(chrome.devtools.inspectedWindow.tabId))
	});
	backgroundPageConnection.onMessage.addListener(function(message) {
		// Handle responses from the background page, if any
		if (message.action === 'injectViaDevTool' && message.code) {

			try {
				// 使用chrome.devtools.inspectedWindow.eval，这个可以绕过CSP
				chrome.devtools.inspectedWindow.eval(message.code, function(result, isException) {
					if (isException) {
						console.error('[Egret调试器] DevTool脚本执行失败:', isException);
					} else {

					}
				});
			} catch (e) {
				console.error('[Egret调试器] DevTool脚本错误:', e);
			}
		}


	});
	backgroundPageConnection.postMessage({
		tabId: chrome.devtools.inspectedWindow.tabId
	});
	panel.onSearch.addListener(function(action, query) {
		return false;
	});
});