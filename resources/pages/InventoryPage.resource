*** Settings ***
Documentation     Page object for the product list (/products): sorting, reading names
...               and prices, and adding products.
...
...               The header (sign-out, cart link) is a separate component, imported here so
...               a test that uses this page can also use the header keywords.
Resource          ../common.resource
Resource          ../components/HeaderComponent.resource
# ShopLibrary: Parse Prices.
Library           ../../libraries/ShopLibrary.py


*** Variables ***
${PRODUCTS_PATH}           /products
${PAGE_TITLE_LABEL}        css:[data-testid="products-title"]
# The sort control is a plain form: pick an option, then click "Sort" (no JavaScript).
${SORT_DROPDOWN}           css:[data-testid="sort"]
${SORT_BUTTON}             css:[data-testid="sort-apply"]

# One label per product card, in the order the page shows them.
${PRODUCT_NAME_LABELS}     css:[data-testid="product-name"]
${PRODUCT_PRICE_LABELS}    css:[data-testid="product-price"]


*** Keywords ***
Open Products Page Directly
    [Documentation]    Types the products URL into the browser, skipping the login form.
    ...                Used to check that the page is protected from anonymous users.
    Go To    ${UI_URL}${PRODUCTS_PATH}

Products Page Should Be Open
    [Documentation]    Waits for the product list and checks its title and URL.
    Wait Until Element Is Visible    ${PAGE_TITLE_LABEL}
    Element Text Should Be    ${PAGE_TITLE_LABEL}    Products
    Location Should Contain    ${PRODUCTS_PATH}

Sort Products By
    [Documentation]    Picks a sort option by its visible text, e.g. "Price (low to high)",
    ...                and applies it.
    [Arguments]    ${option_label}
    # The sort control is a real <select>, so SeleniumLibrary's list keywords work on it.
    Select From List By Label    ${SORT_DROPDOWN}    ${option_label}
    Click Button    ${SORT_BUTTON}
    # The page reloads with the new order; the chosen option stays selected.
    Wait Until Keyword Succeeds    ${TIMEOUT}    200 ms
    ...    List Selection Should Be    ${SORT_DROPDOWN}    ${option_label}

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
    ...                and waits until the cart counter has gone up by one.
    [Arguments]    ${product_name}
    ${before}=    Get Cart Count
    # The card whose name link has this exact text, and the add button inside it.
    Click Button
    ...    xpath://li[@data-testid="product-card"][a[@data-testid="product-name" and normalize-space()="${product_name}"]]//button
    # The page reloads after the click; the counter shows the new number.
    ${expected}=    Evaluate    ${before} + 1
    Wait Until Element Contains    ${CART_COUNT}    ${expected}
