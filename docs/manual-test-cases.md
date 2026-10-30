# Manual test cases

The test cases this project automates, written as a tester would run them by hand. Every case has an
ID; the Robot test that covers it starts with the same ID (`[TC-112] User Can Buy Two Products`) and
carries it as a tag, so a failure in the report leads straight to the case below, and one case runs
with `robot -A args/common.args --include TC-112 tests`. Data-driven tests (`[Template]`) are one case
with several data sets.

| ID range | Area | Automated in |
|---|---|---|
| TC-101 to TC-115 | Sauce Demo shop in the browser | `tests/ui/*.robot` (SeleniumLibrary) |
| TC-201 to TC-215 | DummyJSON REST API | `tests/api/*.robot` (RequestsLibrary) |

## Setup

- Shop: <https://www.saucedemo.com>, password `secret_sauce`; users `standard_user`, `locked_out_user`.
  Every UI case starts logged in as `standard_user` on the products page, except the login cases.
- API: <https://dummyjson.com>, user `emilys` / `emilyspass`. DummyJSON fakes writes: add, update
  and delete answer as if they worked, but nothing is stored.
- Tax on the shop's overview: 8 % of the item total, rounded to cents.

## Summary

| ID | Title | Type | Priority |
|---|---|---|---|
| TC-101 | Standard user can log in | UI / Smoke | High |
| TC-102 | User can log out | UI / Smoke | High |
| TC-103 | Logged-out user cannot open the products page directly | UI / Security | High |
| TC-104 | Invalid logins show the right error (5 data sets) | UI / Negative | High |
| TC-105 | Products page lists six products | UI / Smoke | High |
| TC-106 | Default sort is name A to Z | UI | Low |
| TC-107 | Products can be sorted (4 data sets) | UI | Medium |
| TC-108 | Added products appear in the cart | UI / Smoke | High |
| TC-109 | Removing a product updates the badge | UI | Medium |
| TC-110 | The cart is empty for a new session | UI | Medium |
| TC-111 | The cart keeps products after Continue Shopping | UI | Medium |
| TC-112 | User can buy two products (end to end) | UI / Smoke / E2E | High |
| TC-113 | Order totals include eight percent tax | UI | High |
| TC-114 | Cancel on the overview keeps the cart | UI | Medium |
| TC-115 | Customer information is required (3 data sets) | UI / Negative | High |
| TC-201 | Valid login returns tokens and the user | API / Smoke | High |
| TC-202 | The token gives access to the current user | API | High |
| TC-203 | The current user needs a token | API / Security | High |
| TC-204 | Invalid credentials are rejected (2 data sets) | API / Negative | High |
| TC-205 | A product can be fetched by id | API / Smoke | High |
| TC-206 | Unknown product returns 404 | API / Negative | Low |
| TC-207 | Search finds only matching products | API | Medium |
| TC-208 | Paging returns the requested slice | API | Medium |
| TC-209 | Select returns only the requested fields | API | Low |
| TC-210 | Add product echoes the new product | API | Medium |
| TC-211 | Update changes only the sent field | API | Medium |
| TC-212 | Delete marks the product as deleted | API | Medium |
| TC-213 | Cart line totals add up | API / Smoke | High |
| TC-214 | A new cart contains the added products | API | Medium |
| TC-215 | The carts of a user belong to that user | API / Security | High |

---

## UI: login (`tests/ui/01_login.robot`)

### TC-101 Standard user can log in

| # | Step | Expected result |
|---|---|---|
| 1 | Open the shop, log in as `standard_user` / `secret_sauce` | The products page |

### TC-102 User can log out

| # | Step | Expected result |
|---|---|---|
| 1 | Log in; open the side menu (☰), click **Logout** | The login page |

### TC-103 Logged-out user cannot open the products page directly

| # | Step | Expected result |
|---|---|---|
| 1 | Logged out, open `https://www.saucedemo.com/inventory.html` | Login page with "Epic sadface: You can only access '/inventory.html' when you are logged in." |

### TC-104 Invalid logins show the right error

For every data set: enter the user and password, click **Login**; expected the error shown.

| Data set | User | Password | Error |
|---|---|---|---|
| 1 | (empty) | (empty) | Epic sadface: Username is required |
| 2 | `standard_user` | (empty) | Epic sadface: Password is required |
| 3 | `standard_user` | `wrong_pass` | Epic sadface: Username and password do not match any user in this service |
| 4 | `unknown_user` | `secret_sauce` | Epic sadface: Username and password do not match any user in this service |
| 5 | `locked_out_user` | `secret_sauce` | Epic sadface: Sorry, this user has been locked out. |

## UI: products (`tests/ui/02_products.robot`)

### TC-105 Products page lists six products

| # | Step | Expected result |
|---|---|---|
| 1 | Count the product cards | Exactly 6 |

### TC-106 Default sort is name A to Z

| # | Step | Expected result |
|---|---|---|
| 1 | Without choosing a sort option, read the product names | Alphabetical order |

### TC-107 Products can be sorted

For every data set: choose the option in the sort list; expected order shown.

| Data set | Option | Expected |
|---|---|---|
| 1 | Name (A to Z) | Names ascending |
| 2 | Name (Z to A) | Names descending |
| 3 | Price (low to high) | Prices ascending |
| 4 | Price (high to low) | Prices descending |

## UI: cart (`tests/ui/03_cart.robot`)

### TC-108 Added products appear in the cart

| # | Step | Expected result |
|---|---|---|
| 1 | **Add to cart** on Sauce Labs Backpack and Sauce Labs Bike Light | Cart badge `2` |
| 2 | Open the cart (header icon) | Exactly those two products |

