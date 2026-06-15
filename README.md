# jQuery Unit Test Project (Jest + jsdom)

This project demonstrates how to unit test jQuery-based code with Jest in a Node environment.

Instead of opening a real browser, tests run in **jsdom** (a virtual DOM). That lets you test:

- pure business logic
- DOM updates
- jQuery event behavior

## Quick Start

1. Install dependencies:

   npm install

2. Run tests:

   npm test

3. Debug tests in VS Code:
   - Open the Run and Debug panel
   - Select Debug Jest Tests
   - Press F5

## Scaffold Scripts

Yes, the scaffold scripts are in the [scripts](scripts) directory.

- Bash (Git Bash / WSL): [scripts/scaffold-jquery-jest.sh](scripts/scaffold-jquery-jest.sh)
- PowerShell (Windows): [scripts/scaffold-jquery-jest.ps1](scripts/scaffold-jquery-jest.ps1)

Use one of these commands from the project root:

```bash
bash scripts/scaffold-jquery-jest.sh my-jquery-app
```

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\scaffold-jquery-jest.ps1 -TargetDir my-jquery-app
```

What the scaffold scripts do:

1. Create a new project folder safely (must be empty).
2. Initialize npm and install Jest + jsdom + jQuery.
3. Create starter folders/files (`src`, `.vscode`, `docs`, tests, README).
4. Add debugger config and VS Code extension recommendation.
5. Initialize git and attempt an initial commit.
6. Attempt to install the Jest extension (`Orta.vscode-jest`) via VS Code CLI.

## What This Project Does

The dashboard module in `src/dashboard.js`:

- waits for the DOM to load with `$(document).ready(...)`
- initializes UI behavior through a `UserDashboard` module object
- handles a save action (`handleSave`)
- updates the UI (`updateUI`) using jQuery
- keeps testable business logic in `businessLogic.generateWelcome(name)`

The test file in `src/dashboard.test.js` verifies:

- generated welcome text for known input
- DOM text update + visibility behavior after UI updates

## Project Structure

```text
jQueryUnitTestProject/
├── scripts/
│   ├── scaffold-jquery-jest.sh
│   └── scaffold-jquery-jest.ps1
├── .vscode/
│   └── launch.json
├── docs/
│   └── setup.md
├── src/
│   ├── dashboard.js
│   └── dashboard.test.js
├── .gitignore
├── package.json
└── README.md
```

## Prerequisites

- Node.js (LTS recommended)
- npm
- VS Code (for debugger workflow)

Optional but recommended VS Code extension:

- Jest by Orta: https://marketplace.visualstudio.com/items?itemName=Orta.vscode-jest

## Install Dependencies

If you need to reinstall dependencies:

```bash
npm install
```

The current project uses:

- `jest`
- `jest-environment-jsdom`
- `jquery`

## Run Tests

Run all tests once:

```bash
npm test
```

Run tests in watch mode:

```bash
npm test -- --watch
```

## Debug Tests in VS Code

This repo already includes a debug profile at `.vscode/launch.json` named **Debug Jest Tests**.

### Steps

1. Open `src/dashboard.js` and place a breakpoint (for example in `handleSave`).
2. Open `src/dashboard.test.js` and place another breakpoint in a test case.
3. Press **F5** (or open **Run and Debug** and select **Debug Jest Tests**).
4. Step through execution with **F10/F11**.

### Debug Config Notes

The launch profile runs Jest with:

- `--runInBand` (single process, easier to debug)
- `--env=jsdom` (browser-like DOM environment)

## Why jsdom Matters

jQuery manipulates the DOM. In normal Node.js there is no browser DOM, so tests would fail.

`@jest-environment jsdom` in the test file gives Jest a virtual browser environment so selectors, text updates, and display checks can be tested reliably.

## Learning Focus in This Repo

This setup is intentionally beginner-friendly and emphasizes:

- callback-based DOM-ready initialization
- module-style organization to reduce global scope pollution
- `const` usage for stable module references
- separation of business logic from DOM logic for easier testing

## Troubleshooting

If tests fail unexpectedly:

1. Ensure dependencies are installed (`npm install`).
2. Confirm `src/dashboard.js` exports `UserDashboard` for Jest.
3. Confirm test file includes `@jest-environment jsdom`.
4. Run `npm test` from the project root folder.
