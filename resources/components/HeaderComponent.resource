*** Settings ***
Documentation     Component object for the header shared by every logged-in page
...               (products, cart, checkout): burger menu, cart icon and cart badge.
...
...               It is a component, not a page: it has no URL of its own, so it is kept
...               apart from the page objects and any page or test can use it.
Resource          ../common.resource


*** Variables ***
# The menu has no data-test attributes, so the stable ids are used instead.
${MENU_BUTTON}        id:react-burger-menu-btn
${LOGOUT_LINK}        id:logout_sidebar_link
${RESET_LINK}         id:reset_sidebar_link
${CART_BADGE}         css:[data-test="shopping-cart-badge"]
${CART_LINK}          css:[data-test="shopping-cart-link"]


*** Keywords ***
Logout
    [Documentation]    Logs out through the burger menu.
    Open Menu And Click    ${LOGOUT_LINK}

Reset App State
    [Documentation]    Empties the cart through the burger menu ("Reset App State").
    Open Menu And Click    ${RESET_LINK}

Open Menu And Click
    [Documentation]    Opens the burger menu and clicks one of its links.
    [Arguments]    ${link}
    Click Button    ${MENU_BUTTON}
    # The menu slides in; wait until the link is really visible before clicking.
    Wait Until Element Is Visible    ${link}
    Click Link    ${link}

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
