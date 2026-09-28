"use strict";

const tools = document.getElementById("tools");
const title = document.getElementById("app-title");
const selectedGame = document.getElementById("selected-game");
const footerPath = document.getElementById("footer-path");
const dpiWarning = document.getElementById("dpi-warning");
const connectionStatus = document.getElementById("connection-status");
const updateButton = document.querySelector('[data-action="update"]');

function send(message) {
  const bridge = window.chrome && window.chrome.webview;
  if (!bridge) {
    connectionStatus.textContent = "WebView2 application bridge is unavailable.";
    return;
  }
  bridge.postMessage(message);
}

function renderState(state) {
  title.textContent = `${state.name} v${state.version}`;
  selectedGame.textContent = `The Selected Game @ "${state.gameLocation}"`;
  footerPath.textContent = state.gameLocation;
  footerPath.title = state.gameLocation;
  dpiWarning.hidden = !state.dpiWarning;

  for (const button of document.querySelectorAll("[data-game]")) {
    button.disabled = !state.games[button.dataset.game];
  }

  tools.replaceChildren();
  for (const tool of state.tools) {
    const button = document.createElement("button");
    button.className = "wood-button tool-button";
    button.type = "button";
    button.textContent = tool.title;
    button.dataset.tool = tool.key;
    tools.append(button);
  }

  connectionStatus.textContent = "";
}

window.chrome?.webview?.addEventListener("message", (event) => {
  const message = event.data;
  if (message.type === "state") {
    renderState(message);
  } else if (message.type === "update-status") {
    updateButton.disabled = message.checking;
    updateButton.textContent = message.checking ? "Checking..." : "Update?";
  }
});

document.addEventListener("click", (event) => {
  const actionButton = event.target.closest("[data-action]");
  if (actionButton) {
    send({ action: actionButton.dataset.action });
    return;
  }

  const toolButton = event.target.closest("[data-tool]");
  if (toolButton) {
    send({ action: "launch-tool", key: toolButton.dataset.tool });
    return;
  }

  const gameButton = event.target.closest("[data-game]");
  if (gameButton && !gameButton.disabled) {
    send({ action: "launch-game", key: gameButton.dataset.game });
  }
});

if (window.chrome && window.chrome.webview) {
  send({ action: "ready" });
} else {
  connectionStatus.textContent = "WebView2 application bridge is unavailable.";
}
