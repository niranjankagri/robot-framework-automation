*** Settings ***
Documentation     Service object for the DummyJSON auth endpoints:
...               POST /auth/login (get tokens) and GET /auth/me (who am I, needs a token).
Resource          ApiSession.resource


*** Keywords ***
Send Login Request
    [Documentation]    POST /auth/login with ${username} and ${password}.
    ...
    ...                Returns the whole response, because tests check the status and the body.
    ...                ${expected_status} defaults to 200; negative tests pass 400.
    ...                The token is asked to expire after 30 minutes.
    [Arguments]    ${username}    ${password}    ${expected_status}=200
    # ${30} is a number, so the JSON body sends "expiresInMins": 30 and not "30".
    VAR    &{body}    username=${username}    password=${password}    expiresInMins=${30}
    # json= sends the dict as a JSON body with the matching Content-Type header.
    ${response}=    POST On Session    ${SESSION}    /auth/login    json=${body}    expected_status=${expected_status}
    RETURN    ${response}

Get Access Token
    [Documentation]    Logs in and returns only the access token (a JWT string).
    [Arguments]    ${username}    ${password}
    ${response}=    Send Login Request    ${username}    ${password}
    # A clear "missing key" failure here beats a confusing error in the next request.
    Dictionary Should Contain Key    ${response.json()}    accessToken
    RETURN    ${response.json()}[accessToken]

Get Current User With Token
    [Documentation]    GET /auth/me with ${token} in the Authorization header.
    ...                Returns the response (body: the logged-in user).
    [Arguments]    ${token}
    # The header is added to this one request only; the session itself stays unchanged.
    VAR    &{headers}    Authorization=Bearer ${token}
    ${response}=    GET On Session    ${SESSION}    /auth/me    headers=${headers}
    RETURN    ${response}

Get Current User Without Token
    [Documentation]    GET /auth/me from a session that never logged in (no header, no cookie).
    ...                Fails unless the API answers 401; returns the response for further checks.
    Create Anonymous API Session
    # expected_status=401: a 200 here would mean the endpoint is not protected.
    ${response}=    GET On Session    ${ANONYMOUS_SESSION}    /auth/me    expected_status=401
    RETURN    ${response}

Create Authenticated API Session
    [Documentation]    Suite setup for protected endpoints: logs in once and makes the
    ...                shared session send the Bearer token with every request.
    # A plain session is needed first, to send the login request itself.
    Create API Session
    ${token}=    Get Access Token    ${API_USER}    ${API_PASSWORD}
    Create Session With Bearer Token    ${token}
