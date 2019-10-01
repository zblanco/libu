import css from "../css/app.css"
import "phoenix_html"
import LiveSocket from "phoenix_live_view"

import SentimentGuage from "./sentiment_gauge"

const targetNode = document.getElementsByClassName("logged_events")[0]
document.addEventListener("DOMContentLoaded", function() {
  targetNode.scrollTop = targetNode.scrollHeight
});

let Hooks = {}
Hooks.NewLoggedEvents = {
  updated(){
    this.el.scrollTop = this.el.scrollHeight
  }
}


let liveSocket = new LiveSocket("/live")
liveSocket.connect()

SentimentGuage.buildChart()