let send = null;
let state = null;
let cart = [];
let sent = "";
let selectedPlot = 0;
let lastPhase = "";
let chosen = [];
let sell = {};

const FOOD = ["chicken", "gathering", "hunting", "vegetables"];
const WOOD = ["householdWood", "importedWood", "lowWood", "highWood"];
const HELP = {
  ready: "The game master will start the round.",
  park: "The park manager is creating the park. Wait.",
  activities: "Tap a plot, choose an activity for one family, then send your cards.",
  guard: "The forest guard is checking. Wait.",
  market: "Choose what you sell and how many families get health and education, then send.",
  results: "Here is what happened this decade.",
  ended: "The game is over."
};

const show = (text, kind = "info") => { byId("msg").className = kind; byId("msg").textContent = text; };

byId("login").addEventListener("submit", ev => {
  ev.preventDefault();
  const name = byId("name").value.trim();
  if (name.length < 2) return;
  send = connectToGame(name, onMessage, ok => byId("connection").className = "dot " + (ok ? "on" : "off"));
  byId("login").classList.add("hidden");
  byId("game").classList.remove("hidden");
});

function onMessage(m) {
  if (m.type === "rejected") show("This name is already used by another phone.", "error");
  if (m.type === "state") onState(m);
}

function onState(s) {
  state = s;
  if (s.phase !== lastPhase) { cart = []; chosen = []; sell = {}; sent = ""; selectedPlot = 0; lastPhase = s.phase; show(""); }
  const team = s.community;
  byId("team").textContent = team ? team.color + " team" : (s.parkManager ? "Park manager" : "No team yet");
  byId("team").style.color = team ? teamColor(team.color) : "";
  byId("round").textContent = s.phase === "lobby" ? "" : `Round ${s.round} / ${s.maxRounds}` + (s.tourists ? ` · ${s.tourists} tourists` : "");
  byId("phase").textContent = PHASES[s.phase] || s.phase;
  refresh();
}

function refresh() {
  if (state.parkManager) return renderParkManager();
  renderCounters(); renderBoard(); renderPanel();
}
function familiesLeft() { return state.community.families - cart.length; }
function cashLeft() { return state.community.cash - cart.reduce((sum, c) => sum + c.cost, 0); }
function price(n) { return n === 0 ? "free" : `${n} dobra${n > 1 ? "s" : ""}`; }
function total(list, stock) { return list.reduce((sum, k) => sum + (stock[k] || 0), 0); }

function renderCounters() {
  const t = state.community;
  if (!t) { byId("counters").innerHTML = ""; return; }
  const activities = state.phase === "activities";
  const free = activities ? familiesLeft() : t.families;
  byId("counters").innerHTML = [
    ["Families", `<span class="pawns">${"●".repeat(free)}<i>${"●".repeat(t.families - free)}</i></span>`],
    ["Cash", activities ? cashLeft() : t.cash],
    ["Debt", t.debt],
    ["Educated", t.educated]
  ].map(([k, v]) => `<div><span>${k}</span><b>${v}</b></div>`).join("");
}

function renderBoard() {
  const marks = {};
  cart.forEach(c => marks[c.plot] = ACTIVITY_LETTERS[c.code]);
  drawBoard(byId("boardBox"), state.board, {
    marks,
    selectable: new Set((state.options || []).map(o => o.plot).concat(cart.map(c => c.plot))),
    selected: selectedPlot,
    onClick: c => { selectedPlot = c.id; refresh(); }
  });
}

function renderPanel() {
  const panel = byId("panel");
  if (!state.community) panel.innerHTML = "<p>Wait for the game master to put you in a team.</p>";
  else if (state.phase === "activities") renderActivities(panel);
  else if (state.phase === "market") renderMarket(panel);
  else if (state.phase === "results" || state.phase === "ended") renderResults(panel);
  else panel.innerHTML = `<p class="help">${HELP[state.phase] || "Wait for the game master."}</p>`;
}

