<#
.SYNOPSIS
Scaffold a new jQuery + Jest project for VS Code.

.DESCRIPTION
This script creates a beginner-friendly project template with:
- npm + Jest + jsdom + jQuery
- source and test starter files
- VS Code debug config for Jest
- extension recommendations for Jest by Orta
- git initialization + first commit

.USAGE
From this repository root:
  powershell -ExecutionPolicy Bypass -File .\scripts\scaffold-jquery-jest.ps1 -TargetDir my-jquery-app

If -TargetDir is omitted, the default is: my-jquery-app
#>

param(
    # Name of the folder to create for the new project.
    [string]$TargetDir = "my-jquery-app"
)

# Fail fast on non-terminating errors so problems are visible immediately.
$ErrorActionPreference = "Stop"

# Build an absolute project path based on current working directory.
$ProjectPath = Join-Path -Path (Get-Location) -ChildPath $TargetDir
Write-Host "Scaffolding project at: $ProjectPath"

# --- Guardrails -------------------------------------------------------------
# Create folder if it does not exist. -Force is safe here and avoids extra checks.
New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null

# Refuse to scaffold into a non-empty directory.
# This prevents accidental overwrite of existing work.
$existing = Get-ChildItem -Path $ProjectPath -Force
if ($existing.Count -gt 0) {
    Write-Error "Target directory is not empty: $ProjectPath`nChoose an empty folder or pass a different -TargetDir."
}

# Enter project directory so subsequent commands create files in the right location.
Set-Location -Path $ProjectPath

# --- npm setup --------------------------------------------------------------
# Initialize package.json with default values.
npm init -y

# Install test tooling and jQuery as dev dependencies.
# - jest: test runner
# - jest-environment-jsdom: browser-like DOM for tests
# - jquery: library under test
npm install --save-dev jest jest-environment-jsdom jquery

# Configure npm test script to run Jest.
npm pkg set scripts.test="jest"

# --- Project folders --------------------------------------------------------
# Keep source, docs, and VS Code settings organized and predictable.
New-Item -ItemType Directory -Path "src", ".vscode", "docs" -Force | Out-Null

# --- .gitignore -------------------------------------------------------------
# Exclude dependencies, generated output, and machine-local files from git.
@"
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
"@ | Set-Content -Path ".gitignore" -Encoding utf8

# --- VS Code launch config --------------------------------------------------
# Add a ready-to-run debugger profile for Jest so users can press F5.
@"
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Jest Tests",
      "program": "`${workspaceFolder}/node_modules/jest/bin/jest.js",
      "args": ["--runInBand", "--env=jsdom"],
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "disableOptimizations": true
    }
  ]
}
"@ | Set-Content -Path ".vscode/launch.json" -Encoding utf8

# Recommend VS Code extensions so teammates are prompted consistently.
@"
{
  "recommendations": ["Orta.vscode-jest"]
}
"@ | Set-Content -Path ".vscode/extensions.json" -Encoding utf8

# --- Starter source file ----------------------------------------------------
# Provide a minimal module with UI + pure logic sections for learning and testing.
@"
`$(document).ready(function () {
  UserDashboard.init();
});

const UserDashboard = {
  selectors: {
    saveButton: '#save-profile-btn',
    statusMessage: '#status-text'
  },

  init: function () {
    `$(this.selectors.saveButton).on('click', () => this.handleSave());
  },

  handleSave: function () {
    const message = this.businessLogic.generateWelcome('Alex');
    this.updateUI(message);
  },

  updateUI: function (text) {
    `$(this.selectors.statusMessage).text(text).fadeIn();
  },

  businessLogic: {
    generateWelcome: function (name) {
      if (!name) {
        return 'Welcome, Guest!';
      }
      return ``Welcome back, `${name}!``;
    }
  }
};

if (typeof module !== 'undefined' && module.exports) {
  module.exports = UserDashboard;
}
"@ | Set-Content -Path "src/dashboard.js" -Encoding utf8

# --- Starter test file ------------------------------------------------------
# Use jsdom so jQuery selectors and DOM methods work under Jest.
@"
/**
 * @jest-environment jsdom
 */
const `$ = require('jquery');
global.`$ = global.jQuery = `$;

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

    const statusDiv = `$('#status-text');
    expect(statusDiv.text()).toBe('Test Success!');
    expect(statusDiv.css('display')).not.toBe('none');
  });
});
"@ | Set-Content -Path "src/dashboard.test.js" -Encoding utf8

# --- Starter docs -----------------------------------------------------------
@"
# jQuery + Jest Starter

## Install
npm install

## Test
npm test

## Debug in VS Code
Use Run and Debug and choose "Debug Jest Tests".
"@ | Set-Content -Path "README.md" -Encoding utf8

@"
# Setup Notes

Use this folder for onboarding docs, architecture notes, and team conventions.
"@ | Set-Content -Path "docs/setup.md" -Encoding utf8

# --- Git setup --------------------------------------------------------------
# Start version control immediately so users can checkpoint changes from day one.
git init
git add .

# Commit may fail if git identity is not configured; handle this gracefully.
try {
    git commit -m "Initial jQuery + Jest scaffold" | Out-Null
    Write-Host "Created initial commit."
}
catch {
    Write-Warning "Skipping commit: set git user.name and user.email, then commit manually."
}

# --- VS Code extension install ---------------------------------------------
# Try to auto-install Jest extension via VS Code CLI if available.
$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if ($null -ne $codeCmd) {
    try {
        code --install-extension Orta.vscode-jest --force | Out-Null
        Write-Host "Installed VS Code extension: Orta.vscode-jest"
    }
    catch {
        Write-Warning "Could not install Orta.vscode-jest automatically. Install it from Extensions view if needed."
    }
}
else {
    Write-Warning "VS Code CLI 'code' not found on PATH; skipping extension install."
    Write-Host "Manual command: code --install-extension Orta.vscode-jest"
}

Write-Host "Done. Next steps:"
Write-Host "1) cd $TargetDir"
Write-Host "2) npm test"
Write-Host "3) Open the folder in VS Code and press F5 to debug tests"
