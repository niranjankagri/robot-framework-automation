*** Settings ***
Documentation     Page object for the cart page (/cart.html): the products in the cart,
...               and the buttons to go back shopping or on to the checkout.
Resource          ../common.resource


*** Variables ***
${CART_PATH}                   /cart.html

# One row per product in the cart, and the product name inside each row.
${CART_ITEM_ROWS}              css:[data-test="inventory-item"]
${CART_ITEM_NAME_LABELS}       css:[data-test="inventory-item-name"]

${CHECKOUT_BUTTON}             css:[data-test="checkout"]
${CONTINUE_SHOPPING_BUTTON}    css:[data-test="continue-shopping"]


*** Keywords ***
Cart Page Should Be Open
    [Documentation]    Waits for the cart page and checks its URL.
    Wait Until Element Is Visible    ${CHECKOUT_BUTTON}
    Location Should Contain    ${CART_PATH}

Cart Should Contain Only
    [Documentation]    Checks that the cart holds exactly the products named in @{expected_names}:
    ...                no product missing, none extra. The order does not matter.
    ...
    ...                Example: ``Cart Should Contain Only    Sauce Labs Backpack    Sauce Labs Onesie``
    [Arguments]    @{expected_names}
    Cart Page Should Be Open
    ${actual_names}=    Get Texts Of All Matching Elements    ${CART_ITEM_NAME_LABELS}
    Lists Should Be Equal    ${actual_names}    ${expected_names}    ignore_order=True

Cart Should Be Empty
    [Documentation]    Checks that the cart page shows no product rows.
    Cart Page Should Be Open
    Page Should Not Contain Element    ${CART_ITEM_ROWS}

Continue Shopping From Cart
    [Documentation]    Clicks "Continue Shopping" to go back to the product list.
    Click Button    ${CONTINUE_SHOPPING_BUTTON}

Proceed To Checkout
    [Documentation]    Clicks "Checkout" to start step 1 of the checkout (customer information).
    Click Button    ${CHECKOUT_BUTTON}
