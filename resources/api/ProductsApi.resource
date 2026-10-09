*** Settings ***
Documentation     Service object for the DummyJSON product endpoints (/products...).
...               DummyJSON only simulates writes: add, update and delete answer as if they
...               worked but nothing is stored.
Resource          ApiSession.resource


*** Keywords ***
Get Product
    [Documentation]    GET /products/{id}. Returns the response.
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
    ...                Returns the JSON body.
    [Arguments]    ${limit}=30    ${skip}=0    ${select}=${EMPTY}
    VAR    &{params}    limit=${limit}    skip=${skip}
    IF    $select    Set To Dictionary    ${params}    select=${select}
    ${response}=    GET On Session    ${SESSION}    /products    params=${params}
    RETURN    ${response.json()}

Add Product
    [Documentation]    POST /products/add with the fields given as named arguments,
    ...                e.g. ``title=Pen    price=${1.5}``. Expects 201 and returns the JSON body.
    [Arguments]    &{fields}
    ${response}=    POST On Session    ${SESSION}    /products/add    json=${fields}    expected_status=201
    RETURN    ${response.json()}

Update Product
    [Documentation]    PUT /products/{id} with only the fields to change. Returns the JSON body.
    [Arguments]    ${id}    &{fields}
    ${response}=    PUT On Session    ${SESSION}    /products/${id}    json=${fields}
    RETURN    ${response.json()}

Delete Product
    [Documentation]    DELETE /products/{id}. Returns the JSON body (the "deleted" product).
    [Arguments]    ${id}
    ${response}=    DELETE On Session    ${SESSION}    /products/${id}
    RETURN    ${response.json()}
