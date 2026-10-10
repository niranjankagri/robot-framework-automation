*** Settings ***
Documentation     Page object for the product list (inventory page, /inventory.html):
...               sorting, reading names and prices, and adding/removing products.
...
...               The header (side menu, cart icon) is a separate component, imported here so
...               a test that uses this page can also use the header keywords.
Resource          ../common.resource
Resource          ../components/HeaderComponent.resource
# ShopLibrary: Product Id From Name and Parse Prices.
Library           ../../libraries/ShopLibrary.py


*** Variables ***
${INVENTORY_PATH}          /inventory.html
${PAGE_TITLE_LABEL}        css:[data-test="title"]
${SORT_DROPDOWN}           css:[data-test="product-sort-container"]

# One label per product card, in the order the page shows them.
${PRODUCT_NAME_LABELS}     css:[data-test="inventory-item-name"]
${PRODUCT_PRICE_LABELS}    css:[data-test="inventory-item-price"]


*** Keywords ***
Open Products Page Directly
    [Documentation]    Types the products URL into the browser, skipping the login form.
    ...                Used to check that the page is protected from anonymous users.
    Go To    ${UI_URL}${INVENTORY_PATH}

Products Page Should Be Open
    [Documentation]    Waits for the product list and checks its title and URL.
    Wait Until Element Is Visible    ${PAGE_TITLE_LABEL}
    Element Text Should Be    ${PAGE_TITLE_LABEL}    Products
    Location Should Contain    ${INVENTORY_PATH}

Sort Products By
    [Documentation]    Picks a sort option by its visible text, e.g. "Price (low to high)".
    [Arguments]    ${option_label}
    # The sort control is a real <select>, so SeleniumLibrary's list keywords work on it.
    Select From List By Label    ${SORT_DROPDOWN}    ${option_label}

Get Displayed Product Names
    [Documentation]    Returns the product names as a list, in the order the page shows them.
    ${names}=    Get Texts Of All Matching Elements    ${PRODUCT_NAME_LABELS}
    RETURN    ${names}

Get Displayed Product Prices
    [Documentation]    Returns the product prices as a list of Decimals (e.g. 29.99),
    ...                in the order the page shows them.
    ${price_texts}=    Get Texts Of All Matching Elements    ${PRODUCT_PRICE_LABELS}
    # "$29.99" -> Decimal("29.99"), so prices compare as numbers, not as text.
    ${prices}=    Parse Prices    ${price_texts}
    RETURN    ${prices}

Add Product To Cart
    [Documentation]    Clicks "Add to cart" on the product named ${product_name}
    ...                and waits until the button has turned into "Remove".
    [Arguments]    ${product_name}
    # Button ids are built from the product name, e.g. add-to-cart-sauce-labs-backpack.
    ${id}=    Product Id From Name    ${product_name}
    Click Button    css:[data-test="add-to-cart-${id}"]
    # The button turns into "Remove" once the product is in the cart.
    Wait Until Element Is Visible    css:[data-test="remove-${id}"]

Remove Product From Cart
    [Documentation]    Clicks "Remove" on the product named ${product_name}
    ...                and waits until the button has turned back into "Add to cart".
    [Arguments]    ${product_name}
    ${id}=    Product Id From Name    ${product_name}
    Click Button    css:[data-test="remove-${id}"]
    # Waiting for the swap back means the next step sees the updated cart badge.
    Wait Until Element Is Visible    css:[data-test="add-to-cart-${id}"]
