*** Settings ***
Documentation     Login and logout on Pattern Shop, access control, and the login error messages.
Resource          ../../resources/pages/LoginPage.resource
Resource          ../../resources/pages/InventoryPage.resource
Resource          ../../resources/components/HeaderComponent.resource
# A fresh browser per test keeps tests independent (no shared session or cookies).
# These tests start on the login page, so the setup does not log in.
Test Setup        Open Browser On Login Page
# The teardown runs even when the test fails, so no browser is left open.
Test Teardown     Close All Test Browsers
Test Tags         ui    login


*** Test Cases ***
[TC-101] Standard User Can Log In
    [Documentation]    Valid credentials lead to the product list.
    [Tags]    smoke    TC-101
    Submit Login Form    ${STANDARD_USER}    ${PASSWORD}
    # Landing on the product list is the proof that the login worked.
    Products Page Should Be Open

[TC-102] User Can Log Out
    [Documentation]    Signing out with the header button returns to the login page.
    [Tags]    smoke    TC-102
    # Log in first and make sure it worked, so a failure below is really about logging out.
    Submit Login Form    ${STANDARD_USER}    ${PASSWORD}
    Products Page Should Be Open
    Log Out Through Header
    Login Page Should Be Open

[TC-103] Logged Out User Cannot Open Products Page Directly
    [Documentation]    Access control: typing the products URL without logging in must
    ...                send the user back to the login page with an error.
    [Tags]    TC-103
    # Skip the login form and go straight to a page that needs a login.
    Open Products Page Directly
    # The shop redirects to the login page and asks the visitor to sign in.
    Login Error Message Should Be    Please sign in to see that page.

[TC-104] Invalid Logins Show The Right Error
    [Documentation]    Data-driven: every row is one failed login attempt with the error it
    ...                must show. All rows run, even when one of them fails.
    [Tags]    negative    TC-104
    # Each row below is one call of the template keyword with these arguments.
    [Template]    Login Should Fail With Error
    # username            password        expected error
    ${EMPTY}              ${EMPTY}        User name and password are required.
    ${STANDARD_USER}      ${EMPTY}        User name and password are required.
    ${STANDARD_USER}      wrong_pass      User name and password do not match any user.
    unknown_user          ${PASSWORD}     User name and password do not match any user.
    ${LOCKED_USER}        ${PASSWORD}     This user has been locked out.


*** Keywords ***
Login Should Fail With Error
    [Documentation]    Template for the rows above: reloads the login page (the rows share
    ...                one browser), submits the credentials and checks the error message.
    [Arguments]    ${username}    ${password}    ${expected_error}
    # Reload so the error of the previous row is gone before this attempt.
    Open Login Page
    Submit Login Form    ${username}    ${password}
    Login Error Message Should Be    ${expected_error}
