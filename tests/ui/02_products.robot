*** Settings ***
Documentation     Product list: sorting by name and price.
Resource          ../../resources/pages/LoginPage.resource
Resource          ../../resources/pages/InventoryPage.resource
# Every test here starts logged in, so the login is part of the setup, not the test.
Test Setup        Open Shop And Log In
Test Teardown     Close Shop
Test Tags         ui    products


*** Test Cases ***
Products Page Lists Six Products
    [Tags]    smoke
    @{names}=    Get Product Names
    Length Should Be    ${names}    6

Default Sort Is Name A To Z
    @{names}=    Get Product Names
    Should Be Sorted    ${names}    ascending

Products Can Be Sorted
    [Documentation]    Data-driven: sort option, what to read, expected order.
    [Template]    Sorting Should Order Products
    Name (A to Z)            names     ascending
    Name (Z to A)            names     descending
    Price (low to high)      prices    ascending
    Price (high to low)      prices    descending


*** Keywords ***
Sorting Should Order Products
    [Documentation]    Template: picks a sort option and checks the order of names or prices.
    [Arguments]    ${option}    ${field}    ${order}
    Sort Products By    ${option}
    IF    '${field}' == 'names'
        ${values}=    Get Product Names
    ELSE
        ${values}=    Get Product Prices
    END
    Should Be Sorted    ${values}    ${order}
