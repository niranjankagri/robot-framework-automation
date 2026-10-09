*** Settings ***
Documentation     Checkout: the full order flow (end to end), price maths and form validation.
Resource          ../../resources/pages/LoginPage.resource
Resource          ../../resources/pages/InventoryPage.resource
Resource          ../../resources/pages/CartPage.resource
Resource          ../../resources/pages/CheckoutPage.resource
Test Setup        Open Shop And Log In
Test Teardown     Close Shop
Test Tags         ui    checkout


*** Test Cases ***
User Can Buy Two Products
    [Documentation]    End to end: products -> cart -> information -> overview -> complete.
    [Tags]    smoke    e2e
    Add Product To Cart    Sauce Labs Backpack
    Add Product To Cart    Sauce Labs Fleece Jacket
    Open Cart
    Cart Should Contain Exactly    Sauce Labs Backpack    Sauce Labs Fleece Jacket
    Go To Checkout
    Enter Random Customer Information
    Overview Totals Should Be Correct
    Finish Order
    Order Should Be Complete
    # After the order the cart must be empty again.
    Cart Badge Should Show    0
    Back To Products
    Products Page Should Be Open

Order Totals Include Eight Percent Tax
    [Documentation]    Three products of different prices, so rounding of the tax is tested too.
    Add Product To Cart    Sauce Labs Bike Light
    Add Product To Cart    Sauce Labs Bolt T-Shirt
    Add Product To Cart    Sauce Labs Onesie
    Open Cart
    Go To Checkout
    Enter Random Customer Information
    Overview Totals Should Be Correct

Cancel On Overview Keeps The Cart
    Add Product To Cart    Sauce Labs Backpack
    Open Cart
    Go To Checkout
    Enter Random Customer Information
    Cancel Checkout
    Products Page Should Be Open
    Cart Badge Should Show    1

Customer Information Is Required
    [Tags]    negative
    [Template]    Checkout Should Fail With
    # first name    last name    postal code    expected error
    ${EMPTY}        Doe          12345          Error: First Name is required
    Jane            ${EMPTY}     12345          Error: Last Name is required
    Jane            Doe          ${EMPTY}       Error: Postal Code is required


*** Keywords ***
Checkout Should Fail With
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}    ${expected_error}
    Go To    ${UI_URL}/checkout-step-one.html
    Enter Customer Information    ${first_name}    ${last_name}    ${postal_code}
    Checkout Error Should Be    ${expected_error}
