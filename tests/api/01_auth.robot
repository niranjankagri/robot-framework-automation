*** Settings ***
Documentation     DummyJSON authentication: token login, protected endpoint, bad credentials.
Resource          ../../resources/api/DummyJsonApi.resource
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
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    GET On Session    ${SESSION}    /auth/me    headers=${headers}
    Should Be Equal    ${response.json()}[username]    ${API_USER}

Current User Needs A Token
    [Documentation]    Uses its own fresh session: the login response also sets an accessToken
    ...                cookie, and the shared session would send it back and be authenticated.
    [Tags]    negative
    Create Session    anonymous    ${API_URL}    disable_warnings=1
    ${response}=    GET On Session    anonymous    /auth/me    expected_status=401
    Should Be Equal    ${response.json()}[message]    Access Token is required

Invalid Credentials Are Rejected
    [Tags]    negative
    [Template]    Login Should Be Rejected
    ${API_USER}        wrong-password
    unknown-user       ${API_PASSWORD}


*** Keywords ***
Login Should Be Rejected
    [Arguments]    ${username}    ${password}
    ${response}=    Login    ${username}    ${password}    expected_status=400
    Should Be Equal    ${response.json()}[message]    Invalid credentials
    Dictionary Should Not Contain Key    ${response.json()}    accessToken
