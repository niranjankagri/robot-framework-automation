*** Settings ***
Documentation     Service object for the DummyJSON product endpoints (/products...):
...               read one, search, list a page, add, update, delete.
...
...               DummyJSON only simulates writes: add, update and delete answer as if they
...               worked, but nothing is stored.
Resource          ApiSession.resource


*** Keywords ***
Get Product By Id
    [Documentation]    GET /products/{id}. Returns the whole response, so tests can check
    ...                the status (${expected_status}, default 200) and the body.
    [Arguments]    ${id}    ${expected_status}=200
    ${response}=    GET On Session    ${SESSION}    /products/${id}    expected_status=${expected_status}
    RETURN    ${response}

Search Products
    [Documentation]    GET /products/search?q=${query}. Returns the result as a dict:
    ...                ``products`` (list), ``total``, ``skip``, ``limit``.
    [Arguments]    ${query}    ${limit}=30
    VAR    &{params}    q=${query}    limit=${limit}
    ${response}=    GET On Session    ${SESSION}    /products/search    params=${params}
    RETURN    ${response.json()}

List Products Page
    [Documentation]    GET /products: one page of ${limit} products after skipping ${skip}.
    ...                ${select} (e.g. ``title,price``) limits the fields of each product.
    ...                Returns the page as a dict: ``products`` (list), ``total``, ``skip``, ``limit``.
    [Arguments]    ${limit}=30    ${skip}=0    ${select}=${EMPTY}
    VAR    &{params}    limit=${limit}    skip=${skip}
    IF    $select    Set To Dictionary    ${params}    select=${select}
    ${response}=    GET On Session    ${SESSION}    /products    params=${params}
    RETURN    ${response.json()}

Add Product
    [Documentation]    POST /products/add with the fields given as named arguments,
    ...                e.g. ``title=Pen    price=${1.5}``. Fails unless the API answers 201;
    ...                returns the "created" product as a dict.
    [Arguments]    &{fields}
    ${response}=    POST On Session    ${SESSION}    /products/add    json=${fields}    expected_status=201
    RETURN    ${response.json()}

Update Product
    [Documentation]    PUT /products/{id} with only the fields to change, e.g. ``price=${12.5}``.
    ...                Returns the updated product as a dict.
    [Arguments]    ${id}    &{fields}
    ${response}=    PUT On Session    ${SESSION}    /products/${id}    json=${fields}
    RETURN    ${response.json()}

Delete Product
    [Documentation]    DELETE /products/{id}. Returns the "deleted" product as a dict,
    ...                with ``isDeleted`` and ``deletedOn`` added.
    [Arguments]    ${id}
    ${response}=    DELETE On Session    ${SESSION}    /products/${id}
    RETURN    ${response.json()}
