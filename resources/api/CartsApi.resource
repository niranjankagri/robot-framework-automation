*** Settings ***
Documentation     Service object for the DummyJSON cart endpoints (/carts...).
...               Suites using it open the session with Create Authenticated API Session
...               (from AuthApi), so every call here sends the Bearer token.
Resource          ApiSession.resource


*** Keywords ***
Get Cart
    [Documentation]    GET /carts/{id}. Returns the JSON body.
    [Arguments]    ${id}
    ${response}=    GET On Session    ${SESSION}    /carts/${id}
    RETURN    ${response.json()}

Get Carts Of User
    [Documentation]    GET /carts/user/{user_id}. Returns the list of carts.
    [Arguments]    ${user_id}
    ${response}=    GET On Session    ${SESSION}    /carts/user/${user_id}
    RETURN    ${response.json()}[carts]

Add Cart
    [Documentation]    POST /carts/add for ${user_id} with one product line.
    ...                Expects 201 and returns the new cart (JSON body).
    [Arguments]    ${user_id}    ${product_id}    ${quantity}
    VAR    &{line}    id=${product_id}    quantity=${quantity}
    VAR    @{products}    ${line}
    VAR    &{body}    userId=${user_id}    products=${products}
    ${response}=    POST On Session    ${SESSION}    /carts/add    json=${body}    expected_status=201
    RETURN    ${response.json()}
