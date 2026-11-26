const TEAM_COLORS = { blue: "#2B6CB0", green: "#2F855A", red: "#C53030", yellow: "#D69E2E" };
const COVER_COLORS = { F: "#E9D8A6", U: "#B8B8B8", P: "#1E5631", S: "#76B947", X: "#A9D6F5" };
const PHASES = {
  lobby: "Waiting for players",
  ready: "Round ready to start",
  park: "The park manager creates the park",
  activities: "Place your activities",
  guard: "The forest guard is checking",
  market: "Market",
  results: "Results of the round",
  ended: "Game over"
};
const ACTIVITY_LETTERS = { farming: "F", gathering: "G", hunting: "H", cocoa: "C", householdWood: "W", commercialWood: "L", motoTaxi: "M", skilledJob: "J", ecoGuide: "E" };
const COVER_NAMES = { F: "Farmland", U: "Town", P: "Primary forest", S: "Secondary forest" };
const RESOURCE_NAMES = {
  vegetables: "Vegetables", gathering: "Gathering", hunting: "Game meat", cocoa: "Cocoa",
  householdWood: "Household wood", lowWood: "Low value wood", highWood: "High value wood",
  chicken: "Chicken", importedWood: "Imported wood"
};

const byId = id => document.getElementById(id);
const SVG_NS = "http://www.w3.org/2000/svg";

function svg(tag, attrs, parent) {
  const el = document.createElementNS(SVG_NS, tag);
  Object.entries(attrs).forEach(([k, v]) => el.setAttribute(k, v));
  if (parent) parent.appendChild(el);
  return el;
}

function teamColor(name) {
  return TEAM_COLORS[name] || "#555";
}

function neighbours(c, cells) {
  const shift = c.row % 2 === 0 ? 0 : -1;
  const near = [[0, -1], [0, 1], [-1, shift], [-1, shift + 1], [1, shift], [1, shift + 1]];
  return cells.filter(n => near.some(([dr, dc]) => n.row === c.row + dr && n.col === c.col + dc));
}

