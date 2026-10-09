*** Settings ***
Documentation     DummyJSON carts with an authenticated session: the cart maths must add up.
Resource          ../../resources/api/DummyJsonApi.resource
# The token is fetched once per suite, not per test: faster, and the login is
# already covered by the auth suite.
Suite Setup       Create Authenticated API Session
Suite Teardown    Close API Sessions
Test Tags         api    carts


*** Test Cases ***
Cart Line Totals Add Up
    [Tags]    smoke
    ${response}=    GET On Session    ${SESSION}    /carts/1
    ${cart}=    Set Variable    ${response.json()}
    ${sum}=    Set Variable    ${0}
    FOR    ${line}    IN    @{cart}[products]
        # line total = price x quantity (rounded to cents)
        ${expected_line}=    Evaluate    round($line['price'] * $line['quantity'], 2)
        Should Be Equal As Numbers    ${line}[total]    ${expected_line}    precision=2
        ${sum}=    Evaluate    $sum + $line['total']
    END
    Should Be Equal As Numbers    ${cart}[total]    ${sum}    precision=2
    Should Be Equal As Integers    ${cart}[totalProducts]    ${{len($cart['products'])}}

New Cart Contains The Added Products
    ${line}=    Create Dictionary    id=${144}    quantity=${2}
    ${products}=    Create List    ${line}
    ${body}=    Create Dictionary    userId=${1}    products=${products}
    ${response}=    POST On Session    ${SESSION}    /carts/add    json=${body}    expected_status=201
    ${cart}=    Set Variable    ${response.json()}
    Should Be Equal As Integers    ${cart}[totalQuantity]    2
    Should Be Equal As Integers    ${cart}[products][0][id]    144
    Should Be Equal As Numbers    ${cart}[total]    ${{round($cart['products'][0]['price'] * 2, 2)}}

Carts Of A User Belong To That User
    ${response}=    GET On Session    ${SESSION}    /carts/user/1
    FOR    ${cart}    IN    @{response.json()}[carts]
        Should Be Equal As Integers    ${cart}[userId]    1
    END
