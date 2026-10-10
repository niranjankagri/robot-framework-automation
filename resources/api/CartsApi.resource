*** Settings ***
Documentation     Service object for the DummyJSON cart endpoints (/carts...).
...
...               Suites using it open the session with ``Create Authenticated API Session``
...               (from AuthApi), so every call here sends the Bearer token.
...               DummyJSON only simulates writes: a new cart is returned but not stored.
Resource          ApiSession.resource


*** Keywords ***
Get Cart By Id
    [Documentation]    GET /carts/{id}. Returns the cart as a dict (products, totals, userId).
    [Arguments]    ${id}
    # No expected_status: RequestsLibrary fails on any 4xx/5xx by default.
    ${response}=    GET On Session    ${SESSION}    /carts/${id}
    RETURN    ${response.json()}

Get Carts Of User
    [Documentation]    GET /carts/user/{user_id}. Returns the list of that user's carts.
    [Arguments]    ${user_id}
    ${response}=    GET On Session    ${SESSION}    /carts/user/${user_id}
    # The body wraps the list ({"carts": [...], "total": ...}); return only the list.
    RETURN    ${response.json()}[carts]

Create Cart With Product
    [Documentation]    POST /carts/add: a new cart for ${user_id} with ${quantity} pieces of
    ...                product ${product_id}. Fails unless the API answers 201;
    ...                returns the new cart as a dict.
    [Arguments]    ${user_id}    ${product_id}    ${quantity}
    # Body shape: {"userId": 1, "products": [{"id": 144, "quantity": 2}]}
    VAR    &{line}    id=${product_id}    quantity=${quantity}
    VAR    @{products}    ${line}
    VAR    &{body}    userId=${user_id}    products=${products}
    ${response}=    POST On Session    ${SESSION}    /carts/add    json=${body}    expected_status=201
    RETURN    ${response.json()}
