*** Settings ***
Documentation     DummyJSON carts with an authenticated session: the cart maths must add up.
Resource          ../../resources/api/AuthApi.resource
Resource          ../../resources/api/CartsApi.resource
# The token is fetched once per suite, not per test: faster, and the login is
# already covered by the auth suite.
Suite Setup       Create Authenticated API Session
Suite Teardown    Close All API Sessions
Test Tags         api    carts


*** Test Cases ***
Cart Line Totals Add Up
    [Documentation]    Every line total is price x quantity, the cart total is the sum of
    ...                the lines, and totalProducts is the number of lines.
    [Tags]    smoke
    ${cart}=    Get Cart By Id    1
    # ${0} is the number 0 (not the text "0"), so it can be added to.
    VAR    ${sum_of_lines}    ${0}
    FOR    ${line}    IN    @{cart}[products]
        # line total = price x quantity (rounded to cents)
        ${expected_line_total}=    Evaluate    round($line['price'] * $line['quantity'], 2)
        # precision=2 compares to the cent, so float noise such as 0.30000000000000004 is ignored.
        Should Be Equal As Numbers    ${line}[total]    ${expected_line_total}    precision=2
        ${sum_of_lines}=    Evaluate    $sum_of_lines + $line['total']
    END
    # The cart total must be the sum of its lines, and each line counts as one product.
    Should Be Equal As Numbers    ${cart}[total]    ${sum_of_lines}    precision=2
    Should Be Equal As Integers    ${cart}[totalProducts]    ${{len($cart['products'])}}

New Cart Contains The Added Products
    [Documentation]    A new cart with 2 pieces of one product has the right quantity and total.
    # ${1}, ${144}, ${2} are numbers, so the JSON body sends numbers and not strings.
    ${cart}=    Create Cart With Product    user_id=${1}    product_id=${144}    quantity=${2}
    Should Be Equal As Integers    ${cart}[totalQuantity]    2
    Should Be Equal As Integers    ${cart}[products][0][id]    144
    # Total = the product's own price x 2; the price is taken from the response.
    Should Be Equal As Numbers    ${cart}[total]    ${{round($cart['products'][0]['price'] * 2, 2)}}

Carts Of A User Belong To That User
    [Documentation]    /carts/user/1 returns only carts whose userId is 1.
    ${carts}=    Get Carts Of User    1
    # A cart of another user in this list would be a data leak.
    FOR    ${cart}    IN    @{carts}
        Should Be Equal As Integers    ${cart}[userId]    1
    END
