import { execFileSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

type ExtensionAPI = { on: (event: string, handler: (event: any, ctx: any) => any) => void };

const hooks = join(dirname(fileURLToPath(import.meta.url)), "..", "..", "..", "hooks");

function spawnHook(script: string, payload: Record<string, unknown>): string {
	try {
		return execFileSync(join(hooks, script), { input: JSON.stringify(payload), encoding: "utf8" }).trim();
	} catch {
		return "";
	}
}

function refusalIn(printed: string): string {
	try {
		return JSON.parse(printed)?.hookSpecificOutput?.permissionDecisionReason ?? "";
	} catch {
		return "";
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("before_file_write", async (event: any) => {
		const written = event?.new_string ?? event?.content ?? "";
		if (!written) return undefined;
		const reason = refusalIn(spawnHook("guard-tech-steps.sh", { tool_input: { new_string: written } }));
		return reason ? { permission: "deny", reason } : undefined;
	});
}
