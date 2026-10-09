*** Settings ***
Documentation     Login and logout on Sauce Demo, access control, and the login error messages.
Resource          ../../resources/pages/LoginPage.resource
Resource          ../../resources/pages/InventoryPage.resource
Resource          ../../resources/components/HeaderComponent.resource
# A fresh browser per test keeps tests independent (no shared session or cookies).
# These tests start on the login page, so the setup does not log in.
Test Setup        Open Browser On Login Page
Test Teardown     Close All Test Browsers
Test Tags         ui    login


*** Test Cases ***
Standard User Can Log In
    [Documentation]    Valid credentials lead to the product list.
    [Tags]    smoke
    Submit Login Form    ${STANDARD_USER}    ${PASSWORD}
    Products Page Should Be Open

User Can Log Out
    [Documentation]    Logging out through the side menu returns to the login page.
    [Tags]    smoke
    Submit Login Form    ${STANDARD_USER}    ${PASSWORD}
    Products Page Should Be Open
    Log Out Through Side Menu
    Login Page Should Be Open

Logged Out User Cannot Open Products Page Directly
    [Documentation]    Access control: typing the products URL without logging in must
    ...                send the user back to the login page with an error.
    Open Products Page Directly
    Login Error Message Should Be    Epic sadface: You can only access '/inventory.html' when you are logged in.

Invalid Logins Show The Right Error
    [Documentation]    Data-driven: every row is one failed login attempt with the error it
    ...                must show. All rows run, even when one of them fails.
    [Tags]    negative
    [Template]    Login Should Fail With Error
    # username            password        expected error
    ${EMPTY}              ${EMPTY}        Epic sadface: Username is required
    ${STANDARD_USER}      ${EMPTY}        Epic sadface: Password is required
    ${STANDARD_USER}      wrong_pass      Epic sadface: Username and password do not match any user in this service
    unknown_user          ${PASSWORD}     Epic sadface: Username and password do not match any user in this service
    ${LOCKED_USER}        ${PASSWORD}     Epic sadface: Sorry, this user has been locked out.


*** Keywords ***
Login Should Fail With Error
    [Documentation]    Template for the rows above: reloads the login page (the rows share
    ...                one browser), submits the credentials and checks the error message.
    [Arguments]    ${username}    ${password}    ${expected_error}
    Open Login Page
    Submit Login Form    ${username}    ${password}
    Login Error Message Should Be    ${expected_error}
