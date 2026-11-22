// Ctrl-F: find an agent or a tab. Grouped under their space, same look as the
// sidebar. Every agent (sub-agents too) is its own row, named as the Agents
// list names it; tabs without an agent get one row each.
// Search: every word must match; name > program / tab / space > full title.
// Paths and user@host titles are never searched (they'd match everything).
// Everything is read live on each render and key press.

import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, ScrollHandle } from "gpui-base";
import { agents, panes, spaces, terminals, run, theme, props, closeOverlay, shared, setShared } from "herdr";

const MARK = { ansi6: "#22a99a", ansi3: "#e3814f", ansi4: "#5b8def", ansi5: "#8b7cf6", ansi2: "#3fae6a", ansi1: "#d9649a" };
const PROJECT_COLORS = ["ansi6", "ansi3", "ansi4", "ansi5", "ansi2", "ansi1"];

// Same space colors as the sidebar and picker (shared "space.colors").
function spaceColors() {
  const ids = new Set(spaces().map((p) => p.id));
  const kept = Object.fromEntries(Object.entries(shared("space.colors") ?? {}).filter(([id]) => ids.has(id)));
  let changed = Object.keys(kept).length !== Object.keys(shared("space.colors") ?? {}).length;
  for (const p of spaces()) {
    if (kept[p.id] || p.name === "~") continue;
    const uses = (c) => Object.values(kept).filter((v) => v === c).length;
    kept[p.id] = PROJECT_COLORS.reduce((best, c) => (uses(c) < uses(best) ? c : best));
    changed = true;
  }
  if (changed) setShared("space.colors", kept);
  return kept;
}
function spaceColor(t, p) {
  const c = spaceColors()[p.id] ?? "ansi6";
  return c.startsWith("#") ? c : (MARK[c] ?? t[c]);
}

// Names exactly as the tab bar and the Agents list show them (mods/tabs, mods/agents).
const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}\p{Ps}\p{Pi}]+/u, "").replace(/^\[ [!.] \] /, "").trim();
const isPath = (s) => /^[~/]|^[A-Za-z]:\\/.test((s ?? "").replace(/^[^\p{L}\p{N}~/]+/u, ""));
function telling(l) {
  const live = clean(l?.title);
  const prog = l?.program?.name;
  return live && live !== (l?.terminal ?? l?.address) && live !== prog && !isPath(l?.title) && !live.includes("@") && live.toLowerCase() !== l?.program?.key ? live : "";
}
// The tab bar's name for a tab (a tab without an agent shows its program).
function tabLabel(tab, lead) {
  const base = tab.named ? tab.name : lead?.program?.name ?? "Terminal";
  if (!lead?.program?.agent) return base;
  const live = telling(lead);
  return (tab.name === lead.program.name || !tab.named) && live ? live : base;
}
function title(tab, l) {
  const live = telling(l);
  return (tab.name === l?.program?.name || !tab.named) && live ? live : tab.name;
}

// How well `word` matches `text`, as a substring anywhere, ranked:
// whole > prefix > start of a later word > inside a word; 0 = no match.
// "her" finds "herdr" first, then "gopher".
function hit(text, word) {
  if (!text) return 0;
  const at = text.indexOf(word);
  if (at < 0) return 0;
  if (text === word) return 4;
  if (at === 0) return 3;
  for (let i = at; i > 0; i = text.indexOf(word, i + 1)) {
    if (/[\s\-_/.:()\[\]]/.test(text[i - 1])) return 2;
  }
  return 1;
}

const ROW = 32;
const HEAD = 30;
const GAP = 6; // extra space above every group after the first
const MAX_LIST = 360;

export default class FindTab extends View {
  init(_props, cx) {
    this.at = null;
    this.handle = cx.focus_handle();
    this.scroll = ScrollHandle.new();
    this.input = InputState.new({ placeholder: "Find an agent, tab or space…" });
    this.input.on("change", (_e, cx) => {
      this.at = 0;
      cx.notify();
    });
    this.input.on("submit", () => this.go(this.picks()[this.at ?? 0]));
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
  }

