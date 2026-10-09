*** Settings ***
Documentation     Component object for the header shared by every logged-in page
...               (products, cart, checkout): side menu, cart icon and cart badge.
...
...               It is a component, not a page: it has no URL of its own, so it is kept
...               apart from the page objects and any page or test can use it.
Resource          ../common.resource


*** Variables ***
# Side menu ("burger" menu). It has no data-test attributes, so the stable ids are used.
${SIDE_MENU_BUTTON}       id:react-burger-menu-btn
${LOGOUT_MENU_LINK}       id:logout_sidebar_link
${RESET_MENU_LINK}        id:reset_sidebar_link

# Cart icon in the top right corner and the red number on it.
${CART_ICON_LINK}         css:[data-test="shopping-cart-link"]
${CART_BADGE}             css:[data-test="shopping-cart-badge"]


*** Keywords ***
Log Out Through Side Menu
    [Documentation]    Logs the user out with the "Logout" link of the side menu.
    ...                Sauce Demo then shows the login page again.
    Click Link In Side Menu    ${LOGOUT_MENU_LINK}

Reset App State Through Side Menu
    [Documentation]    Empties the cart with the "Reset App State" link of the side menu.
    Click Link In Side Menu    ${RESET_MENU_LINK}

Click Link In Side Menu
    [Documentation]    Opens the side menu and clicks the link given as ${link} (a locator).
    [Arguments]    ${link}
    Click Button    ${SIDE_MENU_BUTTON}
    # The menu slides in; wait until the link is really visible before clicking.
    Wait Until Element Is Visible    ${link}
    Click Link    ${link}

Cart Badge Count Should Be
    [Documentation]    Checks the number on the cart icon.
    ...                A ${count} of 0 means the badge must not be shown at all,
    ...                because Sauce Demo hides it when the cart is empty.
    [Arguments]    ${count}
    IF    ${count} == 0
        Page Should Not Contain Element    ${CART_BADGE}
    ELSE
        Element Text Should Be    ${CART_BADGE}    ${count}
    END

Open Cart Through Header Icon
    [Documentation]    Opens the cart page by clicking the cart icon in the header.
    Click Link    ${CART_ICON_LINK}
