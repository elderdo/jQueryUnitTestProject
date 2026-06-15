// =========================================================================
// jQuery Syntax Guide:
// $(selector) -> This is the jQuery function. It finds HTML elements.
// .on('event', callback) -> Attaches an event listener to those elements.
// =========================================================================

// =========================================================================
// FUNCTIONAL PROGRAMMING: THE READY METHOD
// =========================================================================
// 
// $(document).ready() is an example of a HIGHER-ORDER FUNCTION in action.
// A higher-order function is a function that accepts another function as an argument.
// 
// What's happening here:
// 1. We're PASSING a function (the anonymous function) into .ready()
// 2. The .ready() method ACCEPTS that function as a callback
// 3. jQuery stores this callback internally
// 4. When the DOM is fully loaded, jQuery CALLS (executes) our callback function
//
// Why is this powerful?
// - We don't call UserDashboard.init() directly. Instead, we give jQuery the INSTRUCTION
//   to call it later (when the DOM is ready).
// - This delays execution until the right moment, preventing errors from trying to
//   select HTML elements that haven't been parsed yet.
//
// Think of it like this:
// - Without .ready(): "Run init() RIGHT NOW!" (might crash if HTML isn't loaded)
// - With .ready(): "Hey jQuery, please call init() ONCE you've finished loading the DOM"
//
$(document).ready(function () {
    // Fire up our dashboard module once the page is safely loaded.
    UserDashboard.init();
});

// =========================================================================
// SCOPE & GLOBAL SCOPE POLLUTION
// =========================================================================
//
// In JavaScript, SCOPE determines where variables can be accessed.
// There are multiple scopes:
// - GLOBAL SCOPE: Variables accessible EVERYWHERE in your entire application
// - LOCAL SCOPE: Variables accessible only within a function or block
//
// Why avoid global scope pollution?
//
// PROBLEM: If we wrote all our code directly in global scope:
//   let selectors = { saveButton: '#save-profile-btn' };
//   let init = function() { ... };
//   let handleSave = function() { ... };
//
//   These would ALL be directly on the global `window` object:
//   - window.selectors
//   - window.init
//   - window.handleSave
//
//   This causes conflicts if:
//   1. Another script file also creates a variable named `selectors` or `init`
//   2. Someone accidentally overwrites your variable: selectors = "oops, now it's a string!"
//   3. Your code becomes harder to test because everything leaks into global namespace
//
// SOLUTION: Wrap everything inside a single object (a NAMESPACE):
// - We create ONE global variable: UserDashboard
// - ALL our code lives INSIDE this object as properties/methods
// - Only UserDashboard is exposed to the global scope
// - Everything else is "namespaced" and protected from collisions
//
// This pattern is called a MODULE or NAMESPACE pattern.
//
// Why use `const` for UserDashboard?
// - `const` means the variable binding cannot be reassigned later.
//   Example: `UserDashboard = {}` would throw an error instead of silently replacing our module.
// - This protects the module reference from accidental overwrite by other code.
// - Important: `const` does NOT make the object immutable.
//   We can still add or change properties like `UserDashboard.selectors` if needed.
// - In short: we keep a stable module identity while still allowing controlled internal updates.
//
// We wrap everything in a plain JavaScript object to avoid "global scope pollution".
// This keeps our code isolated, clean, and incredibly easy to test.
const UserDashboard = {

    // 1. SELECTORS STORAGE
    // Instead of hardcoding '#save-profile-btn' all over our code, we keep it here.
    // If the HTML ID ever changes, we only have to fix it in this one spot!
    selectors: {
        saveButton: '#save-profile-btn', // Matches: <button id="save-profile-btn">
        statusMessage: '#status-text'    // Matches: <div id="status-text">
    },

    // 2. INITIALIZATION
    // This hooks up our webpage elements to our JavaScript logic.
    init: function () {
        // $(this.selectors.saveButton) wraps our HTML button in a jQuery power-suit.
        // .on('click', ...) listens for a physical mouse click on that button.
        // We use an arrow function () => to make sure 'this' still points to UserDashboard.
        $(this.selectors.saveButton).on('click', () => this.handleSave());
    },

    // 3. UI EVENT HANDLER
    // This coordinates what happens when a user triggers an event.
    handleSave: function () {
        // Step A: Call our pure logic function to calculate what the message should be.
        const message = this.businessLogic.generateWelcome("Alex");

        // Step B: Pass that calculated string into our UI function to update the screen.
        this.updateUI(message);
    },

    // 4. DOM MANIPULATION
    // This function physically alters the HTML structure visible to the user.
    updateUI: function (text) {
        // $(this.selectors.statusMessage) finds our hidden #status-text div.
        // .text(text) updates its inner HTML content to say "Welcome back, Alex!".
        // .fadeIn() is a built-in jQuery animation that smoothly transitions opacity from 0 to 1.
        $(this.selectors.statusMessage).text(text).fadeIn();
    },

    // 5. PURE BUSINESS LOGIC
    // CRITICAL FOR TESTING: This section contains NO HTML and NO jQuery selectors.
    // It is pure input and output, making it instantly testable anywhere.
    businessLogic: {
        generateWelcome: function (name) {
            if (!name) {
                return "Welcome, Guest!";
            }
            return `Welcome back, ${name}!`;
        }
    }

};

// This line exports the code so Jest can read it during tests.
// The "typeof module" check stops the browser from crashing since browsers don't natively understand "module.exports".
if (typeof module !== 'undefined' && module.exports) {
    module.exports = UserDashboard;
}