function sendBar(label, value) {
  const changed = JSON.stringify(value) !== sent;
  return `<div class="sendbar"><span class="${changed ? "todo" : "done"}">${changed ? "Not sent yet" : "Sent ✓"}</span>
    <button id="send" class="primary" ${changed ? "" : "disabled"}>${label}</button></div>`;
}

function cardsToSend() {
  return cart.map(c => ({ plot: c.plot, code: c.code, permit: c.permit === true }));
}

function huntingHtml(report) {
  const hunts = (report && report.hunting) || [];
  return hunts.length
    ? "<h2>Hunting</h2>" + hunts.map(h => `<p>Plot ${h.plot}: the die gave <b>${h.animals}</b> animal${h.animals === 1 ? "" : "s"}.</p>`).join("")
    : "";
}

function renderActivities(panel) {
  const plot = state.board.find(c => c.id === selectedPlot);
  const here = state.options.filter(o => o.plot === selectedPlot);
  const inTown = here.some(o => o.code === "motoTaxi");
  const placed = cart.map((c, i) => [c, i]).filter(([c]) => c.plot === selectedPlot);
  const can = cost => familiesLeft() > 0 && cashLeft() >= cost;
  const why = cost => familiesLeft() === 0 ? "no family left" : `needs ${price(cost)}`;
  const button = (attrs, label, cost) => `<button class="option" ${attrs} ${can(cost) ? "" : "disabled"}>
    <span>${label}</span><small>${can(cost) ? price(cost) : why(cost)}</small></button>`;
  let html = `<p class="help">${HELP.activities}</p>`;
  if (plot) {
    const trees = plot.low + plot.high;
    html += `<h2>Plot ${plot.id} · ${COVER_NAMES[plot.cover] || ""}${trees ? ` · ${trees} tree${trees > 1 ? "s" : ""}` : ""}${plot.elevation ? ` · +${plot.elevation}` : ""}</h2>`;
    html += placed.map(([c, i]) => `<div class="placed"><b>${c.label}</b> (${price(c.cost)}) <button data-remove="${i}">Remove</button></div>`).join("");
    const hasGuide = placed.some(([c]) => c.code === "ecoGuide");
    const hasMain = placed.some(([c]) => c.code !== "ecoGuide");
    const shown = inTown ? here : here.filter(o => o.code === "ecoGuide" ? !hasGuide : !hasMain);
    if (shown.length || !placed.length) {
      html += shown.map(o => o.code === "hunting"
        ? `<div class="option">Hunting – the die decides the animals <small>${price(o.cost)}</small><div class="choices">
            <button data-hunt ${can(o.cost) ? "" : "disabled"}>Randomize</button></div></div>`
        : o.permit === undefined
          ? button(`data-code="${o.code}"`, o.label, o.cost)
          : button(`data-code="${o.code}" data-permit="${o.permit}"`, `${o.label} with permit`, o.cost + o.permit)
            + button(`data-code="${o.code}"`, `${o.label} without permit`, o.cost)).join("")
        || "<p>Nothing your team can do here.</p>";
    }
  }
  html += `<h2>Your cards (${cart.length})</h2>` + (cart.length
    ? "<ul class='cart'>" + cart.map((c, i) => `<li>${c.label} · plot ${c.plot} · ${price(c.cost)} <button data-remove="${i}">✕</button></li>`).join("") + "</ul>"
    : "<p>No card yet.</p>");
  html += sendBar("Send my cards", cardsToSend());
  panel.innerHTML = html;
  const add = card => { cart.push(card); refresh(); };
  panel.querySelectorAll("[data-remove]").forEach(b => b.onclick = () => { cart.splice(+b.dataset.remove, 1); refresh(); });
  panel.querySelectorAll("[data-code]").forEach(b => b.onclick = () => {
    const card = Object.assign({}, here.find(o => o.code === b.dataset.code), { permit: false });
    if (b.dataset.permit) { card.permit = true; card.cost += +b.dataset.permit; card.label += " (permit)"; }
    add(card);
  });
  panel.querySelectorAll("[data-hunt]").forEach(b => b.onclick = () => {
    const card = Object.assign({}, here.find(o => o.code === "hunting"), { permit: false });
    card.label = "Hunting (random)";
    add(card);
  });
  byId("send").onclick = () => {
    send({ type: "submit", value: cardsToSend() });
    sent = JSON.stringify(cardsToSend());
    show("Sent. You can still change and send again until the game master closes the turn.", "ok");
    refresh();
  };
}

