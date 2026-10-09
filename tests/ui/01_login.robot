*** Settings ***
Documentation     Login and logout on Sauce Demo, including the error messages.
Resource          ../../resources/pages/LoginPage.resource
Resource          ../../resources/pages/InventoryPage.resource
# A fresh browser per test keeps tests independent (no shared session or cookies).
Test Setup        Open Shop
Test Teardown     Close Shop
Test Tags         ui    login


*** Test Cases ***
Standard User Can Log In
    [Tags]    smoke
    Login As    ${STANDARD_USER}    ${PASSWORD}
    Products Page Should Be Open

User Can Log Out
    [Tags]    smoke
    Login As    ${STANDARD_USER}    ${PASSWORD}
    Products Page Should Be Open
    Logout
    Login Page Should Be Open

Logged Out User Cannot Open Products Page Directly
    [Documentation]    Access control: the products URL must send an anonymous user back to login.
    Go To    ${UI_URL}/inventory.html
    Login Error Should Be    Epic sadface: You can only access '/inventory.html' when you are logged in.

Invalid Logins Show The Right Error
    [Documentation]    Data-driven: one row per case, same steps for every row.
    [Tags]    negative
    [Template]    Login Should Fail With
    # username            password        expected error
    ${EMPTY}              ${EMPTY}        Epic sadface: Username is required
    ${STANDARD_USER}      ${EMPTY}        Epic sadface: Password is required
    ${STANDARD_USER}      wrong_pass      Epic sadface: Username and password do not match any user in this service
    unknown_user          ${PASSWORD}     Epic sadface: Username and password do not match any user in this service
    ${LOCKED_USER}        ${PASSWORD}     Epic sadface: Sorry, this user has been locked out.


*** Keywords ***
Login Should Fail With
    [Documentation]    Template keyword: reloads the login page, tries the login, checks the error.
    [Arguments]    ${username}    ${password}    ${expected_error}
    Go To    ${UI_URL}
    Login As    ${username}    ${password}
    Login Error Should Be    ${expected_error}
