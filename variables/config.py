"""Central configuration for all suites.

Robot Framework imports this file as a variable file: every upper-case
name below becomes a ${VARIABLE} in the tests.

Each value can be overridden without editing code, in two ways:
  1. environment variable, e.g.  BROWSER=firefox robot tests
  2. command line, e.g.          robot --variable BROWSER:firefox tests
The command line wins, because --variable is applied after variable files.
"""

import os


def _env(name, default):
    """Return the environment variable `name`, or `default` when it is not set."""
    return os.environ.get(name, default)


def _env_bool(name, default):
    """Read a true/false environment variable ("true", "1", "yes" count as true)."""
    value = os.environ.get(name)
    if value is None:
        return default
    return value.strip().lower() in ("true", "1", "yes")


# ---------- UI (Sauce Demo) ----------
UI_URL = _env("UI_URL", "https://www.saucedemo.com")
BROWSER = _env("BROWSER", "chrome")          # chrome | firefox | edge
HEADLESS = _env_bool("HEADLESS", False)      # true in CI, false locally to watch the run
TIMEOUT = _env("TIMEOUT", "10 s")            # max wait for any element/condition
WINDOW_WIDTH = 1366
WINDOW_HEIGHT = 900

# Sauce Demo publishes its test users on the login page; they are not secrets.
STANDARD_USER = "standard_user"
LOCKED_USER = "locked_out_user"
PROBLEM_USER = "problem_user"
PASSWORD = _env("SAUCE_PASSWORD", "secret_sauce")

# ---------- API (DummyJSON) ----------
API_URL = _env("API_URL", "https://dummyjson.com")
API_USER = _env("API_USER", "emilys")
API_PASSWORD = _env("API_PASSWORD", "emilyspass")
