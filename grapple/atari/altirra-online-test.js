"use strict";

/*
 * Small dependency-free Chrome DevTools client for the browser build of
 * AltirraSDL. Run it with Windows Node while Edge is listening on localhost.
 * This is deliberately kept separate from build.sh: it is a developer smoke
 * test, not a requirement for assembling the game.
 */
var fs = require("fs");
var http = require("http");
var path = require("path");
var WebSocketClient = global.WebSocket;

/* Windows Node 20 has no global WebSocket. Reuse the already installed pure-JS
 * client from the neighbouring 8bitworkshop checkout when that is the case. */
if (!WebSocketClient) {
  WebSocketClient = require(path.resolve(__dirname,
    "../../../8bitworkshop/node_modules/ws"));
}

function getJson(urlPath) {
  return new Promise(function (resolve, reject) {
    http.get({host: "127.0.0.1", port: 9222, path: urlPath}, function (res) {
      var chunks = [];
      res.on("data", function (chunk) { chunks.push(chunk); });
      res.on("end", function () {
        try { resolve(JSON.parse(Buffer.concat(chunks).toString("utf8"))); }
        catch (error) { reject(error); }
      });
    }).on("error", reject);
  });
}

async function main() {
  var pages = await getJson("/json");
  var page = pages.find(function (item) {
    return item.type === "page" && /AltirraSDL/.test(item.title);
  });
  if (!page) throw new Error("AltirraSDL page not found on port 9222");

  var ws = new WebSocketClient(page.webSocketDebuggerUrl);
  var nextId = 1;
  var pending = new Map();
  var opened = new Promise(function (resolve, reject) {
    ws.addEventListener("open", resolve, {once: true});
    ws.addEventListener("error", reject, {once: true});
  });
  ws.addEventListener("message", function (event) {
    var message = JSON.parse(event.data);
    if (!message.id || !pending.has(message.id)) return;
    var handler = pending.get(message.id);
    pending.delete(message.id);
    if (message.error) handler.reject(new Error(message.error.message));
    else handler.resolve(message.result);
  });
  await opened;

  function call(method, params) {
    return new Promise(function (resolve, reject) {
      var id = nextId++;
      pending.set(id, {resolve: resolve, reject: reject});
      ws.send(JSON.stringify({id: id, method: method, params: params || {}}));
    });
  }

  async function evaluate(expression) {
    var response = await call("Runtime.evaluate", {
      expression: expression, returnByValue: true, awaitPromise: true
    });
    if (response.exceptionDetails) {
      throw new Error(response.exceptionDetails.text + ": " +
        JSON.stringify(response.exceptionDetails.exception));
    }
    return response.result.value;
  }

  await call("Page.bringToFront");
  await call("Emulation.setDeviceMetricsOverride", {
    width: 1280, height: 900, deviceScaleFactor: 1, mobile: false
  });
  await new Promise(function (resolve) { setTimeout(resolve, 1000); });

  for (var action of process.argv.slice(3)) {
    if (action.startsWith("click-text:")) {
      var wanted = action.substring(11);
      var clicked = await evaluate("(function(){var wanted=" +
        JSON.stringify(wanted) +
        ";var e=Array.from(document.querySelectorAll('button')).find(function(b){return b.textContent.trim()===wanted&&b.getClientRects().length>0});if(!e)return false;e.click();return true})()");
      if (!clicked) throw new Error("Button not found: " + wanted);
    } else if (action.startsWith("click:")) {
      var point = action.substring(6).split(",").map(Number);
      await call("Input.dispatchMouseEvent", {
        type: "mouseMoved", x: point[0], y: point[1]
      });
      await call("Input.dispatchMouseEvent", {
        type: "mousePressed", x: point[0], y: point[1], button: "left",
        clickCount: 1
      });
      await call("Input.dispatchMouseEvent", {
        type: "mouseReleased", x: point[0], y: point[1], button: "left",
        clickCount: 1
      });
    } else if (action.startsWith("canvas-click:")) {
      var canvasPoint = action.substring(13).split(",").map(Number);
      var dispatched = await evaluate("(function(){var c=document.querySelector('canvas');if(!c)return null;var r=c.getBoundingClientRect();var x=r.left+" +
        canvasPoint[0] + ",y=r.top+" + canvasPoint[1] + ";['pointermove','mousemove','pointerdown','mousedown','pointerup','mouseup','click'].forEach(function(t){var E=t.indexOf('pointer')===0?PointerEvent:MouseEvent;c.dispatchEvent(new E(t,{bubbles:true,cancelable:true,clientX:x,clientY:y,button:0,buttons:t.indexOf('down')>=0?1:0,pointerId:1,pointerType:'mouse'}))});return {x:x,y:y}})()");
      if (!dispatched) throw new Error("Canvas not found");
    } else if (action.startsWith("key:")) {
      var key = action.substring(4);
      var code = key.length === 1 ? "Key" + key.toUpperCase() : key;
      await call("Input.dispatchKeyEvent", {
        type: "keyDown", key: key, code: code,
        windowsVirtualKeyCode: key.length === 1 ? key.toUpperCase().charCodeAt(0) : 0
      });
      await call("Input.dispatchKeyEvent", {
        type: "keyUp", key: key, code: code,
        windowsVirtualKeyCode: key.length === 1 ? key.toUpperCase().charCodeAt(0) : 0
      });
    } else if (action.startsWith("wait:")) {
      await new Promise(function (resolve) {
        setTimeout(resolve, Number(action.substring(5)));
      });
    } else if (action.startsWith("upload:")) {
      var documentNode = await call("DOM.getDocument", {depth: -1, pierce: true});
      var fileInput = await call("DOM.querySelector", {
        nodeId: documentNode.root.nodeId, selector: "input[type=file]"
      });
      if (!fileInput.nodeId) throw new Error("File input not found");
      await call("DOM.setFileInputFiles", {
        nodeId: fileInput.nodeId,
        files: [path.resolve(action.substring(7))]
      });
    }
    await new Promise(function (resolve) { setTimeout(resolve, 750); });
  }

  var inventory = await evaluate("JSON.stringify(Array.from(document.querySelectorAll('button,input,canvas')).map(function(e){var r=e.getBoundingClientRect();return {tag:e.tagName,id:e.id,cls:typeof e.className==='string'?e.className:'',text:(e.textContent||e.value||'').trim(),type:e.type||'',x:Math.round(r.x),y:Math.round(r.y),w:Math.round(r.width),h:Math.round(r.height),pixelWidth:e.width||0,pixelHeight:e.height||0}}))");
  console.log(inventory);

  var shot = await call("Page.captureScreenshot", {
    format: "png", captureBeyondViewport: false, fromSurface: true
  });
  var output = path.resolve(process.argv[2] || "altirra-online.png");
  fs.writeFileSync(output, Buffer.from(shot.data, "base64"));
  console.log("Saved " + output);
  ws.close();
}

main().catch(function (error) {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
