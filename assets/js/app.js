import css from "../css/app.css"
import "phoenix_html"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

// import SentimentGuage from "./sentiment_gauge"

const targetNode = document.getElementById("convo_messages")
document.addEventListener("DOMContentLoaded", function() {
  targetNode.scrollTop = targetNode.scrollHeight
});

let Hooks = {}
Hooks.MessageAdded = {
  updated(){
    this.el.scrollTop = this.el.scrollHeight
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken, hooks: Hooks}});

liveSocket.connect()

// SentimentGuage.buildChart()