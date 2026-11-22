// Shows "Copied to clipboard" when you copy from a terminal:
// - mouse selection (copy_on_select): once the clipboard actually changes
// - Ctrl+Shift+C / Ctrl+Insert: bound to "copy-toast.copy" in keys.json
import { View, div } from "gpui-kit";
import { focused, run, notify, nextCommand, panes, exec, openOverlay } from "herdr";

const key = (s) => (s ? `${s.start.row},${s.start.col}-${s.end.row},${s.end.col}` : null);
async function clip() {
  try {
    const r = await exec("wl-paste", ["-n", "-t", "text"], { timeout: 1000 });
    return r.code === 0 ? r.stdout : "";
  } catch { return null; }
}
const toast = () => notify({ title: "Copied to clipboard", level: "success", timeout: 1500 });

export default class CopyToast extends View {
  init(_props, cx) {
    // Mouse selections: Herdr copies on mouse release. While a selection exists,
    // watch the clipboard; once it changes, the copy really happened -> toast + clear.
    cx.spawn(async (cx) => {
      let before = null, term = null;
      for (;;) {
        await cx.sleep(150);
        const f = focused();
        if (!f?.terminal || !f.selection) { before = term = null; continue; }
        const now = await clip();
        if (term !== f.terminal || before === null) { term = f.terminal; before = now; continue; }
        if (now !== null && now !== before) {
          toast();
          run("terminal.clear_selection", { terminal: term });
          before = term = null;
        }
      }
    });
    // Keyboard copy.
    cx.spawn(async () => {
      for (;;) {
        const c = await nextCommand();
        if (c === "nextpane" || c === "prevpane") {
          const tab = focused()?.tab;
          const list = panes().filter((p) => p.tab === tab);
          const i = list.findIndex((p) => p.focused);
          const step = c === "nextpane" ? 1 : list.length - 1;
          if (list.length > 1) run("pane.focus", { pane: list[(i + step) % list.length].pane });
        }
        if (c === "spiral") {
          // Like ~/.local/bin/herdr-spiral-split.sh: split the newest (last) pane,
          // alternating right / down.
          const tab = focused()?.tab;
          const list = panes().filter((p) => p.tab === tab);
          if (list.length) run("pane.split", { pane: list[list.length - 1].pane, direction: list.length % 2 ? "right" : "down" });
        }
        if (c === "closetab") {
          // Ask before closing the tab (Herdr's own confirm dialog: Enter = yes, Esc = no).
          const tab = focused()?.tab;
          if (tab) openOverlay({
            mod: "confirm", kind: "dialog", width: 380, height: 150,
            props: { title: "Close tab?", detail: "Everything running in it will be closed.",
                     command: { name: "tab.close", args: { id: tab, confirmed: true } } },
          });
        }
        if (c === "closepane") {
          const pane = focused()?.pane;
          if (pane) openOverlay({
            mod: "confirm", kind: "dialog", width: 380, height: 150,
            props: { title: "Close pane?", detail: "What runs in it will be closed.",
                     command: { name: "pane.close", args: { pane } } },
          });
        }
        if (c === "newtab") {
          // Ask for the name first, then open the tab with it (Enter = create, Esc = cancel).
          openOverlay({
            mod: "tab-prompt", kind: "dialog", width: 420, height: 195,
            props: { title: "New tab", label: "Name", value: "", command: { name: "tab.new", args: {} } },
          });
        }
        if (c === "newspace") {
          openOverlay({
            mod: "tab-prompt", kind: "dialog", width: 420, height: 195,
            props: { title: "New space", what: "space", value: "", command: { name: "space.new", args: {} } },
          });
        }
        if (c === "palette") {
          // Herdr's palette design with a strict search (mods/my-palette).
          openOverlay({ mod: "my-palette", kind: "dialog", width: 640, height: 460 });
        }
        if (c === "copy") { const f = focused(); run("terminal.copy"); if (f?.selection) { toast(); run("terminal.clear_selection", { terminal: f.terminal }); } }
      }
    });
  }
  render() { return div().size_full(); }
}