  rows() {
    const words = this.input.value().trim().toLowerCase().split(/[\s/]+/).filter(Boolean);
    const allPanes = panes();
    const allAgents = agents();
    const listed = new Set(allAgents.map((a) => a.address));
    // Sub-agents without a pane aren't in agents(): they come from terminals().
    const kids = terminals().filter((k) => k.parent && k.state === "live" && !listed.has(k.address));

    // Score one row against its own fields and its space's name. Every word must
    // hit one or the row is out. fields: [text, weight, shown?]; a hit only in a
    // hidden field becomes the row's note. `viaSpace` counts words only the space
    // name matched: rows that needed fewer of those win (see the filter below).
    const score = (fields, spaceName) => {
      let total = 0;
      let note = "";
      let viaSpace = 0;
      for (const word of words) {
        let best = 0;
        let from = null;
        for (const f of fields) {
          const v = hit((f[0] ?? "").toLowerCase(), word) * f[1];
          if (v > best) { best = v; from = f; }
        }
        if (!best) {
          const v = hit(spaceName.toLowerCase(), word) * 2;
          if (!v) return null;
          total += v;
          viaSpace++;
          continue;
        }
        total += best;
        if (!from[2] && !note) note = from[0];
      }
      return { total, note, viaSpace };
    };

    const found = [];
    for (const w of spaces()) {
      const items = [];
      for (const tab of w.tabs) {
        const inTab = allPanes.filter((p) => p.tab === tab.id);
        const lead = inTab.find((p) => p.program?.agent) ?? inTab.find((p) => p.terminal) ?? inTab[0];
        const tabName = tabLabel(tab, lead);
        const here = w.active && tab.active;
        const tabAgents = allAgents.filter((a) => a.tab === tab.id);
        const many = tabAgents.length > 1;

        if (!tabAgents.length) {
          const progs = [...new Set(inTab.map((p) => p.program?.name).filter(Boolean))];
          const titles = inTab.map((p) => telling(p)).filter(Boolean);
          const m = score([[tabName, 3, true], ...progs.map((n) => [n, 2, true]), ...titles.map((x) => [x, 1, false])], w.name);
          if (m) items.push({ kind: "pick", key: tab.id, w, tab, name: tabName, program: lead?.program, status: tab.status, here, ...m });
          continue;
        }

        const addAgent = (a, depth) => {
          const name = depth
            ? clean(a.name) || a.template || telling(a) || a.program?.name || a.address
            : (() => { const n = title(many ? { ...tab, named: false } : tab, many ? a : lead); return /^\d+$/.test(n) ? a.program?.name || n : n; })();
          const full = telling(a);
          const m = score([
            [name, 3, true],
            [a.program?.name, 2, true], [a.app, 2, true], [tab.named ? tab.name : "", 2, false],
            [full !== name ? full : "", 1, false],
          ], w.name);
          const st = depth ? (a.status === "error" ? "blocked" : a.status === "done" ? "idle" : a.status) : a.status;
          if (m) items.push({ kind: "pick", key: a.address, w, tab, agent: a, depth, name, program: a.program, status: st, here: here && (a.focused || !many), ...m });
          for (const k of kids.filter((k) => k.parent === a.address)) addAgent(k, depth + 1);
        };
        for (const a of tabAgents) addAgent(a, 0);
      }
      found.push({ w, items });
    }
    // "python" finds the Python tab, not every tab in a space named "...-python":
    // only rows that needed the space name least stay. "data" alone still lists the space.
    const least = Math.min(...found.flatMap((g) => g.items.map((x) => x.viaSpace)));
    const groups = [];
    for (const g of found) {
      const items = g.items.filter((x) => x.viaSpace === least);
      if (!items.length) continue;
      if (words.length) items.sort((a, b) => b.total - a.total);
      groups.push({ w: g.w, items, best: Math.max(...items.map((x) => x.total)) });
    }
    if (words.length) groups.sort((a, b) => b.best - a.best);
    const out = [];
    for (const g of groups) {
      out.push({ kind: "head", w: g.w, first: !out.length });
      out.push(...g.items);
    }
    return out;
  }

  picks() {
    return this.rows().filter((r) => r.kind === "pick");
  }

  close() {
    closeOverlay(props().overlay);
  }

  go(r) {
    if (!r) return;
    this.close();
    run("space.select", { id: r.w.id });
    run("tab.select", { id: r.tab.id });
    if (r.agent) run("agent.focus", { terminal: r.agent.address });
  }

  // The program's icon, as in the tab bar and sidebar.
  icon(t, p) {
    if (!p?.icon) return svg("mods/workspace-chrome/terminal.svg").size(14).flex_none().text_color(t.dim);
    return p.tint ? svg(p.icon).size(14).flex_none().text_color(t.muted) : image(p.icon).w(14).h(14).flex_none();
  }

