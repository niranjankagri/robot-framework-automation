*** Settings ***
Documentation     DummyJSON products: read, search, paging and the write endpoints.
...               DummyJSON only simulates writes (nothing is stored), so the tests check
...               the response the API sends back, which is what a client would rely on.
Resource          ../../resources/api/DummyJsonApi.resource
Suite Setup       Create API Session
Suite Teardown    Close API Sessions
Test Tags         api    products


*** Test Cases ***
Get Product By Id
    [Tags]    smoke
    ${response}=    Get Product    1
    Response Should Have Fields    ${response.json()}
    ...    id    title    description    category    price    stock    rating
    Should Be Equal As Integers    ${response.json()}[id]    1
    Should Be True    ${response.json()}[price] > 0

Unknown Product Returns 404
    [Tags]    negative
    ${response}=    Get Product    999999    expected_status=404
    Should Be Equal    ${response.json()}[message]    Product with id '999999' not found

Search Finds Only Matching Products
    ${json}=    Search Products    phone
    Should Be True    ${json}[total] > 0
    FOR    ${product}    IN    @{json}[products]
        # The search covers title and description, so check both.
        ${text}=    Set Variable    ${product}[title] ${product}[description]
        Should Contain    ${text.lower()}    phone
    END

Paging Returns The Requested Slice
    [Documentation]    limit=5, skip=10 must return ids 11..15.
    ${json}=    List Products    limit=5    skip=10    select=title
    Length Should Be    ${json}[products]    5
    ${ids}=    Evaluate    [p['id'] for p in $json['products']]
    ${expected}=    Evaluate    list(range(11, 16))
    Lists Should Be Equal    ${ids}    ${expected}

Select Returns Only Requested Fields
    ${json}=    List Products    limit=3    select=title,price
    FOR    ${product}    IN    @{json}[products]
        ${keys}=    Get Dictionary Keys    ${product}    sort_keys=True
        # "id" is always included by DummyJSON.
        Lists Should Be Equal    ${keys}    ${{['id', 'price', 'title']}}
    END

Add Product Echoes The New Product
    ${body}=    Create Dictionary    title=Robot Test Product    price=${19.99}    category=testing
    ${response}=    POST On Session    ${SESSION}    /products/add    json=${body}    expected_status=201
    Should Be Equal    ${response.json()}[title]    Robot Test Product
    Should Be Equal As Numbers    ${response.json()}[price]    19.99
    Dictionary Should Contain Key    ${response.json()}    id

Update Product Changes Only The Sent Field
    ${before}=    Get Product    1
    ${body}=    Create Dictionary    price=${12.5}
    ${response}=    PUT On Session    ${SESSION}    /products/1    json=${body}
    Should Be Equal As Numbers    ${response.json()}[price]    12.5
    Should Be Equal    ${response.json()}[title]    ${before.json()}[title]

Delete Product Marks It As Deleted
    ${response}=    DELETE On Session    ${SESSION}    /products/1
    Should Be True    ${response.json()}[isDeleted]
    Dictionary Should Contain Key    ${response.json()}    deletedOn
