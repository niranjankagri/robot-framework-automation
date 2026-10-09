*** Settings ***
Documentation     Page objects for the three checkout steps:
...               1. your information, 2. overview (prices), 3. complete.
...               The three steps are one flow with shared buttons (Continue, Cancel),
...               so they share one resource file instead of three tiny ones.
Resource          ../common.resource
Library           ../../libraries/ShopLibrary.py


*** Variables ***
${INFORMATION_PATH}    /checkout-step-one.html
${COMPLETE_PATH}       /checkout-complete.html
# Robot variable names ignore case and underscores, so ${FIRST_NAME} would clash
# with the keyword argument ${first_name}. Hence the _INPUT suffix on the locators.
${FIRST_NAME_INPUT}    css:[data-test="firstName"]
${LAST_NAME_INPUT}     css:[data-test="lastName"]
${POSTAL_CODE_INPUT}   css:[data-test="postalCode"]
${CONTINUE_BUTTON}     css:[data-test="continue"]
${CANCEL_BUTTON}       css:[data-test="cancel"]
${CHECKOUT_ERROR}      css:[data-test="error"]
${OVERVIEW_PRICES}     css:[data-test="inventory-item-price"]
${SUBTOTAL_LABEL}      css:[data-test="subtotal-label"]
${TAX_LABEL}           css:[data-test="tax-label"]
${TOTAL_LABEL}         css:[data-test="total-label"]
${FINISH_BUTTON}       css:[data-test="finish"]
${COMPLETE_HEADER}     css:[data-test="complete-header"]
${BACK_HOME_BUTTON}    css:[data-test="back-to-products"]


*** Keywords ***
Open Checkout Information Page
    [Documentation]    Opens step 1 directly by URL (the cart may be empty; the form still works).
    ...                Lets the form-validation tests skip the cart steps.
    Go To    ${UI_URL}${INFORMATION_PATH}

Enter Customer Information
    [Documentation]    Step 1. Empty arguments are allowed so negative tests can leave fields blank.
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}
    Input Text    ${FIRST_NAME_INPUT}     ${first_name}
    Input Text    ${LAST_NAME_INPUT}      ${last_name}
    Input Text    ${POSTAL_CODE_INPUT}    ${postal_code}
    Click Button    ${CONTINUE_BUTTON}

Enter Random Customer Information
    [Documentation]    Step 1 with random names and postal code (see ShopLibrary).
    ${customer}=    Random Customer
    Enter Customer Information    ${customer}[first_name]    ${customer}[last_name]    ${customer}[postal_code]

Checkout Error Should Be
    [Documentation]    Checks the error message shown on step 1.
    [Arguments]    ${expected}
    Wait Until Element Is Visible    ${CHECKOUT_ERROR}
    Element Text Should Be    ${CHECKOUT_ERROR}    ${expected}

Overview Totals Should Be Correct
    [Documentation]    Step 2. Recalculates subtotal, 8% tax and total from the item prices
    ...                and compares them with what the page shows.
    Wait Until Element Is Visible    ${TOTAL_LABEL}
    ${texts}=    Get Element Texts    ${OVERVIEW_PRICES}
    ${item_prices}=    Prices From Texts    ${texts}
    ${subtotal}    ${tax}    ${total}=    Order Total    ${item_prices}
    Element Text Should Be    ${SUBTOTAL_LABEL}    Item total: $${subtotal}
    Element Text Should Be    ${TAX_LABEL}         Tax: $${tax}
    Element Text Should Be    ${TOTAL_LABEL}       Total: $${total}

Finish Order
    [Documentation]    Step 2: places the order.
    Click Button    ${FINISH_BUTTON}

Order Should Be Complete
    [Documentation]    Step 3.
    Wait Until Element Is Visible    ${COMPLETE_HEADER}
    Element Text Should Be    ${COMPLETE_HEADER}    Thank you for your order!
    Location Should Contain    ${COMPLETE_PATH}

Back To Products
    [Documentation]    Goes back to the product list after the order.
    Click Button    ${BACK_HOME_BUTTON}

Cancel Checkout
    [Documentation]    Cancels the checkout (on step 1 or 2).
    Click Button    ${CANCEL_BUTTON}