  // The sidebar's status marks: spinner, "Needs you", done dot, idle ring.
  status(t, st) {
    if (st === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).mx(1).flex_none().text_color(t.working).spin(900);
    if (st === "blocked") return div().flex_none().px(6).h(18).rounded(5).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).flex().items_center().child("Needs you");
    if (st === "done") return div().size(7).mx(3).flex_none().rounded(4).bg(t.done ?? t.dim);
    if (st === "idle") return div().size(7).mx(3).flex_none().rounded(4).border(1.5).border_color(t.idle ?? t.dim);
    return null;
  }

  render() {
    const t = theme();
    const rows = this.rows();
    const picks = rows.filter((r) => r.kind === "pick");
    // Opens on where you are; typing selects the best match.
    if (this.at === null) this.at = Math.max(0, picks.findIndex((r) => r.here));
    this.at = Math.max(0, Math.min(this.at, picks.length - 1));
    const sel = picks[this.at];
    const total = rows.reduce((h, r) => h + (r.kind === "head" ? HEAD + (r.first ? 0 : GAP) : ROW), 0);

    const row = (r) => {
      if (r.kind === "head") {
        return h_flex().h(HEAD + (r.first ? 0 : GAP)).flex_none().px(14).pt(r.first ? 8 : 8 + GAP).gap(10).items_center()
          .text_size(11).font_semibold().text_color(t.dim)
          .child(h_flex().size(14).flex_none().rounded(4).bg(spaceColor(t, r.w)).items_center().justify_center()
            .text_size(9).font_bold().text_color("#ffffff").child([...r.w.name][0]?.toUpperCase() ?? "?"))
          .child(div().truncate().child(r.w.name))
          .when(Boolean(r.w.branch), (el) => el.child(div().flex_none().font_normal().child(r.w.branch)));
      }
      const here = r.here;
      const st = r.status;
      return h_flex().id(`ft-${r.key}`).h(ROW).flex_none().mx(4).px(10).pl(10 + (r.depth ?? 0) * 18).gap(10).items_center().rounded(7).cursor_pointer()
        .when(r === sel, (el) => el.bg(t.hover))
        .hover((s) => s.bg(t.hover))
        .on_click(() => this.go(r))
        .child(this.icon(t, r.program))
        .child(div().flex_1().min_w(0).truncate().text_color(here ? t.foreground : t.muted).when(here, (d) => d.font_semibold()).child(r.name))
        .when(Boolean(r.note), (el) => el.child(div().flex_none().max_w(200).truncate().text_size(11).text_color(t.dim).child(r.note)))
        .when(Boolean(st), (el) => el.child(this.status(t, st)));
    };

    const selIndex = rows.indexOf(sel);
    if (selIndex >= 0) this.scroll.scroll_to_item(selIndex);

    // The whole window: a dark backdrop (click it to close) with the card near the top.
    return v_flex().id("find-backdrop").track_focus(this.handle)
      .size_full().items_center().pt(90).bg("#00000080")
      .on_click(() => this.close())
      .on_key_down((e, cx) => {
        const n = this.picks().length;
        const down = e.key === "down" || (e.modifiers.control && (e.key === "n" || e.key === "j"));
        const up = e.key === "up" || (e.modifiers.control && (e.key === "p" || e.key === "k"));
        if (!n || (!down && !up)) return;
        this.at = ((this.at ?? 0) + (down ? 1 : -1) + n) % n;
        cx.stop_propagation();
        cx.notify();
      })
      .child(v_flex().id("find-card").w(560).max_w_full().min_h(0).p(14).gap(8)
      .bg(t.popover).text_size(13).text_color(t.foreground)
      .rounded(14).border_1().border_color(t.border).shadow_lg()
      .on_click((_e, cx) => cx.stop_propagation())
      .child(h_flex().h(36).flex_none().px(10).gap(8).items_center().rounded(9).border_1().border_color(t.accent).bg(t.background)
        .child(svg("mods/workspace-chrome/search.svg").size(15).text_color(t.dim))
        .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)))
      .child(picks.length
        ? v_flex().id("ft-list").h(Math.min(MAX_LIST, total)).min_h(0).overflow_y_scrollbar().track_scroll(this.scroll)
          .children(rows.map(row))
        : div().px(10).py(8).text_size(12).text_color(t.dim).child("Nothing matches")));
  }
}
