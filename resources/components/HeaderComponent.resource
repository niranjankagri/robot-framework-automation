*** Settings ***
Documentation     Component object for the header shared by every logged-in page
...               (products, product, cart, checkout): who is signed in, the cart link
...               with its counter, and the "Sign out" button.
...
...               It is a component, not a page: it has no URL of its own, so it is kept
...               apart from the page objects and any page or test can use it.
Resource          ../common.resource


*** Variables ***
# Pattern Shop gives every element a test needs a data-testid.
${LOGOUT_BUTTON}          css:[data-testid="logout"]
# "Cart (2)": the link, and the number inside it.
${CART_LINK}              css:[data-testid="cart-link"]
${CART_COUNT}             css:[data-testid="cart-count"]


*** Keywords ***
Log Out Through Header
    [Documentation]    Logs the user out with the "Sign out" button in the header.
    ...                The shop then shows the sign-in page again.
    Click Button    ${LOGOUT_BUTTON}

Get Cart Count
    [Documentation]    Returns the number in the cart link as an integer.
    Wait Until Element Is Visible    ${CART_COUNT}
    ${text}=    Get Text    ${CART_COUNT}
    RETURN    ${text.strip()}

Cart Badge Count Should Be
    [Documentation]    Checks the number in the cart link, e.g. "2".
    ...                Pattern Shop always shows it, also "0" for an empty cart.
    [Arguments]    ${count}
    Wait Until Element Is Visible    ${CART_COUNT}
    Element Text Should Be    ${CART_COUNT}    ${count}

Open Cart Through Header Icon
    [Documentation]    Opens the cart page with the cart link in the header.
    Click Link    ${CART_LINK}
