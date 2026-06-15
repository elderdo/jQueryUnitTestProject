/**
 * @jest-environment jsdom
 *
 * JEST NAMING CONVENTIONS & TEST FILE STRUCTURE
 * 
 * File Naming:
 * - Test files MUST end with .test.js (or .spec.js as an alternative)
 * - Jest automatically discovers files matching this pattern
 * - Convention: Name test file after the code it tests
 *   Example: dashboard.js → dashboard.test.js (co-located in same folder)
 * 
 * Test Organization:
 * - describe() groups related tests together with a descriptive name
 * - test() (or it()) defines individual test cases with human-readable descriptions
 * - Each test should be focused on ONE specific behavior
 * 
 * Running Tests:
 * - npm test          → Runs all test files matching *.test.js
 * - npm test -- --watch → Re-runs tests automatically when files change
 */
// The comment above is a magic flag telling Jest to load a virtual browser window (jsdom)

// 1. Import jQuery globally inside this test file so our code can use it
const $ = require('jquery');
global.$ = global.jQuery = $;

// 2. Import our dashboard module
const UserDashboard = require('./dashboard');

describe('UserDashboard Test Suite', () => {

    // Test 1: Testing pure calculations without touching HTML
    test('generateWelcome returns custom string when name is provided', () => {
        const result = UserDashboard.businessLogic.generateWelcome('Alex');
        expect(result).toBe('Welcome back, Alex!');
    });

    // Test 2: Testing DOM (HTML) Changes
    test('updateUI should inject text and display the hidden div', () => {
        // Arrange: Build a mini piece of mock HTML inside Jest's virtual memory
        document.body.innerHTML = `
            <button id="save-profile-btn">Save</button>
            <div id="status-text" style="display:none;"></div>
        `;

        // Act: Directly run our UI function with a mock message
        UserDashboard.updateUI('Test Success!');

        // Assert: Find the element in our virtual HTML and check if its text updated
        const statusDiv = $('#status-text');
        expect(statusDiv.text()).toBe('Test Success!');

        // Check if jQuery changed its display status (fadeIn sets display to block/inline-block)
        expect(statusDiv.css('display')).not.toBe('none');
    });

});
