import css from "../css/app.css"
import "phoenix_html"
import LiveSocket from "phoenix_live_view"

import SentimentGuage from "./sentiment_gauge"

let liveSocket = new LiveSocket("/live")
liveSocket.connect()

SentimentGuage.buildChart()