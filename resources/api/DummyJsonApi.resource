*** Settings ***
Documentation     API keywords for DummyJSON (https://dummyjson.com).
...               One HTTP session per suite (connection reuse), token login, and small
...               keywords per endpoint so the tests read like the API documentation.
Variables         ../../variables/config.py
Library           Collections
Library           RequestsLibrary


*** Variables ***
${SESSION}        dummyjson


*** Keywords ***
Create API Session
    [Documentation]    Plain session without a token, for public endpoints.
    ...                disable_warnings=1 silences urllib3 noise in the log.
    Create Session    ${SESSION}    ${API_URL}    disable_warnings=1    max_retries=2

Create Authenticated API Session
    [Documentation]    Logs in once and creates a session that sends the Bearer token
    ...                with every request.
    Create API Session
    ${token}=    Get Access Token    ${API_USER}    ${API_PASSWORD}
    VAR    &{headers}    Authorization=Bearer ${token}
    Create Session    ${SESSION}    ${API_URL}    headers=${headers}    disable_warnings=1    max_retries=2

Close API Sessions
    [Documentation]    Closes every HTTP session of the suite.
    Delete All Sessions

Login
    [Documentation]    POST /auth/login. Returns the response; the caller checks the status
    ...                via ${expected_status} (default 200, "anything" for negative tests).
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

Get Product
    [Documentation]    GET /products/{id}.
    [Arguments]    ${id}    ${expected_status}=200
    ${response}=    GET On Session    ${SESSION}    /products/${id}    expected_status=${expected_status}
    RETURN    ${response}

Search Products
    [Documentation]    GET /products/search?q=... Returns the JSON body.
    [Arguments]    ${query}    ${limit}=30
    VAR    &{params}    q=${query}    limit=${limit}
    ${response}=    GET On Session    ${SESSION}    /products/search    params=${params}
    RETURN    ${response.json()}

List Products
    [Documentation]    GET /products with paging (limit/skip) and an optional field selection.
    [Arguments]    ${limit}=30    ${skip}=0    ${select}=${EMPTY}
    VAR    &{params}    limit=${limit}    skip=${skip}
    IF    $select    Set To Dictionary    ${params}    select=${select}
    ${response}=    GET On Session    ${SESSION}    /products    params=${params}
    RETURN    ${response.json()}

Response Should Have Fields
    [Documentation]    Lightweight contract check: every listed key exists in ${json}.
    [Arguments]    ${json}    @{fields}
    FOR    ${field}    IN    @{fields}
        Dictionary Should Contain Key    ${json}    ${field}    Missing field '${field}'
    END
