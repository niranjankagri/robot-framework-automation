*** Settings ***
Documentation     DummyJSON products: read, search, paging and the write endpoints.
...               DummyJSON only simulates writes (nothing is stored), so the tests check
...               the response the API sends back, which is what a client would rely on.
Resource          ../../resources/api/ProductsApi.resource
# The product endpoints are public, so a session without a token is enough.
Suite Setup       Create API Session
Suite Teardown    Close All API Sessions
Test Tags         api    products


*** Test Cases ***
Product Can Be Fetched By Id
    [Documentation]    A product has the fields a shop client needs, and a positive price.
    [Tags]    smoke
    ${response}=    Get Product By Id    1
    # Contract check: the fields a product page would show must all be there.
    JSON Should Contain Fields    ${response.json()}
    ...    id    title    description    category    price    stock    rating
    # The API must return the product that was asked for, with a sensible price.
    Should Be Equal As Integers    ${response.json()}[id]    1
    Should Be True    ${response.json()}[price] > 0

Unknown Product Returns 404
    [Documentation]    An id that does not exist gets 404 with a clear message.
    [Tags]    negative
    # An id far above the catalogue size, so it cannot exist.
    ${response}=    Get Product By Id    999999    expected_status=404
    Should Be Equal    ${response.json()}[message]    Product with id '999999' not found

Search Finds Only Matching Products
    [Documentation]    Searching "phone" finds products, and each of them mentions "phone".
    ${search_result}=    Search Products    phone
    # An empty result would let the loop below pass without checking anything.
    Should Be True    ${search_result}[total] > 0
    FOR    ${product}    IN    @{search_result}[products]
        # The search covers title and description, so check both.
        VAR    ${text}    ${product}[title] ${product}[description]
        # Lower-case first: "Phone" in a title is a match too.
        Should Contain    ${text.lower()}    phone
    END

Paging Returns The Requested Slice
    [Documentation]    limit=5, skip=10 must return exactly the products with ids 11..15.
    # select=title keeps the response small; only the ids are checked.
    ${page}=    List Products Page    limit=5    skip=10    select=title
    Length Should Be    ${page}[products]    5
    # Collect the ids and compare them, in order, with the range 11..15.
    ${ids}=    Evaluate    [product['id'] for product in $page['products']]
    ${expected}=    Evaluate    list(range(11, 16))
    Lists Should Be Equal    ${ids}    ${expected}

Select Returns Only Requested Fields
    [Documentation]    select=title,price trims every product to those fields (plus id).
    ${page}=    List Products Page    limit=3    select=title,price
    FOR    ${product}    IN    @{page}[products]
        # Sorted keys, so the check does not depend on the field order in the JSON.
        ${keys}=    Get Dictionary Keys    ${product}    sort_keys=True
        # "id" is always included by DummyJSON.
        Lists Should Be Equal    ${keys}    ${{['id', 'price', 'title']}}
    END

Add Product Echoes The New Product
    [Documentation]    Adding a product answers 201 with the sent fields and a new id.
    # ${19.99} is a number, not the text "19.99", so the JSON body sends a number.
    ${product}=    Add Product    title=Robot Test Product    price=${19.99}    category=testing
    # The response must echo what was sent and give the product an id.
    Should Be Equal    ${product}[title]    Robot Test Product
    Should Be Equal As Numbers    ${product}[price]    19.99
    Dictionary Should Contain Key    ${product}    id

Update Product Changes Only The Sent Field
    [Documentation]    A PUT with only a new price changes the price and keeps the other fields.
    # Read the product first, to compare the unchanged fields afterwards.
    ${before}=    Get Product By Id    1
    ${after}=    Update Product    1    price=${12.5}
    Should Be Equal As Numbers    ${after}[price]    12.5
    # Fields that were not sent must stay as they were.
    Should Be Equal    ${after}[title]    ${before.json()}[title]

Delete Product Marks It As Deleted
    [Documentation]    Deleting answers with the product marked as deleted, with a timestamp.
    ${product}=    Delete Product    1
    # DummyJSON adds these two fields to the deleted product it sends back.
    Should Be True    ${product}[isDeleted]
    Dictionary Should Contain Key    ${product}    deletedOn
