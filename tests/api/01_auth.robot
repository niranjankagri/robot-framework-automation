*** Settings ***
Documentation     DummyJSON authentication: token login, protected endpoint, bad credentials.
Resource          ../../resources/api/AuthApi.resource
# One HTTP session for the whole suite: opened before the first test, closed after the last.
Suite Setup       Create API Session
Suite Teardown    Close All API Sessions
# Every test here is an API test of the auth area; extra tags are added per test.
Test Tags         api    auth


*** Test Cases ***
[TC-201] Valid Login Returns Tokens And User
    [Documentation]    A valid login returns an access token (a JWT), a refresh token and the user.
    [Tags]    smoke    TC-201
    # Log in with the test user DummyJSON publishes in its docs.
    ${response}=    Send Login Request    ${API_USER}    ${API_PASSWORD}
    # Contract check: both tokens and the user's basic fields must be in the body.
    JSON Should Contain Fields    ${response.json()}
    ...    accessToken    refreshToken    id    username    email
    # The tokens must belong to the user who logged in, not to someone else.
    Should Be Equal    ${response.json()}[username]    ${API_USER}
    # A JWT has three dot-separated parts: header.payload.signature
    Should Match Regexp    ${response.json()}[accessToken]    ^[\\w-]+\\.[\\w-]+\\.[\\w-]+$

[TC-202] Token Gives Access To Current User
    [Documentation]    The access token opens the protected /auth/me endpoint for that user.
    [Tags]    TC-202
    # Step 1: log in and keep only the token.
    ${token}=    Get Access Token    ${API_USER}    ${API_PASSWORD}
    # Step 2: call the protected endpoint with it; it must say who the token belongs to.
    ${response}=    Get Current User With Token    ${token}
    Should Be Equal    ${response.json()}[username]    ${API_USER}

[TC-203] Current User Needs A Token
    [Documentation]    /auth/me without a token is refused with 401.
    ...                The keyword uses a fresh session: the login response also sets an
    ...                accessToken cookie, and the shared session would send it back.
    [Tags]    negative    TC-203
    # The keyword already fails on any status but 401; here the reason is checked too.
    ${response}=    Get Current User Without Token
    Should Be Equal    ${response.json()}[message]    Access Token is required

[TC-204] Invalid Credentials Are Rejected
    [Documentation]    Data-driven: a wrong password or an unknown user gets 400 and no token.
    [Tags]    negative    TC-204
    # Each row below is one call of the template keyword with these arguments.
    [Template]    Login Should Be Rejected With 400
    # username         password
    ${API_USER}        wrong-password
    unknown-user       ${API_PASSWORD}


*** Keywords ***
Login Should Be Rejected With 400
    [Documentation]    Template for the rows above: the login must fail with HTTP 400,
    ...                say "Invalid credentials" and give no token.
    [Arguments]    ${username}    ${password}
    # expected_status=400 makes RequestsLibrary fail the step on any other status.
    ${response}=    Send Login Request    ${username}    ${password}    expected_status=400
    Should Be Equal    ${response.json()}[message]    Invalid credentials
    # A rejected login must never hand out a token.
    Dictionary Should Not Contain Key    ${response.json()}    accessToken
