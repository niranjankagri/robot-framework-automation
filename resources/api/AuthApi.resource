*** Settings ***
Documentation     Service object for the DummyJSON auth endpoints (/auth/login, /auth/me).
Resource          ApiSession.resource


*** Keywords ***
Login
    [Documentation]    POST /auth/login. Returns the response; the caller sets the expected
    ...                status (default 200, 400 for the negative tests).
    [Arguments]    ${username}    ${password}    ${expected_status}=200
    VAR    &{body}    username=${username}    password=${password}    expiresInMins=${30}
    ${response}=    POST On Session    ${SESSION}    /auth/login    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Get Access Token
    [Documentation]    Logs in and returns only the access token (JWT).
    [Arguments]    ${username}    ${password}
    ${response}=    Login    ${username}    ${password}
    Dictionary Should Contain Key    ${response.json()}    accessToken
    RETURN    ${response.json()}[accessToken]

Get Current User
    [Documentation]    GET /auth/me with the given token in the Authorization header.
    [Arguments]    ${token}
    VAR    &{headers}    Authorization=Bearer ${token}
    ${response}=    GET On Session    ${SESSION}    /auth/me    headers=${headers}
    RETURN    ${response}

Get Current User Without Token
    [Documentation]    GET /auth/me from a session that never logged in (no header, no cookie).
    ...                Returns the response; the call must be refused with 401.
    Create Anonymous API Session
    ${response}=    GET On Session    ${ANONYMOUS_SESSION}    /auth/me    expected_status=401
    RETURN    ${response}

Create Authenticated API Session
    [Documentation]    Suite setup for protected endpoints: logs in once and makes the
    ...                shared session send the Bearer token with every request.
    Create API Session
    ${token}=    Get Access Token    ${API_USER}    ${API_PASSWORD}
    Create Bearer Session    ${token}
