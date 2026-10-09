*** Settings ***
Documentation     Page object for the product list (inventory page, /inventory.html).
...               The header (menu, cart icon) is a separate component, imported here so
...               a test that uses this page can also use the header keywords.
Resource          ../common.resource
Resource          ../components/HeaderComponent.resource
Library           ../../libraries/ShopLibrary.py


*** Variables ***
${INVENTORY_PATH}     /inventory.html
${PAGE_TITLE}         css:[data-test="title"]
${SORT_SELECT}        css:[data-test="product-sort-container"]
${ITEM_NAMES}         css:[data-test="inventory-item-name"]
${ITEM_PRICES}        css:[data-test="inventory-item-price"]


*** Keywords ***
Open Products Page Directly
    [Documentation]    Types the products URL into the browser, skipping the login form.
    ...                Used to check that the page is protected.
    Go To    ${UI_URL}${INVENTORY_PATH}

Products Page Should Be Open
    [Documentation]    Checks the title and URL of the product list.
    Wait Until Element Is Visible    ${PAGE_TITLE}
    Element Text Should Be    ${PAGE_TITLE}    Products
    Location Should Contain    ${INVENTORY_PATH}

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
