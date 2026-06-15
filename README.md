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

## Dashboard Test + jQuery-to-HTML Wiring (Beginner)

### How to run your dashboard Jest test

1. From the project root, run:

   ```bash
   npm test -- src/dashboard.test.js --watchAll=false
   ```

2. To run all tests:

   ```bash
   npm test
   ```

3. To keep tests re-running while you edit:

   ```bash
   npm test -- --watch
   ```

### How to debug the dashboard test in VS Code

1. Open `src/dashboard.test.js`.
2. Put a breakpoint on the test line you want to inspect.
3. Open the Run and Debug panel in VS Code.
4. Choose **Debug Jest Tests**.
5. Press **F5** to start the debugger.
6. Use **F10** to step over code and **F11** to step into code.
7. Watch variables, the call stack, and the test result as the debugger pauses.

### Where this is defined

1. Test script is in `package.json`.
2. Test file is `src/dashboard.test.js`.
3. Module under test is `src/dashboard.js`.

### How jQuery modules are packaged and tied to HTML pages

In this project:

1. For tests, Jest uses CommonJS style import/export:
   - `require(...)` in `src/dashboard.test.js`
   - `module.exports` in `src/dashboard.js`
2. For the browser page, the same module behaves as a global object.
3. When the page loads, `$(document).ready(...)` calls `UserDashboard.init()`.

Beginner mental model:

1. HTML provides elements like `save-profile-btn` and `status-text`.
2. jQuery finds those elements with selectors.
3. Your module attaches behavior to them.
4. Clicking the button runs logic, then updates the page.

Typical HTML wiring pattern:

1. Load jQuery first.
2. Load your dashboard script second.
3. Ensure the page has matching IDs used in selectors.
4. Let document ready initialize everything.

Minimal order example:

1. Include a script tag for jQuery.
2. Include a script tag for `dashboard.js`.
3. HTML contains `id="save-profile-btn"` and `id="status-text"`.

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

## GitHub Actions (Beginner Guide)

This project uses **two** workflow files so the pipeline is easy to understand:

- [PR checks workflow](.github/workflows/pr-checks.yml): runs tests for pull requests into `main`.
- [Production deploy workflow](.github/workflows/deploy-production.yml): runs on push to `main`, then runs the deploy stage only if tests pass.

### Why split into two files?

- Pull request workflow focuses only on code quality checks.
- Production workflow focuses on release/deploy flow.
- Keeping them separate makes each file shorter and easier for beginners to follow.

### What happens in each workflow?

1. Check out the repository code.
2. Install Node.js.
3. Install dependencies with `npm ci`.
4. Run tests with `npm test -- --watchAll=false`.
5. In production workflow only: run deploy stage if tests pass.

### Where do I add real deployment commands?

Edit the placeholder deploy step in [deploy workflow](.github/workflows/deploy-production.yml) and replace the `echo` lines with your real deploy commands.

### How do I make this required before merge?

In GitHub branch protection rules for `main`, require the PR test workflow status check to pass before merging.

### First PR Walkthrough (Beginner Checklist)

1. Create a new branch locally:
   - `git checkout -b my-first-change`
2. Make your code change and run tests locally:
   - `npm test -- --watchAll=false`
3. Commit and push your branch:
   - `git add .`
   - `git commit -m "Describe your change"`
   - `git push -u origin my-first-change`
4. Open GitHub and create a Pull Request into `main`.
5. In the PR page, open the Checks tab and wait for [PR checks workflow](.github/workflows/pr-checks.yml) to finish.
6. If checks fail:
   - Open the failed job log in GitHub Actions.
   - Fix the issue locally.
   - Re-run `npm test -- --watchAll=false`.
   - Commit and push again (the PR checks rerun automatically).
7. When checks pass and review is complete, merge the PR.
8. After merge, confirm [Production deploy workflow](.github/workflows/deploy-production.yml) runs on `main`.

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
