import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const source = await readFile(new URL("../home/modules/opencode/tmux-agent-sidebar.js", import.meta.url), "utf8");
const { default: plugin, createPlugin } = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`);

function harness(env = { TMUX: "/socket", TMUX_PANE: "%4" }) {
  const calls = [];
  let route = { type: "session", sessionID: "ses_1" };
  let listener;
  let tick;
  let stopped = false;
  const cleanup = createPlugin(async (name, payload) => calls.push({ name, payload }), env,
    (fn) => { tick = fn; }).setup({
    location: { directory: "/project" },
    ui: { router: { current: () => route } },
    data: {
      session: { get: () => ({ location: { directory: "/project" } }), status: () => "running" },
      listen(fn) { listener = fn; return () => { stopped = true; }; },
    },
  });
  return {
    calls, cleanup, stopped: () => stopped,
    event(type, data) { listener({ details: { type, data } }); },
    switch(sessionID) { route = { type: "session", sessionID }; tick(); },
  };
}

test("TUI hydrates an existing session without waiting for a new prompt", async () => {
  assert.equal(plugin.id, "tmux-agent-sidebar");
  const h = harness();
  await h.cleanup();
  assert.deepEqual(h.calls, [
    { name: "session-start", payload: { cwd: "/project", session_id: "ses_1", source: "resume" } },
    { name: "user-prompt-submit", payload: { cwd: "/project", session_id: "ses_1", prompt: "" } },
  ]);
  assert.equal(h.stopped(), true);
});

test("ignores other TUI sessions, follows session switches, and maps V2 events", async () => {
  const h = harness();
  h.event("session.execution.failed", { sessionID: "other", error: { message: "ignore" } });
  h.event("permission.asked", { sessionID: "ses_1" });
  h.event("session.execution.succeeded", { sessionID: "ses_1" });
  h.switch("ses_2");
  h.event("session.execution.started", { sessionID: "ses_1" });
  h.event("session.execution.failed", { sessionID: "ses_2", error: { message: "offline" } });
  await h.cleanup();
  assert.deepEqual(h.calls.map((c) => c.name), [
    "session-start", "user-prompt-submit", "notification", "stop", "session-start", "user-prompt-submit", "stop-failure",
  ]);
  assert.equal(h.calls.at(-1).payload.error, "offline");
  assert.equal(h.calls.at(-1).payload.session_id, "ses_2");
});

test("maps terminal tool events to activity logs", async () => {
  const h = harness();
  const ref = { sessionID: "ses_1", id: "call_1" };
  h.event("session.tool.input.started", { ...ref, name: "read" });
  h.event("session.tool.called", { ...ref, input: { path: "a" } });
  h.event("session.tool.success", { ...ref, content: [{ type: "text", text: "one" }, { type: "file", uri: "x" }, { type: "text", text: "two" }] });
  await h.cleanup();
  assert.deepEqual(h.calls.at(-1), {
    name: "activity-log", payload: { cwd: "/project", session_id: "ses_1", tool_name: "read", tool_input: { path: "a" },
      tool_response: { title: "", output: "one\ntwo", metadata: null } },
  });
});

test("outside tmux registers no listeners and emits nothing", () => {
  const h = harness({});
  assert.equal(h.cleanup, undefined);
  assert.deepEqual(h.calls, []);
});