function drawBoard(container, cells, options = {}) {
  const r = 30;
  const w = Math.sqrt(3) * r;
  const visible = cells.filter(c => c.cover !== "X" || c.coast);
  const centre = c => [w / 2 + (c.col - 1) * w + (c.row % 2 === 0 ? w / 2 : 0), r + (c.row - 1) * 1.5 * r];
  const xs = visible.map(c => centre(c)[0]);
  const ys = visible.map(c => centre(c)[1]);
  const left = Math.min(...xs) - w / 2 - 2;
  const top = Math.min(...ys) - r - 2;
  const root = svg("svg", {
    viewBox: `${left} ${top} ${Math.max(...xs) + w / 2 + 2 - left} ${Math.max(...ys) + r + 2 - top}`,
    class: "board"
  });
  const ground = svg("g", {}, root);
  const roads = svg("g", { class: "roads" }, root);
  const items = svg("g", {}, root);
  const corners = (x, y, s) => [0, 1, 2, 3, 4, 5]
    .map(i => { const a = Math.PI / 180 * (60 * i - 30); return `${x + s * Math.cos(a)},${y + s * Math.sin(a)}`; })
    .join(" ");

  const roadCells = cells.filter(c => c.road);
  roadCells.forEach(c => neighbours(c, roadCells).filter(n => n.id > c.id).forEach(n => {
    const [x1, y1] = centre(c);
    const [x2, y2] = centre(n);
    svg("line", { x1, y1, x2, y2 }, roads);
  }));

  visible.forEach(c => {
    const [x, y] = centre(c);
    const cell = svg("g", { class: "cell", "data-id": c.id }, ground);
    svg("polygon", {
      points: corners(x, y, r - 1),
      fill: COVER_COLORS[c.cover] || "#fff",
      stroke: c.owner ? teamColor(c.owner) : (c.cover === "X" ? "#A9D6F5" : "#888"),
      "stroke-width": c.owner ? 4 : 1
    }, cell);
    if (c.cover === "X") return;
    if (c.park) {
      svg("polygon", { points: corners(x, y, r - 6), fill: "none", stroke: "#000", "stroke-width": 1.5, "stroke-dasharray": "3 3" }, cell);
    }
    if (options.selectable && options.selectable.has(c.id)) cell.classList.add("selectable");
    if (options.selectable && options.selectable.size && !options.selectable.has(c.id)) cell.classList.add("dim");
    if (options.selected === c.id) cell.classList.add("selected");
    if (options.onClick) cell.addEventListener("click", () => options.onClick(c));

    const g = svg("g", { class: "items" }, items);
    const icon = (name, px, py, size) => svg("image", {
      href: `/icons/${name}.png`, width: size * w, height: size * w,
      x: x - w / 2 + px * w - size * w / 2, y: y - r + py * 2 * r - size * w / 2
    }, g);
    const slots = [[0.3, 0.55], [0.5, 0.55], [0.7, 0.55], [0.4, 0.78], [0.6, 0.78], [0.5, 0.32]];
    Array(c.low).fill("lowValueTree").concat(Array(c.high).fill("highValueTree")).forEach((name, i) => {
      const [px, py] = slots[Math.min(i, slots.length - 1)];
      icon(name, px, py, name === "lowValueTree" ? 0.2 : 0.26);
    });
    if (c.elevation > 0) icon("elevation" + c.elevation, 0.75, 0.28, 0.28);
    if (c.cocoa > 0) {
      svg("text", { x: x - 18, y: y - 8, class: "cocoa" }, g).textContent = "C" + c.cocoa;
    }
    if (c.activity) {
      svg("circle", { cx: x, cy: y, r: 9, fill: teamColor(c.activityTeam), stroke: "#fff", "stroke-width": 1.5 }, g);
      svg("text", { x: x, y: y + 4, class: "badge" }, g).textContent = ACTIVITY_LETTERS[c.activity] || "?";
    }
    (c.ecoGuides || []).forEach((team, i) => {
      svg("circle", { cx: x + 14 - i * 10, cy: y + 12, r: 6, fill: teamColor(team), stroke: "#fff", "stroke-width": 1.5 }, g);
      svg("text", { x: x + 14 - i * 10, y: y + 15, class: "badge small" }, g).textContent = "E";
    });
    if (options.marks && options.marks[c.id]) {
      svg("circle", { cx: x, cy: y, r: 10, fill: "#fff", stroke: "#000", "stroke-width": 2 }, g);
      svg("text", { x: x, y: y + 4, class: "badge dark" }, g).textContent = options.marks[c.id];
    }
  });
  container.replaceChildren(root);
}

function connectToGame(name, onMessage, onStatus) {
  let token = "";
  try {
    token = localStorage.getItem("dm.token") || Math.random().toString(36).slice(2);
    localStorage.setItem("dm.token", token);
  } catch (e) { token = Math.random().toString(36).slice(2); }
  let socket = null;
  let stopped = false;
  const open = () => {
    const proto = location.protocol === "https:" ? "wss" : "ws";
    socket = new WebSocket(`${proto}://${location.host}/ws`);
    socket.addEventListener("open", () => {
      socket.send(JSON.stringify({ type: "bonjour", name: name, token: token }));
      onStatus(true);
    });
    socket.addEventListener("message", ev => {
      let m;
      try { m = JSON.parse(ev.data); if (typeof m === "string") m = JSON.parse(m); } catch (e) { return; }
      if (m.type === "rejected" || m.type === "replaced") stopped = true;
      onMessage(m);
    });
    socket.addEventListener("close", () => {
      onStatus(false);
      if (!stopped) setTimeout(open, 1500);
    });
  };
  open();
  setInterval(() => send({ type: "ping" }), 20000);
  function send(message) {
    if (socket && socket.readyState === WebSocket.OPEN) socket.send(JSON.stringify(message));
  }
  return send;
}

function escapeHtml(text) {
  return String(text).replace(/[&<>"]/g, ch => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[ch]);
}