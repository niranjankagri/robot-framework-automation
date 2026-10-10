*** Settings ***
Documentation     HTTP session handling for DummyJSON (https://dummyjson.com).
...
...               The API side follows the same idea as the page objects on the UI side:
...               every endpoint group has its own "service object" resource
...               (AuthApi, ProductsApi, CartsApi) and tests only call those keywords.
...               This file holds what they all share: the session alias and how
...               sessions are opened and closed.
# API_URL, API_USER and API_PASSWORD come from the shared config file.
Variables         ../../variables/config.py
# Collections: Dictionary Should Contain Key. RequestsLibrary: the HTTP calls.
Library           Collections
Library           RequestsLibrary


*** Variables ***
# Alias of the suite's shared session. One session per suite reuses the TCP connection.
${SESSION}              dummyjson
# A separate alias for calls that must not carry the cookie DummyJSON sets on login.
${ANONYMOUS_SESSION}    anonymous


*** Keywords ***
Create API Session
    [Documentation]    Opens the suite's shared session without a token, for public endpoints.
    ...
    ...                ``disable_warnings=1`` silences urllib3 noise in the log;
    ...                ``max_retries=2`` rides out a dropped connection on the public API.
    Create Session    ${SESSION}    ${API_URL}    disable_warnings=1    max_retries=2

Create Anonymous API Session
    [Documentation]    Opens a second session that has never logged in.
    ...
    ...                DummyJSON's login also sets an ``accessToken`` cookie, so the shared
    ...                session is authenticated after any login. "No token" checks use this one.
    Create Session    ${ANONYMOUS_SESSION}    ${API_URL}    disable_warnings=1    max_retries=2

Create Session With Bearer Token
    [Documentation]    Re-creates the shared session so that every request sends
    ...                ``Authorization: Bearer ${token}``.
    [Arguments]    ${token}
    # Headers given to Create Session are sent with every request of that session.
    VAR    &{headers}    Authorization=Bearer ${token}
    # Same alias as Create API Session: the service objects keep using ${SESSION}.
    Create Session    ${SESSION}    ${API_URL}    headers=${headers}    disable_warnings=1    max_retries=2

Close All API Sessions
    [Documentation]    Closes every HTTP session of the suite. Used as suite teardown.
    Delete All Sessions

JSON Should Contain Fields
    [Documentation]    Lightweight contract check: fails if any of @{fields} is missing
    ...                from the JSON object ${json_object} (a dict). Extra fields are allowed.
    [Arguments]    ${json_object}    @{fields}
    # One check per field, so the error names exactly the field that is missing.
    FOR    ${field}    IN    @{fields}
        Dictionary Should Contain Key    ${json_object}    ${field}    Missing field '${field}'
    END
