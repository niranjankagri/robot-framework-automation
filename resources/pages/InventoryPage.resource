*** Settings ***
Documentation     Page object for the product list (inventory) and the header shared by
...               all logged-in pages (cart icon, burger menu).
Resource          ../common.resource
Library           ../../libraries/ShopLibrary.py


*** Variables ***
${PAGE_TITLE}         css:[data-test="title"]
${MENU_BUTTON}        id:react-burger-menu-btn
${LOGOUT_LINK}        id:logout_sidebar_link
${RESET_LINK}         id:reset_sidebar_link
${MENU_CLOSE}         id:react-burger-cross-btn
${SORT_SELECT}        css:[data-test="product-sort-container"]
${ITEM_NAMES}         css:[data-test="inventory-item-name"]
${ITEM_PRICES}        css:[data-test="inventory-item-price"]
${CART_BADGE}         css:[data-test="shopping-cart-badge"]
${CART_LINK}          css:[data-test="shopping-cart-link"]


*** Keywords ***
Products Page Should Be Open
    [Documentation]    Checks the title and URL of the product list.
    Wait Until Element Is Visible    ${PAGE_TITLE}
    Element Text Should Be    ${PAGE_TITLE}    Products
    Location Should Contain    /inventory.html

Logout
    [Documentation]    Logs out through the burger menu.
    Open Menu And Click    ${LOGOUT_LINK}

Open Menu And Click
    [Documentation]    Opens the burger menu and clicks one of its links.
    [Arguments]    ${link}
    Click Button    ${MENU_BUTTON}
    # The menu slides in; wait until the link is really visible before clicking.
    Wait Until Element Is Visible    ${link}
    Click Link    ${link}

Sort Products By
    [Documentation]    ${label} is the visible option text, e.g. "Price (low to high)".
    [Arguments]    ${label}
    Select From List By Label    ${SORT_SELECT}    ${label}

Get Product Names
    [Documentation]    Returns the product names in the order shown.
    ${names}=    Get Element Texts    ${ITEM_NAMES}
    RETURN    ${names}

Get Product Prices
    [Documentation]    Returns the prices as Decimals, in the order shown.
    ${texts}=    Get Element Texts    ${ITEM_PRICES}
    ${prices}=    Prices From Texts    ${texts}
    RETURN    ${prices}

Add Product To Cart
    [Documentation]    Clicks the product's "Add to cart" button and waits until it turns into "Remove".
    [Arguments]    ${name}
    ${id}=    Product Id    ${name}
    Click Button    css:[data-test="add-to-cart-${id}"]
    # The button turns into "Remove" once the product is in the cart.
    Wait Until Element Is Visible    css:[data-test="remove-${id}"]

Remove Product From Cart
    [Documentation]    Clicks the product's "Remove" button and waits until it turns back.
    [Arguments]    ${name}
    ${id}=    Product Id    ${name}
    Click Button    css:[data-test="remove-${id}"]
    Wait Until Element Is Visible    css:[data-test="add-to-cart-${id}"]

Cart Badge Should Show
    [Documentation]    0 means the badge is not shown at all (Sauce Demo hides it when empty).
    [Arguments]    ${count}
    IF    ${count} == 0
        Page Should Not Contain Element    ${CART_BADGE}
    ELSE
        Element Text Should Be    ${CART_BADGE}    ${count}
    END

Open Cart
    [Documentation]    Opens the cart through the cart icon in the header.
    Click Link    ${CART_LINK}
