*** Settings ***
Documentation     Shared UI keywords used by every page object: starting and closing the
...               browser, and reading the texts of a list of elements.
...
...               Every UI suite gets this file through a page object resource.
# Variables first: the Library line below already uses ${TIMEOUT} from it.
Variables         ../variables/config.py
Library           Collections
# timeout: the default wait for every "Wait Until ..." keyword.
# run_on_failure: a screenshot is embedded in log.html at the step that failed.
Library           SeleniumLibrary    timeout=${TIMEOUT}    run_on_failure=Capture Page Screenshot


*** Keywords ***
Open Browser On Login Page
    [Documentation]    Starts a new browser on the Sauce Demo login page.
    ...
    ...                Browser, headless mode and window size come from variables/config.py,
    ...                so the same test runs on Chrome, Firefox or Edge without changes.
    ${options}=    Build Options For Selected Browser
    Open Browser    ${UI_URL}    ${BROWSER}    options=${options}
    # A fixed window size keeps the page layout (and screenshots) the same on every machine.
    Set Window Size    ${WINDOW_WIDTH}    ${WINDOW_HEIGHT}
    # No implicit wait: every keyword waits explicitly for what it needs,
    # so a missing element fails fast instead of hiding behind a global wait.
    Set Selenium Implicit Wait    0 s

Close All Test Browsers
    [Documentation]    Closes every browser the test opened. Used as test teardown;
    ...                safe to call when no browser is open.
    Close All Browsers

Build Options For Selected Browser
    [Documentation]    Returns the SeleniumLibrary ``options`` string for ${BROWSER}.
    ...
    ...                - Chrome/Edge: headless flag (when ${HEADLESS}), no search-engine choice
    ...                  screen, and the password manager switched off. Without that, Chrome
    ...                  shows a "change your password" popup over the page after login.
    ...                - Firefox: only the headless flag. Returns ${NONE} when no option is needed.
    IF    '${BROWSER.lower()}' not in ['chrome', 'edge', 'headlesschrome']
        # Firefox spells the headless flag with one dash.
        IF    ${HEADLESS}    RETURN    add_argument("-headless")
        RETURN    ${NONE}
    END
    # Chrome preferences as a Python dict literal; SeleniumLibrary evaluates the string.
    VAR    ${prefs}
    ...    {"credentials_enable_service": False,
    ...    "profile.password_manager_enabled": False,
    ...    "profile.password_manager_leak_detection": False}
    ...    separator=${SPACE}
    # Several options are joined with ";" into one string, as SeleniumLibrary expects.
    VAR    ${options}
    ...    add_argument("--disable-search-engine-choice-screen");
    ...    add_experimental_option("prefs", ${prefs})
    ...    separator=${EMPTY}
    IF    ${HEADLESS}    VAR    ${options}    add_argument("--headless=new");${options}
    RETURN    ${options}

Get Texts Of All Matching Elements
    [Documentation]    Returns a list with the visible text of every element matching ${locator},
    ...                in page order.
    ...
    ...                Waits for the first match before reading, so an empty page is not
    ...                mistaken for "no elements": the keyword fails instead.
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}
    @{elements}=    Get WebElements    ${locator}
    VAR    @{texts}    @{EMPTY}
    FOR    ${element}    IN    @{elements}
        Append To List    ${texts}    ${element.text}
    END
    RETURN    ${texts}
