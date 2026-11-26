const NEXT = {
  ready: "Start the round",
  park: "Close the park",
  activities: "Close the activities",
  guard: "Close the forest guard",
  market: "Close the market",
  results: "Update the board"
};

const send = connectToGame("[GM]", onMessage, ok => byId("connection").className = "dot " + (ok ? "on" : "off"));
byId("start").onclick = () => send({ type: "gmStart" });
byId("proceed").onclick = () => send({ type: "gmProceed" });
setInterval(() => send({ type: "lobby" }), 2000);
showJoinUrl(location.origin + "/");

function onMessage(m) {
  if (m.type === "registered") send({ type: "gmLogin" });
  if (m.type === "join" && m.addresses.length) showJoinUrl(`http://${m.addresses[0]}:${m.port}/`);
  if (m.type === "lobby") renderLobby(m);
  if (m.type === "state") renderGame(m);
}

function showJoinUrl(url) {
  byId("joinUrl").textContent = url;
  try {
    const qr = qrcode(0, "M");
    qr.addData(url);
    qr.make();
    byId("joinQr").innerHTML = qr.createSvgTag({ cellSize: 6, margin: 2, scalable: true });
  } catch (e) {
    byId("joinQr").textContent = "No QR code: web/qrcode.js is missing.";
  }
}

let lastLobby = "";

function renderLobby(m) {
  byId("start").disabled = !m.canStart;
  const lobby = JSON.stringify([m.players, m.roles]);
  if (lobby === lastLobby || byId("players").contains(document.activeElement)) return;
  lastLobby = lobby;
  byId("players").innerHTML = m.players.map(p => `
    <tr><td>${escapeHtml(p.name)}</td><td><select data-player="${escapeHtml(p.name)}">
      <option disabled ${m.roles.includes(p.role) ? "" : "selected"}>–</option>
      ${m.roles.map(r => `<option ${r === p.role ? "selected" : ""}>${r}</option>`).join("")}
    </select></td></tr>`).join("");
  byId("players").querySelectorAll("select").forEach(s =>
    s.onchange = () => { send({ type: "gmAssignRole", player: s.dataset.player, role: s.value }); s.blur(); });
}

function renderGame(s) {
  const lobby = s.phase === "lobby";
  byId("start").classList.toggle("hidden", !lobby);
  byId("round").textContent = lobby ? "" : `Round ${s.round} / ${s.maxRounds}`;
  byId("phase").textContent = (PHASES[s.phase] || s.phase) + (s.tourists ? ` · ${s.tourists} tourists, ${s.guided} guided` : "")
    + (s.inspection && s.inspection.team ? ` · Guard on plot ${s.inspection.plot}: ${s.inspection.team} ${s.inspection.legal ? "legal" : `caught, fine ${s.inspection.fine}`}` : "");
  byId("proceed").classList.toggle("hidden", !NEXT[s.phase]);
  byId("proceed").textContent = NEXT[s.phase] || "";
  drawBoard(byId("boardBox"), s.board);
  byId("teams").innerHTML = "<tr><th>Team</th><th>Families</th><th>Cash</th><th>Debt</th><th>Educated</th></tr>" +
    (s.teams || []).map(t => `<tr><td style="color:${teamColor(t.color)}"><b>${t.color}</b></td>
      <td>${t.families}</td><td>${t.cash}</td><td>${t.debt}</td><td>${t.educated}</td></tr>`).join("");
}