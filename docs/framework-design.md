# Framework design

Why the framework is built the way it is. The README says *how* to use it; this file says *why*.

## 1. Layers

| Layer | Files | Knows about | Does not know about |
|---|---|---|---|
| Tests | `tests/**/*.robot` | business steps and expected results | locators, URL paths, HTTP verbs |
| Page / component objects | `resources/pages`, `resources/components` | locators, URL paths, waits for one screen | other screens' locators, test data |
| Service objects (API) | `resources/api/*Api.resource` | endpoint paths, request bodies, expected status | test expectations beyond the status code |
| Shared helpers | `common.resource`, `ApiSession.resource`, `ShopLibrary.py` | browser and session setup, generic helpers | any specific screen or endpoint |
| Configuration | `variables/config.py`, `args/*.args` | environment, browser, run profiles | anything about the tests themselves |

The point of the split: when Sauce Demo renames a `data-test` attribute, or DummyJSON moves an
endpoint, the fix is one line in one resource file and no test changes.

## 2. Page Object Model in Robot Framework

Robot Framework has no classes, so a "page object" is a **resource file per screen**:

- `*** Variables ***` holds the screen's locators and URL path (private by convention: tests do not use them).
- `*** Keywords ***` holds what a user can do there (`Add Product To Cart`) and what can be checked
  (`Cart Badge Should Show`).
- Each page has a `... Should Be Open` keyword that waits for a landmark element and checks the URL.
  Click-style navigation keywords (`Open Cart`, `Go To Checkout`) do not call it; the next keyword
  that needs the page does (`Cart Should Contain Exactly` starts with `Cart Page Should Be Open`).

**Components.** The header (burger menu, cart icon, badge) is on every logged-in page but has no URL.
Keeping it in `InventoryPage` meant cart and checkout tests imported the product-list page just for
the header. It is now `HeaderComponent.resource`, imported by the pages and tests that need it.

**Checkout is one file, three steps.** The three checkout screens share buttons (Continue, Cancel)
and are only ever used in order, so one resource keeps the flow readable. If a step grew larger,
it would be split into its own page object.

**Actions vs checks.** Action keywords (`Login As`, `Enter Customer Information`) do not assert
the outcome; check keywords contain `Should`. That lets the negative, data-driven tests reuse the
same actions with bad data and then check the error.

**Locators.** `data-test` attributes first (made for automation, survive styling changes), `id` where
there is no `data-test` (the burger menu), never XPath on layout. Product buttons are built from the
product name (`Product Id` in `ShopLibrary.py`), so one keyword serves all six products.

## 3. Service objects for the API

The API side follows the same rule as the UI side. `ApiSession.resource` owns the session aliases;
`AuthApi`, `ProductsApi` and `CartsApi` own one endpoint group each. Read keywords return the parsed
JSON body; keywords whose status code or headers matter to a test (`Login`, `Get Product`, the `/auth/me` calls) return the full
response (`Login` and `Get Product` also take `expected_status`).

One session per suite (not per test) reuses the TCP connection. The carts suite logs in once in its
suite setup; login itself is tested in the auth suite, so it does not need to be repeated per test.

DummyJSON sets an `accessToken` cookie on login. A shared session sends that cookie back, which
would make a "request without a token" test pass by accident. `Get Current User Without Token`
therefore uses its own fresh session.

## 4. Parallel runs with pabot

pabot starts several `robot` processes and merges their `output.xml` files into one report.
That only works if tests are independent, which the framework guarantees by design:

- every UI test opens its own browser in `Test Setup` and closes it in `Test Teardown`;
- every API suite opens its own HTTP session; nothing is shared between processes;
- Sauce Demo keeps the cart per browser session, so parallel browsers cannot see each other's cart;
- DummyJSON does not store writes, so parallel add/update/delete calls cannot interfere.

Because of that, `--testlevelsplit` (one test per work item) is safe and balances better than the
default suite split: with only 7 suites, one long suite would otherwise decide the total time.
Measured on a laptop: 30 tests, about 4 minutes of test time, 68 s wall time with 4 processes.

pabot starts its workers with the command `robot`, so the virtual environment must be active.

## 5. Run profiles as argument files

Long command lines get copied wrongly and drift between machines and CI. The `args/` files are
version-controlled run profiles that combine (`-A common -A ci -A smoke`). The same files work for
`robot` and `pabot`, so a serial debug run and the parallel CI run use the same settings.

The one option kept out of them is `--outputdir`: pabot gives each worker its own output folder,
and an `--outputdir` inside an argument file would override it, so all workers would overwrite the
same `output.xml` and the merged report would be empty.

## 6. Configuration

`variables/config.py` is a Python variable file: every value has a default for a local run, an
environment-variable override for CI, and `--variable` beats both for one-off runs. Booleans are
parsed in Python (`HEADLESS=true` becomes a real `True`), so `IF ${HEADLESS}` works.

## 7. Python where Robot syntax gets awkward

`ShopLibrary.py` holds logic that is clearer in Python: money maths with `Decimal` (no float
rounding surprises when checking tax), a case-insensitive sort check with a clear error message,
and random customer data. It is a `GLOBAL` scope library because it has no state.

## 8. Waits

No implicit wait (`Set Selenium Implicit Wait 0 s`). Every keyword waits explicitly for what it
needs, with the `TIMEOUT` from the config, so a missing element fails fast with a clear message
instead of every lookup silently waiting.
