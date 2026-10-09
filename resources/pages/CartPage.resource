*** Settings ***
Documentation     Page object for the cart page (/cart.html): what is in the cart, and the
...               buttons to go back shopping or on to the checkout.
Resource          ../common.resource


*** Variables ***
${CART_PATH}             /cart.html
${CART_ITEM_NAMES}       css:[data-test="inventory-item-name"]
${CART_ITEMS}            css:[data-test="inventory-item"]
${CHECKOUT_BUTTON}       css:[data-test="checkout"]
${CONTINUE_SHOPPING}     css:[data-test="continue-shopping"]


*** Keywords ***
Cart Page Should Be Open
    [Documentation]    Checks that the cart page is shown.
    Wait Until Element Is Visible    ${CHECKOUT_BUTTON}
    Location Should Contain    ${CART_PATH}

Cart Should Contain Exactly
    [Documentation]    Compares the product names in the cart with ${expected}, ignoring order.
    [Arguments]    @{expected}
    Cart Page Should Be Open
    ${actual}=    Get Element Texts    ${CART_ITEM_NAMES}
    Lists Should Be Equal    ${actual}    ${expected}    ignore_order=True

Cart Should Be Empty
    [Documentation]    Checks that the cart page shows no products.
    Cart Page Should Be Open
    Page Should Not Contain Element    ${CART_ITEMS}

Continue Shopping
    [Documentation]    Goes back from the cart to the product list.
    Click Button    ${CONTINUE_SHOPPING}

Go To Checkout
    [Documentation]    Starts the checkout from the cart.
    Click Button    ${CHECKOUT_BUTTON}
