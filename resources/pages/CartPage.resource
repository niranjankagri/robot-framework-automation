*** Settings ***
Documentation     Page object for the cart page (/cart): the products in the cart, removing
...               one, and the ways back to shopping or on to the checkout.
Resource          ../common.resource
Resource          ../components/HeaderComponent.resource


*** Variables ***
${CART_PATH}                   /cart
${CART_TITLE}                  css:[data-testid="cart-title"]

# One row per product in the cart, and the product name inside each row.
${CART_ITEM_ROWS}              css:[data-testid="cart-item"]
${CART_ITEM_NAME_LABELS}       css:[data-testid="cart-item-name"]

${CHECKOUT_BUTTON}             css:[data-testid="checkout"]
# "Continue shopping" is a link, not a button.
${CONTINUE_SHOPPING_LINK}      css:[data-testid="continue-shopping"]


*** Keywords ***
Cart Page Should Be Open
    [Documentation]    Waits for the cart page and checks its URL.
    Wait Until Element Is Visible    ${CART_TITLE}
    Location Should Contain    ${CART_PATH}

Cart Should Contain Only
    [Documentation]    Checks that the cart holds exactly the products named in @{expected_names}:
    ...                no product missing, none extra. The order does not matter.
    ...
    ...                Example: ``Cart Should Contain Only    Backpack    Bike Light``
    [Arguments]    @{expected_names}
    Cart Page Should Be Open
    ${actual_names}=    Get Texts Of All Matching Elements    ${CART_ITEM_NAME_LABELS}
    # Comparing whole lists catches both a missing and an extra product in one step.
    Lists Should Be Equal    ${actual_names}    ${expected_names}    ignore_order=True

Cart Should Be Empty
    [Documentation]    Checks that the cart page shows no product rows.
    # Wait for the page first, so "no rows" is not just "not loaded yet".
    Cart Page Should Be Open
    Page Should Not Contain Element    ${CART_ITEM_ROWS}

Remove Product From Cart
    [Documentation]    Clicks "Remove" in the cart row of ${product_name}; the cart reloads
    ...                without it.
    [Arguments]    ${product_name}
    Cart Page Should Be Open
    VAR    ${row}
    ...    xpath://li[@data-testid="cart-item"][span[@data-testid="cart-item-name" and normalize-space()="${product_name}"]]
    Click And Wait For New Page    ${row}//button
    # The reloaded cart has no row for it any more.
    Page Should Not Contain Element    ${row}

Continue Shopping From Cart
    [Documentation]    Clicks "Continue shopping" to go back to the product list.
    Click And Wait For New Page    ${CONTINUE_SHOPPING_LINK}

Proceed To Checkout
    [Documentation]    Clicks "Checkout" to start step 1 of the checkout (your information).
    Click And Wait For New Page    ${CHECKOUT_BUTTON}
