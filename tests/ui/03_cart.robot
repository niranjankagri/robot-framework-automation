*** Settings ***
Documentation     Cart: adding and removing products, badge count, cart contents.
Resource          ../../resources/pages/LoginPage.resource
Resource          ../../resources/pages/InventoryPage.resource
Resource          ../../resources/pages/CartPage.resource
Test Setup        Open Shop And Log In
Test Teardown     Close Shop
Test Tags         ui    cart


*** Variables ***
${BACKPACK}       Sauce Labs Backpack
${BIKE_LIGHT}     Sauce Labs Bike Light
${ONESIE}         Sauce Labs Onesie


*** Test Cases ***
Added Products Appear In The Cart
    [Tags]    smoke
    Add Product To Cart    ${BACKPACK}
    Add Product To Cart    ${BIKE_LIGHT}
    Cart Badge Should Show    2
    Open Cart
    Cart Should Contain Exactly    ${BACKPACK}    ${BIKE_LIGHT}

Removing A Product Updates The Badge
    Add Product To Cart    ${BACKPACK}
    Add Product To Cart    ${ONESIE}
    Remove Product From Cart    ${BACKPACK}
    Cart Badge Should Show    1
    Remove Product From Cart    ${ONESIE}
    Cart Badge Should Show    0

Cart Is Empty For A New Session
    Open Cart
    Cart Should Be Empty

Cart Keeps Products After Continue Shopping
    Add Product To Cart    ${BACKPACK}
    Open Cart
    Continue Shopping
    Products Page Should Be Open
    Cart Badge Should Show    1

