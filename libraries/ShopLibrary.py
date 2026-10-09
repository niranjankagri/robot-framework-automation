"""Custom Python keywords for the shop tests.

Logic that is awkward in Robot syntax (parsing prices, sorting checks, money
maths, random test data) lives here as plain Python, which is easier to read
and unit test.

Robot Framework turns every method marked with @keyword into a keyword:
`parse_prices` becomes `Parse Prices`. The docstrings are shown in Libdoc and
in log.html, so they are written for the test author.
"""

import random
import re
import string
from decimal import Decimal, ROUND_HALF_UP

from robot.api import logger
from robot.api.deco import keyword, library

# Sauce Demo charges 8% tax on the item total.
SAUCE_DEMO_TAX_RATE = "0.08"

# "$29.99" or "Item total: $29.99" -> "29.99"
_PRICE_PATTERN = re.compile(r"\$(\d+(?:\.\d{2})?)")


@library(scope="GLOBAL")  # stateless, so one instance for the whole run is enough
class ShopLibrary:

    @keyword
    def product_id_from_name(self, product_name):
        """Returns the id Sauce Demo builds from a product name for its button locators.

        Example: "Sauce Labs Bolt T-Shirt" -> "sauce-labs-bolt-t-shirt",
        used in data-test="add-to-cart-sauce-labs-bolt-t-shirt".
        """
        return product_name.strip().lower().replace(" ", "-")

    @keyword
    def parse_prices(self, price_texts):
        """Returns the amounts in price labels like "$29.99" as a list of Decimals.

        Decimal (not float) so that money maths is exact: 0.1 + 0.2 is really 0.3.
        Fails if a text has no "$" amount in it.
        """
        prices = []
        for text in price_texts:
            match = _PRICE_PATTERN.search(text)
            if not match:
                raise AssertionError(f"No price found in '{text}'")
            prices.append(Decimal(match.group(1)))
        return prices

    @keyword
    def values_should_be_sorted(self, values, order="ascending"):
        """Fails unless `values` is sorted in `order` ("ascending" or "descending").

        Strings are compared case-insensitively, as a shop sorts names.
        The error message lists the values, so a failure shows the wrong order.
        """
        if order not in ("ascending", "descending"):
            raise ValueError(f"order must be ascending or descending, not '{order}'")
        keys = [v.lower() if isinstance(v, str) else v for v in values]
        expected = sorted(keys, reverse=(order == "descending"))
        if keys != expected:
            raise AssertionError(f"Not sorted {order}: {list(values)}")
        logger.info(f"{len(values)} values sorted {order}")

    @keyword
    def calculate_order_totals(self, item_prices, tax_rate=SAUCE_DEMO_TAX_RATE):
        """Returns (subtotal, tax, total) for `item_prices`, as Decimals rounded to cents.

        Tax is rounded half up, like the shop does: 0.125 -> 0.13.
        """
        subtotal = sum((Decimal(str(price)) for price in item_prices), Decimal("0"))
        tax = (subtotal * Decimal(tax_rate)).quantize(Decimal("0.01"), ROUND_HALF_UP)
        return subtotal, tax, subtotal + tax

    @keyword
    def generate_random_customer(self):
        """Returns a dict with a random `first_name`, `last_name` and `postal_code`.

        Random data shows the checkout form does not depend on one fixed value.
        """
        letters = string.ascii_lowercase
        return {
            "first_name": "Test" + "".join(random.choices(letters, k=5)),
            "last_name": "User" + "".join(random.choices(letters, k=5)),
            "postal_code": "".join(random.choices(string.digits, k=5)),
        }
