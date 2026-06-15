#!/usr/bin/env bash

# Exit immediately on errors, treat unset variables as errors,
# and fail pipelines when any command fails.
# This makes the script safer and easier to debug.
set -euo pipefail

# --- Usage -----------------------------------------------------------------
# Run with an optional folder name:
#   bash scripts/scaffold-jquery-jest.sh my-jquery-app
# If no name is provided, use a sensible default.
TARGET_DIR="${1:-my-jquery-app}"

# Resolve to an absolute path so status messages are clearer.
PROJECT_PATH="$(pwd)/${TARGET_DIR}"

echo "Scaffolding project at: ${PROJECT_PATH}"

# --- Guardrails -------------------------------------------------------------
# Create the directory if it does not exist.
mkdir -p "${PROJECT_PATH}"

# Refuse to continue if the target directory is not empty.
# This prevents accidental overwrite of an existing project.
if [[ -n "$(ls -A "${PROJECT_PATH}")" ]]; then
  echo "Error: ${PROJECT_PATH} is not empty."
  echo "Choose an empty folder or pass a different project name."
  exit 1
fi

# Move into the project folder so all generated files land in the right place.
cd "${PROJECT_PATH}"

# --- npm setup --------------------------------------------------------------
# Initialize package.json with defaults to make this script non-interactive.
npm init -y

# Install the tooling we need for jQuery unit testing in Node.
# - jest: test runner/assertion ecosystem
# - jest-environment-jsdom: browser-like DOM for tests
# - jquery: library under test
npm install --save-dev jest jest-environment-jsdom jquery

# Set the npm test script so "npm test" runs Jest directly.
# Using npm pkg keeps edits scriptable and avoids manual file editing.
npm pkg set scripts.test="jest"

# --- project folders --------------------------------------------------------
# Keep source code and VS Code settings organized.
mkdir -p src .vscode docs

# --- .gitignore -------------------------------------------------------------
# Ignore dependencies, generated outputs, and local machine artifacts.
cat > .gitignore <<'EOF'
# Dependencies
node_modules/

# Test output
coverage/
.nyc_output/

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Environment files
.env
.env.*
!.env.example

# OS files
.DS_Store
Thumbs.db

# Editor folders
.vscode/
.idea/

# Optional build artifacts
dist/
build/
EOF

# --- VS Code debug configuration -------------------------------------------
# Create a launch profile so F5 can run/debug Jest tests.
# Note: launch.json supports comments in VS Code JSONC files.
cat > .vscode/launch.json <<'EOF'
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Jest Tests",
      "program": "${workspaceFolder}/node_modules/jest/bin/jest.js",
      "args": ["--runInBand", "--env=jsdom"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "disableOptimizations": true
    }
  ]
}
EOF

# Recommend the Jest extension so teammates get a prompt in VS Code.
cat > .vscode/extensions.json <<'EOF'
{
  "recommendations": ["Orta.vscode-jest"]
}
EOF

# --- starter app code -------------------------------------------------------
# Minimal jQuery dashboard module with one UI action and pure logic.
cat > src/dashboard.js <<'EOF'
$(document).ready(function () {
  UserDashboard.init();
});

const UserDashboard = {
  selectors: {
    saveButton: '#save-profile-btn',
    statusMessage: '#status-text'
  },

  init: function () {
    $(this.selectors.saveButton).on('click', () => this.handleSave());
  },

  handleSave: function () {
    const message = this.businessLogic.generateWelcome('Alex');
    this.updateUI(message);
  },

  updateUI: function (text) {
    $(this.selectors.statusMessage).text(text).fadeIn();
  },

  businessLogic: {
    generateWelcome: function (name) {
      if (!name) {
        return 'Welcome, Guest!';
      }
      return `Welcome back, ${name}!`;
    }
  }
};

if (typeof module !== 'undefined' && module.exports) {
  module.exports = UserDashboard;
}
EOF

# Starter test file using jsdom so jQuery DOM calls work in Jest.
cat > src/dashboard.test.js <<'EOF'
/**
 * @jest-environment jsdom
 */
const $ = require('jquery');
global.$ = global.jQuery = $;

const UserDashboard = require('./dashboard');

describe('UserDashboard Test Suite', () => {
  test('generateWelcome returns custom string when name is provided', () => {
    const result = UserDashboard.businessLogic.generateWelcome('Alex');
    expect(result).toBe('Welcome back, Alex!');
  });

  test('updateUI should inject text and display the hidden div', () => {
    document.body.innerHTML = `
      <button id="save-profile-btn">Save</button>
      <div id="status-text" style="display:none;"></div>
    `;

    UserDashboard.updateUI('Test Success!');

    const statusDiv = $('#status-text');
    expect(statusDiv.text()).toBe('Test Success!');
    expect(statusDiv.css('display')).not.toBe('none');
  });
});
EOF

# Short setup guide for generated projects.
cat > README.md <<'EOF'
# jQuery + Jest Starter

## Install
npm install

## Test
npm test

## Debug in VS Code
Use Run and Debug and choose "Debug Jest Tests".
EOF

# Keep a placeholder in docs so the folder is visible in git from day one.
cat > docs/setup.md <<'EOF'
# Setup Notes

Use this folder for onboarding docs, architecture notes, and team conventions.
EOF

# --- git initialization -----------------------------------------------------
# Initialize git so the scaffold is immediately ready for version control.
git init

git add .

# Commit may fail if git user.name/user.email are not configured.
# We do not hard-fail the script for that case; we show a helpful message instead.
if git commit -m "Initial jQuery + Jest scaffold"; then
  echo "Created initial commit."
else
  echo "Skipping commit: set git user.name and user.email, then commit manually."
fi

# --- VS Code Jest extension -------------------------------------------------
# If VS Code CLI is available, install the Jest extension automatically.
# This is best-effort because some environments do not have the 'code' command on PATH.
if command -v code >/dev/null 2>&1; then
  if code --install-extension Orta.vscode-jest --force; then
    echo "Installed VS Code extension: Orta.vscode-jest"
  else
    echo "Could not install Orta.vscode-jest automatically."
    echo "You can install it manually from the Extensions marketplace."
  fi
else
  echo "VS Code CLI not found on PATH; skipping extension install."
  echo "You can install it manually or run: code --install-extension Orta.vscode-jest"
fi

echo "Done. Next steps:"
echo "1) cd ${TARGET_DIR}"
echo "2) npm test"
echo "3) Open the folder in VS Code and press F5 to debug tests"
