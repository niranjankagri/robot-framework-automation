"""Custom Python keywords for the shop tests.

Logic that is awkward in Robot syntax (parsing prices, sorting checks, money
maths) lives here as plain Python, which is easier to read and unit test.
Robot Framework turns every public method into a keyword:
`prices_from_texts` becomes `Prices From Texts`.
"""

import random
import re
import string
from decimal import Decimal, ROUND_HALF_UP

from robot.api import logger
from robot.api.deco import keyword, library


@library(scope="GLOBAL")  # stateless, so one instance for the whole run is enough
class ShopLibrary:

    @keyword
    def product_id(self, name):
        """Turns a product name into the id Sauce Demo uses in its data-test attributes.

        Example: "Sauce Labs Bolt T-Shirt" -> "sauce-labs-bolt-t-shirt"
        """
        return name.strip().lower().replace(" ", "-")

    @keyword
    def prices_from_texts(self, texts):
        """Converts price labels like "$29.99" or "Item total: $29.99" into Decimals.

        Decimal (not float) so that 0.1 + 0.2 really equals 0.3 in money checks.
        """
        prices = []
        for text in texts:
            match = re.search(r"\$(\d+(?:\.\d{2})?)", text)
            if not match:
                raise AssertionError(f"No price found in '{text}'")
            prices.append(Decimal(match.group(1)))
        return prices

    @keyword
    def should_be_sorted(self, values, order="ascending"):
        """Fails unless `values` is sorted. Strings are compared case-insensitively."""
        if order not in ("ascending", "descending"):
            raise ValueError(f"order must be ascending or descending, not '{order}'")
        keys = [v.lower() if isinstance(v, str) else v for v in values]
        expected = sorted(keys, reverse=(order == "descending"))
        if keys != expected:
            raise AssertionError(f"Not sorted {order}: {list(values)}")
        logger.info(f"{len(values)} values sorted {order}")

    @keyword
    def order_total(self, item_prices, tax_rate="0.08"):
        """Returns (subtotal, tax, total) as Decimals rounded to cents.

        Sauce Demo charges 8% tax on the item total.
        """
        subtotal = sum((Decimal(str(p)) for p in item_prices), Decimal("0"))
        tax = (subtotal * Decimal(tax_rate)).quantize(Decimal("0.01"), ROUND_HALF_UP)
        return subtotal, tax, subtotal + tax

    @keyword
    def random_customer(self):
        """Returns a dict with a random first name, last name and postal code.

        Random data shows the form does not depend on one fixed value.
        """
        letters = string.ascii_lowercase
        return {
            "first_name": "Test" + "".join(random.choices(letters, k=5)),
            "last_name": "User" + "".join(random.choices(letters, k=5)),
            "postal_code": "".join(random.choices(string.digits, k=5)),
        }
