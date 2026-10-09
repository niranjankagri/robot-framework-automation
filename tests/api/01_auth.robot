*** Settings ***
Documentation     DummyJSON authentication: token login, protected endpoint, bad credentials.
Resource          ../../resources/api/AuthApi.resource
Suite Setup       Create API Session
Suite Teardown    Close All API Sessions
Test Tags         api    auth


*** Test Cases ***
Valid Login Returns Tokens And User
    [Documentation]    A valid login returns an access token (a JWT), a refresh token and the user.
    [Tags]    smoke
    ${response}=    Send Login Request    ${API_USER}    ${API_PASSWORD}
    JSON Should Contain Fields    ${response.json()}
    ...    accessToken    refreshToken    id    username    email
    Should Be Equal    ${response.json()}[username]    ${API_USER}
    # A JWT has three dot-separated parts: header.payload.signature
    Should Match Regexp    ${response.json()}[accessToken]    ^[\\w-]+\\.[\\w-]+\\.[\\w-]+$

Token Gives Access To Current User
    [Documentation]    The access token opens the protected /auth/me endpoint for that user.
    ${token}=    Get Access Token    ${API_USER}    ${API_PASSWORD}
    ${response}=    Get Current User With Token    ${token}
    Should Be Equal    ${response.json()}[username]    ${API_USER}

Current User Needs A Token
    [Documentation]    /auth/me without a token is refused with 401.
    ...                The keyword uses a fresh session: the login response also sets an
    ...                accessToken cookie, and the shared session would send it back.
    [Tags]    negative
    ${response}=    Get Current User Without Token
    Should Be Equal    ${response.json()}[message]    Access Token is required

Invalid Credentials Are Rejected
    [Documentation]    Data-driven: a wrong password or an unknown user gets 400 and no token.
    [Tags]    negative
    [Template]    Login Should Be Rejected With 400
    # username         password
    ${API_USER}        wrong-password
    unknown-user       ${API_PASSWORD}


*** Keywords ***
Login Should Be Rejected With 400
    [Documentation]    Template for the rows above: the login must fail with HTTP 400,
    ...                say "Invalid credentials" and give no token.
    [Arguments]    ${username}    ${password}
    ${response}=    Send Login Request    ${username}    ${password}    expected_status=400
    Should Be Equal    ${response.json()}[message]    Invalid credentials
    Dictionary Should Not Contain Key    ${response.json()}    accessToken
