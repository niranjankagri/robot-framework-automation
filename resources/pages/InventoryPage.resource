*** Settings ***
Documentation     Page object for the product list (inventory) and the header shared by
...               all logged-in pages (cart icon, burger menu).
Resource          ../common.resource


*** Variables ***
${PAGE_TITLE}         css:[data-test="title"]
${MENU_BUTTON}        id:react-burger-menu-btn
${LOGOUT_LINK}        id:logout_sidebar_link


*** Keywords ***
Products Page Should Be Open
    Wait Until Element Is Visible    ${PAGE_TITLE}
    Element Text Should Be    ${PAGE_TITLE}    Products
    Location Should Contain    /inventory.html

Logout
    Click Button    ${MENU_BUTTON}
    # The menu slides in; wait until the link is really visible before clicking.
    Wait Until Element Is Visible    ${LOGOUT_LINK}
    Click Link    ${LOGOUT_LINK}