### TC-109 Removing a product updates the badge

| # | Step | Expected result |
|---|---|---|
| 1 | Add Sauce Labs Backpack and Sauce Labs Onesie; **Remove** the Backpack | Badge `1` |
| 2 | **Remove** the Onesie | Badge gone |

### TC-110 The cart is empty for a new session

| # | Step | Expected result |
|---|---|---|
| 1 | Right after logging in, open the cart | No products |

### TC-111 The cart keeps products after Continue Shopping

| # | Step | Expected result |
|---|---|---|
| 1 | Add the Backpack, open the cart, click **Continue Shopping** | Products page; badge `1` |

## UI: checkout (`tests/ui/04_checkout.robot`)

### TC-112 User can buy two products (end to end)

| # | Step | Expected result |
|---|---|---|
| 1 | Add Sauce Labs Backpack and Sauce Labs Fleece Jacket, open the cart | Exactly those two |
| 2 | **Checkout**, enter any first name, last name and postal code, **Continue** | Overview |
| 3 | Check the totals | Item total = sum of the prices; tax = 8 % rounded to cents; total = item total + tax |
| 4 | **Finish** | Order confirmation; badge gone |
| 5 | **Back Home** | Products page |

### TC-113 Order totals include eight percent tax

| # | Step | Expected result |
|---|---|---|
| 1 | Add Bike Light, Bolt T-Shirt and Onesie (three different prices), go to the overview | Item total = sum; tax = 8 % rounded to cents; total = item total + tax |

### TC-114 Cancel on the overview keeps the cart

| # | Step | Expected result |
|---|---|---|
| 1 | Add the Backpack, go to the overview, click **Cancel** | Products page; badge `1`; no order placed |

### TC-115 Customer information is required

For every data set: add a product, open the cart, **Checkout**, fill the form, **Continue**; expected
the error and no overview.

| Data set | First name | Last name | Postal code | Error |
|---|---|---|---|---|
| 1 | (empty) | `Doe` | `12345` | Error: First Name is required |
| 2 | `Jane` | (empty) | `12345` | Error: Last Name is required |
| 3 | `Jane` | `Doe` | (empty) | Error: Postal Code is required |

---

## API: auth (`tests/api/01_auth.robot`)

### TC-201 Valid login returns tokens and the user

| # | Step | Expected result |
|---|---|---|
| 1 | `POST /auth/login` `{"username":"emilys","password":"emilyspass"}` | `200`; `accessToken` (a JWT: three dot-separated parts), `refreshToken`, `id`, `username` `emilys`, `email` |

### TC-202 The token gives access to the current user

| # | Step | Expected result |
|---|---|---|
| 1 | Log in; `GET /auth/me` with `Authorization: Bearer <accessToken>` | `200`; `username` `emilys` |

### TC-203 The current user needs a token

| # | Step | Expected result |
|---|---|---|
| 1 | `GET /auth/me` without a token (and without the login's `accessToken` cookie) | `401`; "Access Token is required" |

### TC-204 Invalid credentials are rejected

For every data set: `POST /auth/login`; expected `400` and no token.

| Data set | Username | Password |
|---|---|---|
| 1 | `emilys` | `wrong-password` |
| 2 | `unknown-user` | `emilyspass` |

## API: products (`tests/api/02_products.robot`)

### TC-205 A product can be fetched by id

| # | Step | Expected result |
|---|---|---|
| 1 | `GET /products/1` | `200`; `id` `1`; `title`, `description`, `category`, `price` (> 0), `stock`, `rating` present |

### TC-206 Unknown product returns 404

| # | Step | Expected result |
|---|---|---|
| 1 | `GET /products/999999` | `404`; "Product with id '999999' not found" |

### TC-207 Search finds only matching products

| # | Step | Expected result |
|---|---|---|
| 1 | `GET /products/search?q=phone` | `total` > 0; every product's title or description contains "phone" |

### TC-208 Paging returns the requested slice

| # | Step | Expected result |
|---|---|---|
| 1 | `GET /products?limit=5&skip=10&select=title` | Exactly 5 products, ids 11 to 15 |

### TC-209 Select returns only the requested fields

| # | Step | Expected result |
|---|---|---|
| 1 | `GET /products?limit=3&select=title,price` | Each product has exactly `id`, `price`, `title` |

### TC-210 Add product echoes the new product

| # | Step | Expected result |
|---|---|---|
| 1 | `POST /products/add` `{"title":"Robot Test Product","price":19.99,"category":"testing"}` | `201`; the same title and price, and an `id` |

### TC-211 Update changes only the sent field

| # | Step | Expected result |
|---|---|---|
| 1 | Note product 1's title; `PUT /products/1` `{"price":12.5}` | `price` `12.5`; title unchanged |

### TC-212 Delete marks the product as deleted

| # | Step | Expected result |
|---|---|---|
| 1 | `DELETE /products/1` | `isDeleted: true` and a `deletedOn` timestamp |

## API: carts (`tests/api/03_carts.robot`)

### TC-213 Cart line totals add up

| # | Step | Expected result |
|---|---|---|
| 1 | `GET /carts/1` | Each line's `total` = `price` × `quantity` (to the cent); cart `total` = sum of the lines; `totalProducts` = number of lines |

### TC-214 A new cart contains the added products

| # | Step | Expected result |
|---|---|---|
| 1 | `POST /carts/add` `{"userId":1,"products":[{"id":144,"quantity":2}]}` | `totalQuantity` `2`; first product id `144`; `total` = 2 × its price |

### TC-215 The carts of a user belong to that user

| # | Step | Expected result |
|---|---|---|
| 1 | `GET /carts/user/1` | Every cart has `userId` `1` |
