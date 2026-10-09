*** Settings ***
Documentation     DummyJSON authentication: token login, protected endpoint, bad credentials.
Resource          ../../resources/api/AuthApi.resource
Suite Setup       Create API Session
Suite Teardown    Close API Sessions
Test Tags         api    auth


*** Test Cases ***
Valid Login Returns Tokens And User
    [Tags]    smoke
    ${response}=    Login    ${API_USER}    ${API_PASSWORD}
    Response Should Have Fields    ${response.json()}
    ...    accessToken    refreshToken    id    username    email
    Should Be Equal    ${response.json()}[username]    ${API_USER}
    # A JWT has three dot-separated parts: header.payload.signature
    Should Match Regexp    ${response.json()}[accessToken]    ^[\\w-]+\\.[\\w-]+\\.[\\w-]+$

Token Gives Access To Current User
    ${token}=    Get Access Token    ${API_USER}    ${API_PASSWORD}
    ${response}=    Get Current User    ${token}
    Should Be Equal    ${response.json()}[username]    ${API_USER}

Current User Needs A Token
    [Documentation]    The keyword uses a fresh session: the login response also sets an
    ...                accessToken cookie, and the shared session would send it back.
    [Tags]    negative
    ${response}=    Get Current User Without Token
    Should Be Equal    ${response.json()}[message]    Access Token is required

Invalid Credentials Are Rejected
    [Tags]    negative
    [Template]    Login Should Be Rejected
    # username         password
    ${API_USER}        wrong-password
    unknown-user       ${API_PASSWORD}


*** Keywords ***
Login Should Be Rejected
    [Documentation]    Template: the login must fail with HTTP 400 and give no token.
    [Arguments]    ${username}    ${password}
    ${response}=    Login    ${username}    ${password}    expected_status=400
    Should Be Equal    ${response.json()}[message]    Invalid credentials
    Dictionary Should Not Contain Key    ${response.json()}    accessToken
