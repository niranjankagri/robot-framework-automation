*** Settings ***
Documentation     Cart: adding and removing products, the badge count, and the cart contents.
Resource          ../../resources/pages/LoginPage.resource
Resource          ../../resources/pages/InventoryPage.resource
Resource          ../../resources/components/HeaderComponent.resource
Resource          ../../resources/pages/CartPage.resource
# Every test starts logged in with a new browser, so the cart is always empty at the start.
Test Setup        Open Browser And Log In
Test Teardown     Close All Test Browsers
Test Tags         ui    cart


*** Variables ***
# Product names as the shop shows them; the page objects build the button locators from them.
${BACKPACK}       Sauce Labs Backpack
${BIKE_LIGHT}     Sauce Labs Bike Light
${ONESIE}         Sauce Labs Onesie


*** Test Cases ***
Added Products Appear In The Cart
    [Documentation]    Two added products are counted on the badge and listed in the cart.
    [Tags]    smoke
    Add Product To Cart    ${BACKPACK}
    Add Product To Cart    ${BIKE_LIGHT}
    # Check both places: the badge in the header and the cart page itself.
    Cart Badge Count Should Be    2
    Open Cart Through Header Icon
    Cart Should Contain Only    ${BACKPACK}    ${BIKE_LIGHT}

Removing A Product Updates The Badge
    [Documentation]    Each removal lowers the badge count; removing the last product hides it.
    Add Product To Cart    ${BACKPACK}
    Add Product To Cart    ${ONESIE}
    # 2 -> 1: the count goes down by one.
    Remove Product From Cart    ${BACKPACK}
    Cart Badge Count Should Be    1
    # 1 -> 0: the badge disappears instead of showing 0.
    Remove Product From Cart    ${ONESIE}
    Cart Badge Count Should Be    0

Cart Is Empty For A New Session
    [Documentation]    A user who just logged in starts with an empty cart.
    # Nothing is added: a product left over from another test would show up here.
    Open Cart Through Header Icon
    Cart Should Be Empty

Cart Keeps Products After Continue Shopping
    [Documentation]    Going back from the cart to the product list must not lose the cart.
    Add Product To Cart    ${BACKPACK}
    Open Cart Through Header Icon
    Continue Shopping From Cart
    # Back on the product list, the badge must still count the product.
    Products Page Should Be Open
    Cart Badge Count Should Be    1
