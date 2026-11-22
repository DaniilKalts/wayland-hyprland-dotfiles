// Herdr's toast, but when the window isn't active (another Hyprland workspace,
// another app focused) the notification goes to the desktop via notify-send.
import Toast from "./toast.js";
import { props, closeOverlay, exec, window } from "herdr";

const ROOT = "/home/gopher/.config/herdr-app/";
// The notification's own icon, else an agent icon whose name appears in the title/body.
const AGENTS = ["claude", "codex", "gemini", "cursor", "copilot", "amp", "opencode", "crush", "droid"];
function iconFor(n) {
  const abs = (p) => (p.startsWith("/") ? p : ROOT + p);
  if (n.icon) return abs(n.icon);
  const text = `${n.title ?? ""} ${n.body ?? ""}`.toLowerCase();
  const hit = AGENTS.find((a) => new RegExp(`\\b${a}\\b`).test(text));
  return hit ? abs(`icons/${hit}.svg`) : abs("icons/agent.svg");
}

const URGENCY = { error: "critical", warning: "normal", success: "normal", info: "low" };

export default class ToastDesktop extends Toast {
  init(p, cx) {
    super.init?.(p, cx);
    this.desktop = !window()?.active;
    if (this.desktop) {
      const n = props() ?? {};
      const args = ["-a", "Herdr", "-u", URGENCY[n.level] ?? "normal"];
      const icon = iconFor(n);
      if (icon) args.push("-i", icon);
      if (n.timeout) args.push("-t", String(n.timeout));
      args.push(n.title ?? "Herdr");
      if (n.body) args.push(n.body);
      exec("notify-send", args).catch(() => {});
      closeOverlay(n.overlay);
    }
  }
}