function renderMarket(panel) {
  const t = state.community;
  const items = Object.keys(state.prices).filter(k => k !== "cocoa" && t.stock[k] > 0);
  const health = sell.health || 0;
  const after = Object.assign({}, t.stock);
  items.forEach(k => after[k] -= sell[k] || 0);
  const cash = t.cash + (t.stock.cocoa || 0) * state.prices.cocoa
    + items.reduce((sum, k) => sum + (sell[k] || 0) * state.prices[k], 0);
  const food = total(FOOD, after);
  const wood = total(WOOD, after);
  const value = { sell: Object.fromEntries(items.map(k => [k, sell[k] || 0])), health };
  const stepper = (key, max) => `<div class="stepper"><button data-step="${key}" data-by="-1" ${(sell[key] || 0) > 0 ? "" : "disabled"}>−</button>
    <b>${sell[key] || 0}</b><button data-step="${key}" data-by="1" ${(sell[key] || 0) < max ? "" : "disabled"}>+</button></div>`;
  panel.innerHTML = `
    <p class="help">${HELP.market}</p>
    <div class="needs">
      <div class="${food >= t.foodNeed ? "ok" : "short"}"><span>Food</span><b>${food} / ${t.foodNeed}</b></div>
      <div class="${wood >= t.woodNeed ? "ok" : "short"}"><span>Wood</span><b>${wood} / ${t.woodNeed}</b></div>
      <div><span>Cash after sales</span><b>${cash}</b></div>
    </div>
    ${huntingHtml(t.report)}
    ${t.stock.cocoa ? `<p>Your ${t.stock.cocoa} cocoa will be sold for ${t.stock.cocoa * state.prices.cocoa}.</p>` : ""}
    ${food < t.foodNeed || wood < t.woodNeed ? "<p class='warn'>What is missing will be bought automatically, with a loan if needed.</p>" : ""}
    <h2>Sell</h2>
    ${items.length ? items.map(k => `<div class="row"><span>${RESOURCE_NAMES[k]} <small>${t.stock[k]} in stock · ${price(state.prices[k])} each</small></span>
      ${stepper(k, t.stock[k])}</div>`).join("") : "<p>Nothing else to sell.</p>"}
    <h2>Health and education</h2>
    <div class="row"><span>Families <small>1 dobra each, only if the needs are met</small></span>${stepper("health", t.families)}</div>
    ${sendBar("Send my choices", value)}`;
  panel.querySelectorAll("[data-step]").forEach(b => b.onclick = () => {
    sell[b.dataset.step] = (sell[b.dataset.step] || 0) + +b.dataset.by;
    renderMarket(panel);
  });
  byId("send").onclick = () => {
    send({ type: "submit", value });
    sent = JSON.stringify(value);
    show("Sent. You can still change and send again until the game master closes the market.", "ok");
    renderMarket(panel);
  };
}

function renderResults(panel) {
  const r = state.community.report;
  panel.innerHTML = `
    <h2>${state.phase === "ended" ? "Game over" : "Results"}</h2>
    <div class="needs">
      <div class="${r.needsMet ? "ok" : "short"}"><span>Needs</span><b>${r.needsMet ? "met ✔" : "not met ✘"}</b></div>
      <div><span>Loan</span><b>${r.loan ? "yes" : "no"}</b></div>
      <div><span>Health and education</span><b>${r.health || 0}</b></div>
    </div>
    ${r.controlled ? "<p class='warn'><b>The forest guard caught you: wood confiscated.</b></p>" : ""}
    ${huntingHtml(r)}
    <table>${Object.entries(state.community.stock).filter(([, v]) => v > 0)
      .map(([k, v]) => `<tr><td>${RESOURCE_NAMES[k]}</td><td>${v}</td></tr>`).join("")}</table>`;
}

