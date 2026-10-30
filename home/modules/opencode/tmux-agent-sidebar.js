import { spawn } from "node:child_process";

// Run in the TUI, never the shared server: TMUX_PANE belongs to the client.
// Invoke the Nix binary directly, independent of PATH.
const dispatch = (name, payload) => new Promise((resolve) => {
  try {
    const child = spawn("@sidebarBinary@", ["hook", "opencode", name], {
      stdio: ["pipe", "ignore", "ignore"],
      timeout: 3000,
    });
    child.on("error", () => {
      console.warn("tmux-agent-sidebar: could not start hook");
      resolve();
    });
    child.on("close", (code) => {
      if (code !== 0) console.warn("tmux-agent-sidebar: hook failed");
      resolve();
    });
    child.stdin.on("error", () => {});
    child.stdin.end(JSON.stringify(payload));
  } catch {
    console.warn("tmux-agent-sidebar: could not send hook");
    resolve();
  }
});

const textContent = (content) => typeof content === "string" ? content :
  (content ?? []).filter((part) => part.type === "text").map((part) => part.text).join("\n");

// A plain definition is accepted by V2; no runtime npm dependency is needed.
export const createPlugin = (send = dispatch, env = process.env, schedule = setInterval) => ({
  id: "tmux-agent-sidebar",
  setup(ctx) {
    if (!env.TMUX || !env.TMUX_PANE) return;
    let selected;
    let queue = Promise.resolve();
    const tools = new Map();
    const emit = (name, sessionID, extra = {}) => {
      const session = ctx.data.session.get(sessionID);
      const cwd = session?.location?.directory ?? ctx.location?.directory ?? ctx.data.location.default().directory;
      queue = queue.then(() => send(name, { cwd, session_id: sessionID, ...extra }))
        .catch(() => console.warn("tmux-agent-sidebar: could not send hook"));
      return queue;
    };
    const sync = () => {
      const route = ctx.ui.router.current();
      const sessionID = route.type === "session" ? route.sessionID : undefined;
      if (sessionID === selected) return;
      selected = sessionID;
      tools.clear();
      if (!selected) return;
      emit("session-start", selected, { source: "resume" });
      if (ctx.data.session.status(selected) === "running") {
        emit("user-prompt-submit", selected, { prompt: "" });
      }
    };
    sync();
    // router.current is reactive, but polling avoids a Solid runtime dependency.
    const timer = schedule(sync, 500);
    const unsubscribe = ctx.data.listen(({ details: event }) => {
      sync();
      const data = event.data;
      if (!selected || data?.sessionID !== selected) return;
      switch (event.type) {
        case "session.execution.started":
          emit("user-prompt-submit", selected, { prompt: "" });
          break;
        case "session.execution.succeeded":
        case "session.execution.interrupted":
          emit("stop", selected, { last_message: "" });
          break;
        case "session.execution.failed":
          emit("stop-failure", selected, { error: data.error?.message ?? "Session failed" });
          break;
        case "permission.asked":
          emit("notification", selected, { wait_reason: "permission" });
          break;
        case "session.tool.input.started":
          tools.set(data.id, { name: data.name });
          break;
        case "session.tool.called":
          tools.set(data.id, { ...tools.get(data.id), input: data.input });
          break;
        case "session.tool.success":
        case "session.tool.failed": {
          const tool = tools.get(data.id);
          tools.delete(data.id);
          if (!tool?.name) break;
          emit("activity-log", selected, {
            tool_name: tool.name, tool_input: tool.input ?? {},
            tool_response: {
              title: data.metadata?.title ?? "",
              output: event.type === "session.tool.success" ? textContent(data.content) : (data.error?.message ?? "Tool failed"),
              metadata: data.metadata ?? null,
            },
          });
          break;
        }
      }
    });
    return async () => {
      clearInterval(timer);
      unsubscribe();
      await queue;
    };
  },
});

export default createPlugin();
