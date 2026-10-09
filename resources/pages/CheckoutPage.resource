*** Settings ***
Documentation     Page objects for the three checkout steps:
...               1. your information (form), 2. overview (prices), 3. complete (confirmation).
...
...               The three steps are one flow with shared buttons (Continue, Cancel),
...               so they share one resource file instead of three tiny ones.
Resource          ../common.resource
Library           ../../libraries/ShopLibrary.py


*** Variables ***
${INFORMATION_PATH}          /checkout-step-one.html
${COMPLETE_PATH}             /checkout-complete.html

# Step 1: customer information form.
# Robot variable names ignore case and underscores, so ${FIRST_NAME} would clash
# with a keyword argument ${first_name}. Hence the _INPUT suffix on the locators.
${FIRST_NAME_INPUT}          css:[data-test="firstName"]
${LAST_NAME_INPUT}           css:[data-test="lastName"]
${POSTAL_CODE_INPUT}         css:[data-test="postalCode"]
${CONTINUE_BUTTON}           css:[data-test="continue"]
${CANCEL_BUTTON}             css:[data-test="cancel"]
${CHECKOUT_ERROR_MESSAGE}    css:[data-test="error"]

# Step 2: overview with item prices and totals.
${ITEM_PRICE_LABELS}         css:[data-test="inventory-item-price"]
${SUBTOTAL_LABEL}            css:[data-test="subtotal-label"]
${TAX_LABEL}                 css:[data-test="tax-label"]
${TOTAL_LABEL}               css:[data-test="total-label"]
${FINISH_BUTTON}             css:[data-test="finish"]

# Step 3: order confirmation.
${CONFIRMATION_HEADER}       css:[data-test="complete-header"]
${BACK_TO_PRODUCTS_BUTTON}   css:[data-test="back-to-products"]


*** Keywords ***
Open Checkout Information Page Directly
    [Documentation]    Opens step 1 by URL. The form works even with an empty cart,
    ...                which lets the form-validation tests skip the cart steps.
    Go To    ${UI_URL}${INFORMATION_PATH}

Submit Customer Information
    [Documentation]    Step 1: fills in the three fields and clicks "Continue".
    ...                Empty values are allowed, so negative tests can leave a field blank.
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}
    Input Text    ${FIRST_NAME_INPUT}     ${first_name}
    Input Text    ${LAST_NAME_INPUT}      ${last_name}
    Input Text    ${POSTAL_CODE_INPUT}    ${postal_code}
    Click Button    ${CONTINUE_BUTTON}

Submit Random Customer Information
    [Documentation]    Step 1 with a random name and postal code (see ShopLibrary),
    ...                which shows the form does not depend on one fixed value.
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
    Wait Until Element Is Visible    ${TOTAL_LABEL}
    ${price_texts}=    Get Texts Of All Matching Elements    ${ITEM_PRICE_LABELS}
    ${item_prices}=    Parse Prices    ${price_texts}
    ${subtotal}    ${tax}    ${total}=    Calculate Order Totals    ${item_prices}
    Element Text Should Be    ${SUBTOTAL_LABEL}    Item total: $${subtotal}
    Element Text Should Be    ${TAX_LABEL}         Tax: $${tax}
    Element Text Should Be    ${TOTAL_LABEL}       Total: $${total}

Place Order
    [Documentation]    Step 2: clicks "Finish" to place the order.
    Click Button    ${FINISH_BUTTON}

Order Confirmation Should Be Shown
    [Documentation]    Step 3: checks the "Thank you for your order!" page.
    Wait Until Element Is Visible    ${CONFIRMATION_HEADER}
    Element Text Should Be    ${CONFIRMATION_HEADER}    Thank you for your order!
    Location Should Contain    ${COMPLETE_PATH}

Return To Products After Order
    [Documentation]    Step 3: clicks "Back Home" to return to the product list.
    Click Button    ${BACK_TO_PRODUCTS_BUTTON}

Cancel Checkout
    [Documentation]    Clicks "Cancel" on step 1 or 2. Sauce Demo goes back to the product
    ...                list and keeps the cart.
    Click Button    ${CANCEL_BUTTON}