const PARK_RULES = { hunting: "Hunting", gathering: "Gathering", householdWood: "Household wood", commercialWood: "Commercial wood" };

function renderParkManager() {
  const pm = state.parkManager;
  const guarding = state.phase === "guard";
  const allowed = new Set(state.board.filter(c => pm.canCreatePark
    ? c.cover !== "X" && c.cover !== "U"
    : guarding && (c.activity === "householdWood" || c.activity === "commercialWood")).map(c => c.id));
  const max = pm.canCreatePark ? 5 : 1;
  byId("counters").innerHTML = `<div><span>Caught this decade</span><b>${pm.caught}</b></div>`;
  const marks = {};
  chosen.forEach(id => marks[id] = pm.canCreatePark ? "P" : "G");
  drawBoard(byId("boardBox"), state.board, {
    marks, selectable: allowed,
    onClick: c => {
      if (!allowed.has(c.id)) return;
      chosen = chosen.includes(c.id) ? chosen.filter(id => id !== c.id) : chosen.concat([c.id]).slice(-max);
      renderParkManager();
    }
  });
  const panel = byId("panel");
  if (pm.canCreatePark) {
    panel.innerHTML = `<h2>Create the park</h2>
      <p class="help">Tap 5 plots, adjacent or not (${chosen.length} / 5 chosen), then choose what is forbidden inside.</p>
      ${Object.entries(PARK_RULES).map(([code, name]) => `<label class="check"><input type="checkbox" data-rule="${code}"> ${name} forbidden</label>`).join("")}
      <button id="send" class="primary" ${chosen.length === 5 ? "" : "disabled"}>Create the park</button>
      ${certificatesHtml(pm)}`;
    byId("send").onclick = () => {
      send({ type: "submit", value: { park: chosen, forbidden: [...panel.querySelectorAll("[data-rule]:checked")].map(i => i.dataset.rule) } });
      show("Park created.", "ok");
    };
    bindCertificates(panel);
  } else if (guarding) {
    panel.innerHTML = `<h2>Forest guard</h2>
      <p class="help">Tap one plot with logging (W = household wood, L = commercial wood). Without permit, or against the park rules, the wood is confiscated.</p>
      <label>Fine <input type="number" id="fine" min="0" max="10" value="0"></label>
      <button id="send" class="primary" ${chosen.length ? "" : "disabled"}>Send the guard</button>`;
    byId("send").onclick = () => {
      send({ type: "submit", value: { guard: chosen[0], fine: +byId("fine").value || 0 } });
      show("Sent. You can change until the game master moves on.", "ok");
    };
  } else {
    panel.innerHTML = state.round < 3
      ? "<p class='help'>You are the park manager. You no longer play with your community. You will create the park at the start of round 3.</p>"
      : `<p>Forbidden in the park: ${pm.forbidden.map(code => PARK_RULES[code]).join(", ") || "nothing"}.</p><p class="help">Wait for the game master.</p>`
        + certificatesHtml(pm);
    bindCertificates(panel);
  }
}

function certificatesHtml(pm) {
  if (!pm.canCertify) return "";
  return `<h2>Eco-guide certificates (${pm.certificatesLeft} left)</h2>
    <p class="help">1 dobra each, paid by the team. Prefer teams that invested in health and education.</p>
    ${pm.teams.map(t => `<div class="row"><span style="color:${teamColor(t.color)}"><b>${t.color}</b>
      <small>${t.educated} educated · ${t.cash} dobras · ${t.certificates} certificate${t.certificates === 1 ? "" : "s"}</small></span>
      <button data-certify="${t.color}" ${pm.certificatesLeft > 0 && t.cash >= 1 ? "" : "disabled"}>Give</button></div>`).join("")}`;
}

function bindCertificates(panel) {
  panel.querySelectorAll("[data-certify]").forEach(b => b.onclick = () => {
    send({ type: "submit", value: { certify: b.dataset.certify } });
    show(`Certificate given to the ${b.dataset.certify} team.`, "ok");
  });
}