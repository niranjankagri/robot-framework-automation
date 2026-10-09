*** Settings ***
Documentation     Shared UI keywords: opening and closing the browser, reading element texts.
...               Every UI suite imports this file (directly or through a page resource).
# Variables first: the Library line below already uses ${TIMEOUT} from it.
Variables         ../variables/config.py
Library           Collections
Library           SeleniumLibrary    timeout=${TIMEOUT}    run_on_failure=Capture Page Screenshot


*** Keywords ***
Open Shop
    [Documentation]    Opens the browser on the Sauce Demo login page.
    ...                Browser, headless mode and window size come from variables/config.py.
    ${options}=    Build Browser Options
    Open Browser    ${UI_URL}    ${BROWSER}    options=${options}
    Set Window Size    ${WINDOW_WIDTH}    ${WINDOW_HEIGHT}
    # No implicit wait: every keyword waits explicitly for what it needs,
    # so a missing element fails fast instead of hiding behind a global wait.
    Set Selenium Implicit Wait    0 s

Close Shop
    [Documentation]    Closes every browser opened by the test (safe to call twice).
    Close All Browsers

Build Browser Options
    [Documentation]    Returns the SeleniumLibrary options string for the selected browser.
    ...                Chrome/Edge: switch off the password manager, otherwise Chrome shows
    ...                a "change your password" popup over the page after the Sauce Demo login.
    IF    '${BROWSER.lower()}' not in ['chrome', 'edge', 'headlesschrome']
        # Firefox: only the headless flag, spelled with one dash.
        IF    ${HEADLESS}    RETURN    add_argument("-headless")
        RETURN    ${NONE}
    END
    VAR    ${prefs}
    ...    {"credentials_enable_service": False,
    ...    "profile.password_manager_enabled": False,
    ...    "profile.password_manager_leak_detection": False}
    ...    separator=${SPACE}
    VAR    ${options}
    ...    add_argument("--disable-search-engine-choice-screen");
    ...    add_experimental_option("prefs", ${prefs})
    ...    separator=${EMPTY}
    IF    ${HEADLESS}    VAR    ${options}    add_argument("--headless=new");${options}
    RETURN    ${options}

Get Element Texts
    [Documentation]    Returns the visible text of every element that matches ${locator}.
    ...                Waits for the first one, so an empty result means "really none".
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}
    @{elements}=    Get WebElements    ${locator}
    VAR    @{texts}    @{EMPTY}
    FOR    ${element}    IN    @{elements}
        Append To List    ${texts}    ${element.text}
    END
    RETURN    ${texts}
