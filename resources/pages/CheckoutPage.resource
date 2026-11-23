*** Settings ***
Documentation     Page objects for the three checkout steps:
...               1. your information (form), 2. overview (prices), 3. complete (confirmation).
...
...               The three steps are one flow with shared controls (Continue, Cancel),
...               so they share one resource file instead of three tiny ones.
Resource          ../common.resource
Resource          ../components/HeaderComponent.resource
# ShopLibrary: Generate Random Customer, Parse Prices and Calculate Order Totals.
Library           ../../libraries/ShopLibrary.py


*** Variables ***
${INFORMATION_PATH}          /checkout/info
${COMPLETE_PATH}             /complete

# Step 1: customer information form.
# Robot variable names ignore case and underscores, so ${FIRST_NAME} would clash
# with a keyword argument ${first_name}. Hence the _INPUT suffix on the locators.
${FIRST_NAME_INPUT}          css:[data-testid="first-name"]
${LAST_NAME_INPUT}           css:[data-testid="last-name"]
${POSTAL_CODE_INPUT}         css:[data-testid="postal-code"]
${CONTINUE_BUTTON}           css:[data-testid="continue"]
# "Cancel" is a link on both steps (back to the cart on step 1, to the products on step 2).
${CANCEL_LINK}               css:[data-testid="cancel"]
${CHECKOUT_ERROR_MESSAGE}    css:[data-testid="checkout-error"]

# Step 2: overview with item prices and totals (each amount is its own element, e.g. "$29.99").
${ITEM_PRICE_LABELS}         css:[data-testid="overview-item-price"]
${SUBTOTAL_LABEL}            css:[data-testid="subtotal"]
${TAX_LABEL}                 css:[data-testid="tax"]
${TOTAL_LABEL}               css:[data-testid="total"]
${FINISH_BUTTON}             css:[data-testid="finish"]

# Step 3: order confirmation.
${CONFIRMATION_HEADER}       css:[data-testid="complete-title"]
${ORDER_NUMBER_LABEL}        css:[data-testid="order-number"]
${BACK_TO_PRODUCTS_LINK}     css:[data-testid="back-to-products"]


*** Keywords ***
Open Checkout Information Page Directly
    [Documentation]    Opens step 1 by URL. Pattern Shop shows the form only when the cart has
    ...                a product (an empty cart goes back to /cart), so add one first.
    Go To    ${UI_URL}${INFORMATION_PATH}
    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}

Submit Customer Information
    [Documentation]    Step 1: fills in the three fields and clicks "Continue".
    ...                Empty values are allowed, so negative tests can leave a field blank.
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    # The form may still be loading right after the click on "Checkout".
    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}
    # Input Text clears each field first, so old values never mix with new ones.
    Input Text    ${FIRST_NAME_INPUT}     ${first_name}
    Input Text    ${LAST_NAME_INPUT}      ${last_name}
    Input Text    ${POSTAL_CODE_INPUT}    ${postal_code}
    Click And Wait For New Page    ${CONTINUE_BUTTON}

Submit Random Customer Information
    [Documentation]    Step 1 with a random name and postal code (see ShopLibrary),
    ...                which shows the form does not depend on one fixed value.
    # A dict with first_name, last_name and postal_code.
    ${customer}=    Generate Random Customer
    Submit Customer Information    ${customer}[first_name]    ${customer}[last_name]    ${customer}[postal_code]

Checkout Error Message Should Be
    [Documentation]    Checks the red error message shown on step 1.
    [Arguments]    ${expected_message}
    Wait Until Element Is Visible    ${CHECKOUT_ERROR_MESSAGE}
    Element Text Should Be    ${CHECKOUT_ERROR_MESSAGE}    ${expected_message}

Overview Totals Should Match Item Prices Plus Tax
    [Documentation]    Step 2: recalculates subtotal, 8% tax and total from the item prices
    ...                on the page and checks that the three labels show the same amounts.
    # The total label is the last part of the overview to render.
    Wait Until Element Is Visible    ${TOTAL_LABEL}
    # "$29.99" texts -> Decimals, then the expected totals in exact money maths.
    ${price_texts}=    Get Texts Of All Matching Elements    ${ITEM_PRICE_LABELS}
    ${item_prices}=    Parse Prices    ${price_texts}
    ${subtotal}    ${tax}    ${total}=    Calculate Order Totals    ${item_prices}
    # "$$" is "$" followed by a variable: "$" + "29.99".
    Element Text Should Be    ${SUBTOTAL_LABEL}    $${subtotal}
    Element Text Should Be    ${TAX_LABEL}         $${tax}
    Element Text Should Be    ${TOTAL_LABEL}       $${total}

Place Order
    [Documentation]    Step 2: clicks "Finish" to place the order.
    Click And Wait For New Page    ${FINISH_BUTTON}

Order Confirmation Should Be Shown
    [Documentation]    Step 3: checks the "Thank you for your order" page and its order number.
    Wait Until Element Is Visible    ${CONFIRMATION_HEADER}
    Element Text Should Be    ${CONFIRMATION_HEADER}    Thank you for your order
    # An order number such as ORD-4821.
    ${order}=    Get Text    ${ORDER_NUMBER_LABEL}
    Should Match Regexp    ${order}    ^ORD-\\d{4}$
    # The URL proves it is the real confirmation step, not a message on another page.
    Location Should Contain    ${COMPLETE_PATH}

Return To Products After Order
    [Documentation]    Step 3: clicks "Back to products" to return to the product list.
    Click And Wait For New Page    ${BACK_TO_PRODUCTS_LINK}

Cancel Checkout
    [Documentation]    Clicks "Cancel" on step 2: the shop goes back to the product list and
    ...                keeps the cart (no order is placed).
    # Step 1 has a "cancel" link too, so wait for step 2 before looking for it.
    Wait Until Element Is Visible    ${FINISH_BUTTON}
    Click And Wait For New Page    ${CANCEL_LINK}
