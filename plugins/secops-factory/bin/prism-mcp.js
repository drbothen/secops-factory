#!/usr/bin/env node
// prism-mcp.js — cross-platform MCP stdio launcher for the Prism binary.
//
// Resolves `prism` (macOS/Linux) or `prism.exe` (Windows) from the
// CLAUDE_PLUGIN_DATA directory and spawns it with the project config dir,
// forwarding stdio so Claude Code can communicate over MCP JSON-RPC.
//
// RUST_LOG=off is mandatory: Rust tracing JSON written to stdout would
// corrupt the MCP JSON-RPC framing (see prism-integration-handoff-brief.md §2.1).
//
// If the binary is missing, exit 1 with a clear remediation message pointing
// to the `activate` skill.
'use strict';

const { spawn } = require('child_process');
const path = require('path');
const os = require('os');

const dataDir = process.env.CLAUDE_PLUGIN_DATA;
if (!dataDir) {
  process.stderr.write(
    'prism-mcp: CLAUDE_PLUGIN_DATA is not set.\n' +
    'Run the `activate` skill (/secops-factory:activate) to set up the plugin environment.\n'
  );
  process.exit(1);
}

const binName = os.platform() === 'win32' ? 'prism.exe' : 'prism';
const bin = path.join(dataDir, binName);

// Verify the binary exists before spawning.
const fs = require('fs');
if (!fs.existsSync(bin)) {
  process.stderr.write(
    `prism-mcp: Prism binary not found at ${bin}\n` +
    'Run the `activate` skill (/secops-factory:activate) to download the correct\n' +
    `Prism build for your platform (${os.platform()}/${os.arch()}) into CLAUDE_PLUGIN_DATA.\n`
  );
  process.exit(1);
}

const projectDir = process.env.CLAUDE_PROJECT_DIR;
if (!projectDir) {
  process.stderr.write(
    'prism-mcp: CLAUDE_PROJECT_DIR is not set.\n' +
    'Ensure direnv has loaded the .envrc for this project before launching Claude Code.\n'
  );
  process.exit(1);
}

const configDir = path.join(projectDir, '.secops', 'prism');

const child = spawn(bin, ['--config-dir', configDir, 'start'], {
  stdio: 'inherit',
  env: { ...process.env, RUST_LOG: 'off' }
});

child.on('error', (err) => {
  process.stderr.write(
    `prism-mcp: Failed to launch Prism binary: ${err.message}\n` +
    'Run the `activate` skill (/secops-factory:activate) to re-download the binary.\n'
  );
  process.exit(1);
});

child.on('exit', (code, signal) => {
  process.exit(code !== null ? code : 1);
});
