// Herdr's prompt for "New tab" / "New space": an empty name gives a fixed number
// (like the TUI) instead of the automatic name that follows the running program.
// props.what: "tab" (default) or "space".
import Prompt from "./prompt.js";
import { run, props, closeOverlay, spaces } from "herdr";

export default class TabPrompt extends Prompt {
  submit() {
    const p = props();
    closeOverlay(p.overlay);
    const typed = this.text.trim();
    if (p.what === "space") {
      run("space.new", { name: typed || String(spaces().length + 1), tab: "1" });
    } else {
      const n = (spaces().find((s) => s.active)?.tabs?.length ?? 0) + 1;
      run("tab.new", { name: typed || String(n) });
    }
  }
}
