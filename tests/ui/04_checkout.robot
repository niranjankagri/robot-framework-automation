*** Settings ***
Documentation     Checkout: the full order flow (end to end), price maths and form validation.
Resource          ../../resources/pages/LoginPage.resource
Resource          ../../resources/pages/InventoryPage.resource
Resource          ../../resources/components/HeaderComponent.resource
Resource          ../../resources/pages/CartPage.resource
Resource          ../../resources/pages/CheckoutPage.resource
Test Setup        Open Browser And Log In
Test Teardown     Close All Test Browsers
Test Tags         ui    checkout


*** Test Cases ***
User Can Buy Two Products
    [Documentation]    End to end: products -> cart -> information -> overview -> complete,
    ...                and the cart is empty again after the order.
    [Tags]    smoke    e2e
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Fleece Jacket
    Open Cart Through Header Icon
    Cart Should Contain Only    Sauce Labs Backpack    Sauce Labs Fleece Jacket
    Proceed To Checkout
    Submit Random Customer Information
    Overview Totals Should Match Item Prices Plus Tax
    Place Order
    Order Confirmation Should Be Shown
    # After the order the cart must be empty again.
    Cart Badge Count Should Be    0
    Return To Products After Order
    Products Page Should Be Open

Order Totals Include Eight Percent Tax
    [Documentation]    Three products of different prices, so the rounding of the tax
    ...                to cents is checked too.
    Add Product To Cart    Sauce Labs Bike Light
    Add Product To Cart    Sauce Labs Bolt T-Shirt
    Add Product To Cart    Sauce Labs Onesie
    Open Cart Through Header Icon
    Proceed To Checkout
    Submit Random Customer Information
    Overview Totals Should Match Item Prices Plus Tax

Cancel On Overview Keeps The Cart
    [Documentation]    Cancelling on the overview step returns to the products and keeps
    ...                the product in the cart (no order is placed).
    Add Product To Cart    Sauce Labs Backpack
    Open Cart Through Header Icon
    Proceed To Checkout
    Submit Random Customer Information
    Cancel Checkout
    Products Page Should Be Open
    Cart Badge Count Should Be    1

Customer Information Is Required
    [Documentation]    Data-driven: each row leaves one field of step 1 empty and checks
    ...                the error message for that field.
    [Tags]    negative
    [Template]    Checkout Form Should Fail With Error
    # first name    last name    postal code    expected error
    ${EMPTY}        Doe          12345          Error: First Name is required
    Jane            ${EMPTY}     12345          Error: Last Name is required
    Jane            Doe          ${EMPTY}       Error: Postal Code is required


*** Keywords ***
Checkout Form Should Fail With Error
    [Documentation]    Template for the rows above: opens step 1 directly, submits the given
    ...                values and checks the error message.
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}    ${expected_error}
    Open Checkout Information Page Directly
    Submit Customer Information    ${first_name}    ${last_name}    ${postal_code}
    Checkout Error Message Should Be    ${expected_error}
