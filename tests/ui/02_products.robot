*** Settings ***
Documentation     Product list: number of products and sorting by name and price.
Resource          ../../resources/pages/LoginPage.resource
Resource          ../../resources/pages/InventoryPage.resource
# Every test here starts logged in, so the login is part of the setup, not the test.
Test Setup        Open Browser And Log In
Test Teardown     Close All Test Browsers
Test Tags         ui    products


*** Test Cases ***
Products Page Lists Six Products
    [Documentation]    The shop offers six products; a missing or extra card is a bug.
    [Tags]    smoke
    @{names}=    Get Displayed Product Names
    Length Should Be    ${names}    6

Default Sort Is Name A To Z
    [Documentation]    Without choosing a sort option, products are listed by name A to Z.
    @{names}=    Get Displayed Product Names
    Values Should Be Sorted    ${names}    ascending

Products Can Be Sorted
    [Documentation]    Data-driven: each row picks a sort option and checks that the names or
    ...                prices shown are in the expected order.
    [Template]    Selected Sort Option Should Order Products
    # sort option            sorted by    expected order
    Name (A to Z)            names        ascending
    Name (Z to A)            names        descending
    Price (low to high)      prices       ascending
    Price (high to low)      prices       descending


*** Keywords ***
Selected Sort Option Should Order Products
    [Documentation]    Template for the rows above: picks ${option} in the sort dropdown and
    ...                checks the order of the product ${field} ("names" or "prices").
    [Arguments]    ${option}    ${field}    ${order}
    Sort Products By    ${option}
    IF    '${field}' == 'names'
        ${values}=    Get Displayed Product Names
    ELSE
        # Prices are compared as numbers (Decimals): as text, "$9.99" would sort after "$15.99".
        ${values}=    Get Displayed Product Prices
    END
    Values Should Be Sorted    ${values}    ${order}
