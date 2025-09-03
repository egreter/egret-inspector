// Service Worker for Egret Inspector - Manifest V3
var __extends = (globalThis && globalThis.__extends) || function (d, b) {
    for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p];
    function __() { this.constructor = d; }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
};

var devToolPort = null;
var contentPort = null;
var inspTabId = 0;

// Handle messages from other parts of the extension
chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
    if (message.from == "devtools-page" && message.tabId) {
        inspTabId = message.tabId;
    }
    if (devToolPort && message.toDevTool) {
        devToolPort.postMessage(message);
    }
    if (message == "getTab") {
        sendResponse(sender);
    }
    return true; // Required for async responses in Manifest V3
});

var PortHandler = function() {
    function PortHandler(port) {
        var self = this;
        this.port = port;
        port.onMessage.addListener(function(message) {
            self.messageReceived(message);
        });
        port.onDisconnect.addListener(function() {
            self.disconnect();
        });
    }
    
    PortHandler.prototype.messageReceived = function(message) {
        if (message.toContent) {
            if (contentPort) contentPort.postMessage(message);
        }
        if (message.toDevTool) {
            if (devToolPort) devToolPort.postMessage(message);
        }
    };
    
    PortHandler.prototype.postMessage = function(message) {
        this.port.postMessage(message);
    };
    
    PortHandler.prototype.disconnect = function() {};
    
    return PortHandler;
}();

var ContentPortHandler = function(_super) {
    __extends(ContentPortHandler, _super);
    function ContentPortHandler() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    
    ContentPortHandler.prototype.messageReceived = function(message) {
        _super.prototype.messageReceived.call(this, message);
    };
    
    ContentPortHandler.prototype.disconnect = function() {
        contentPort = null;
    };
    
    return ContentPortHandler;
}(PortHandler);

var ToolPortHandler = function(_super) {
    __extends(ToolPortHandler, _super);
    function ToolPortHandler() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    
    ToolPortHandler.prototype.messageReceived = function(message) {
        _super.prototype.messageReceived.call(this, message);
        if (message.open) {
            // Use scripting API instead of executeScript in Manifest V3
            chrome.scripting.executeScript({
                target: { tabId: inspTabId },
                func: function() {
                    if (typeof startListen === 'function') {
                        startListen();
                    }
                }
            }).catch(function(error) {
                console.warn('Failed to execute script:', error);
            });
        }
    };
    
    ToolPortHandler.prototype.disconnect = function() {
        contentPort = null;
    };
    
    return ToolPortHandler;
}(PortHandler);

var PortServer = function() {
    function PortServer() {
        this.conns = { stage: {}, view: {}, indexConnection: null };
        this.stageViewMapping = {};
        this.inspecters = {};
        this.views = {};
        this.viewOpened = false;
        this.indexConnection = null;
    }
    
    PortServer.prototype.saveConnection = function(message, port) {
        var from = message.data.from;
        var key = message.key;
        var targetKey = message.data.targetKey;
        if (targetKey) targetKey = decodeURIComponent(targetKey);
        
        this.conns[key] = port;
        port.key = key;
        this.conns[from][key] = message.data.href;
        
        if (targetKey) {
            this.stageViewMapping[targetKey] = key;
            this.stageViewMapping[key] = targetKey;
        }
        this.updateStageList();
    };
    
    PortServer.prototype.updateStageList = function() {
        var conn = this.conns.indexConnection;
        if (conn && conn.disconnected) {
            conn = null;
            this.conns.indexConnection = null;
        }
        if (!conn) return;
        
        conn.postMessage({
            data: {
                name: "stageListUpdated",
                stages: this.conns.stage
            }
        });
    };
    
    PortServer.prototype.createServer = function() {
        var self = this;
        
        chrome.runtime.onConnect.addListener(function(port) {
            port.onMessage.addListener(function(message) {
                message.key = decodeURIComponent(message.key);
                var key = message.key;
                
                if (message.data && message.data.name == "init") {
                    self.saveConnection(message, port);
                }
                
                if (message.data && message.data.type == "index") {
                    self.conns.indexConnection = port;
                    port.onDisconnect.addListener(function() {
                        self.conns.indexConnection = null;
                    });
                    self.updateStageList();
                }
                
                if (message.data && message.data.name == "isDevToolOpen") {
                    var viewKey = self.stageViewMapping[key];
                    var isOpen = viewKey && self.conns[viewKey];
                    isOpen = !!isOpen;
                    port.postMessage({
                        id: message.id,
                        toContent: true,
                        data: isOpen
                    });
                }
                
                if (key in self.stageViewMapping) {
                    var targetKey = self.stageViewMapping[key];
                    var targetPort = self.conns[targetKey];
                    if (targetPort) targetPort.postMessage(message);
                }
            });
            
            port.onDisconnect.addListener(function() {
                var key = port.key || port.name;
                port.disconnected = true;
                
                var mappedKey = self.stageViewMapping[key];
                if (mappedKey) {
                    var mappedPort = self.conns[mappedKey];
                    if (mappedPort) {
                        mappedPort.postMessage({
                            data: {
                                name: "initOptions",
                                highlightClick: false,
                                highlightHover: false,
                                preventTouch: false,
                                showMethods: false,
                                showPrivate: true
                            },
                            key: key
                        });
                    }
                }
                
                delete self.conns[key];
                delete self.conns.stage[key];
                delete self.conns.view[key];
                self.updateStageList();
            });
        });
    };
    
    return PortServer;
}();

// Initialize the port server
(new PortServer()).createServer();
