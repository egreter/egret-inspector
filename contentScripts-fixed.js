// Egret Inspector Content Script - Manifest V3 兼容版本
// 修复 CSP 和 API 兼容性问题

var egret;
(function (egret) {
    var devtool;
    (function (devtool) {
        var Loader = (function () {
            function Loader() {
                var self = this;
                this.port = new devtool.ContentPort(location.host);
                this.port.on('openDevtool', function () {
                    self.injectScripts();
                });
            }

            // 修复：使用 chrome.runtime.getURL 替代废弃的 chrome.extension.getURL
            Loader.urlFormatFunc = function () {
                var chrome = window['chrome'] || null;
                if (chrome && chrome.runtime && chrome.runtime.getURL) {
                    return chrome.runtime.getURL.bind(chrome.runtime);
                }
                // 回退方案
                return function (path) {
                    return chrome.extension ? chrome.extension.getURL(path) : path;
                };
            };

            Loader.prototype.injectScripts = function () {
                var self = this;
                var scripts = [
                    'ipt/inject/Egret2xInspector.js',
                    'ipt/inject/Main.js',
                ];
                
                if (typeof EGRETRELEASE !== 'undefined' && EGRETRELEASE) {
                    scripts = ['injectScripts.min.js'];
                }
                
                window.setTimeout(function () {
                    self.addScript(scripts);
                    self.startInspectIfDevToolOpen();
                }, 200);
            };

            // 修复：使用安全的脚本注入方式，避免 innerHTML 的 CSP 问题
            Loader.prototype.injectScript = function (code) {
                try {
                    // 方法1：创建 script 元素并设置 src 为 data URL
                    var script = document.createElement('script');
                    var blob = new Blob([code], { type: 'application/javascript' });
                    var url = URL.createObjectURL(blob);
                    script.src = url;
                    script.onload = function() {
                        URL.revokeObjectURL(url);
                    };
                    document.head.appendChild(script);
                } catch (e) {
                    console.warn('Failed to inject script via blob, trying alternative method:', e);
                    try {
                        // 方法2：使用 chrome.scripting API（如果可用）
                        if (window.chrome && window.chrome.scripting) {
                            chrome.scripting.executeScript({
                                target: { tabId: chrome.devtools.inspectedWindow.tabId },
                                func: new Function(code)
                            });
                        } else {
                            // 方法3：直接执行（在页面上下文中是安全的）
                            window.eval(code);
                        }
                    } catch (e2) {
                        console.error('All script injection methods failed:', e2);
                    }
                }
            };

            Loader.addScript = function (scripts) {
                var self = this;
                var urlFormat = this.urlFormatFunc();
                
                scripts.forEach(function (scriptPath) {
                    try {
                        var script = document.createElement('script');
                        var scriptUrl = urlFormat(scriptPath);
                        script.src = scriptUrl;
                        script.async = false;
                        script.onerror = function(error) {
                            console.error('Failed to load script:', scriptUrl, error);
                        };
                        document.head.appendChild(script);
                    } catch (e) {
                        console.error('Error adding script:', scriptPath, e);
                    }
                });
            };

            Loader.prototype.startInspectIfDevToolOpen = function () {
                var self = this;
                this.port.post({ name: 'isDevToolOpen' }, null, function (isOpen) {
                    if (isOpen) {
                        // 使用修复的注入方法
                        var inspectorCode = '(function () {' +
                            'var t = window.setInterval(function () {' +
                                'var a = egret && egret.devtool && egret.devtool.start && ' +
                                '(window.clearInterval(t) || egret.devtool.start());' +
                                'console.log("waiting for egret devtool");' +
                            '}, 100);' +
                            'egret && egret.devtool && egret.devtool.start && ' +
                            '(window.clearInterval(t) || egret.devtool.start());' +
                        '})();';
                        
                        self.injectScript(inspectorCode);
                    }
                });
            };

            Loader.start = function () {
                if (!this.instance) {
                    this.instance = new Loader();
                }
                this.instance.injectScripts();
            };

            return Loader;
        })();
        
        devtool.Loader = Loader;
    })(devtool = egret.devtool || (egret.devtool = {}));
})(egret || (egret = {}));

// 定义 EGRETRELEASE 如果未定义
if (typeof EGRETRELEASE === 'undefined') {
    var EGRETRELEASE = true;
}

// 启动加载器
if (egret && egret.devtool && egret.devtool.Loader) {
    egret.devtool.Loader.start();
}
