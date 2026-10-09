*** Settings ***
Documentation     Page object for the cart page.
Resource          ../common.resource


*** Variables ***
${CART_ITEM_NAMES}       css:[data-test="inventory-item-name"]
${CART_ITEMS}            css:[data-test="inventory-item"]
${CHECKOUT_BUTTON}       css:[data-test="checkout"]
${CONTINUE_SHOPPING}     css:[data-test="continue-shopping"]


*** Keywords ***
Cart Page Should Be Open
    Wait Until Element Is Visible    ${CHECKOUT_BUTTON}
    Location Should Contain    /cart.html

Cart Should Contain Exactly
    [Documentation]    Compares the product names in the cart with ${expected}, ignoring order.
    [Arguments]    @{expected}
    Cart Page Should Be Open
    @{elements}=    Get WebElements    ${CART_ITEM_NAMES}
    @{actual}=    Create List
    FOR    ${element}    IN    @{elements}
        Append To List    ${actual}    ${element.text}
    END
    Lists Should Be Equal    ${actual}    ${expected}    ignore_order=True

Cart Should Be Empty
    Cart Page Should Be Open
    Page Should Not Contain Element    ${CART_ITEMS}

Continue Shopping
    Click Button    ${CONTINUE_SHOPPING}

Go To Checkout
    Click Button    ${CHECKOUT_BUTTON}
