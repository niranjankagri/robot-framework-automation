*** Settings ***
Documentation     HTTP session handling for DummyJSON (https://dummyjson.com).
...
...               The API side follows the same idea as the page objects on the UI side:
...               every endpoint group has its own "service object" resource
...               (AuthApi, ProductsApi, CartsApi) and tests only call those keywords.
...               This file holds what they all share: the session alias and how
...               sessions are opened and closed.
Variables         ../../variables/config.py
Library           Collections
Library           RequestsLibrary


*** Variables ***
# Alias of the suite's shared session. One session per suite reuses the TCP connection.
${SESSION}            dummyjson
# A separate alias for calls that must not carry the cookie DummyJSON sets on login.
${ANONYMOUS_SESSION}  anonymous


*** Keywords ***
Create API Session
    [Documentation]    Plain session without a token, for public endpoints.
    ...                disable_warnings=1 silences urllib3 noise in the log;
    ...                max_retries=2 rides out a dropped connection on the public API.
    Create Session    ${SESSION}    ${API_URL}    disable_warnings=1    max_retries=2

Create Anonymous API Session
    [Documentation]    Fresh session that has never logged in. DummyJSON's login also sets
    ...                an accessToken cookie, so the shared session would be authenticated
    ...                after any login; "no token" checks must use this one.
    Create Session    ${ANONYMOUS_SESSION}    ${API_URL}    disable_warnings=1    max_retries=2

Create Bearer Session
    [Documentation]    (Re)creates the shared session so it sends ${token} as a Bearer
    ...                header with every request.
    [Arguments]    ${token}
    VAR    &{headers}    Authorization=Bearer ${token}
    Create Session    ${SESSION}    ${API_URL}    headers=${headers}    disable_warnings=1    max_retries=2

Close API Sessions
    [Documentation]    Closes every HTTP session of the suite.
    Delete All Sessions

Response Should Have Fields
    [Documentation]    Lightweight contract check: every listed key exists in ${json}.
    [Arguments]    ${json}    @{fields}
    FOR    ${field}    IN    @{fields}
        Dictionary Should Contain Key    ${json}    ${field}    Missing field '${field}'
    END
