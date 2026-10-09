*** Settings ***
Documentation     Shared UI keywords: opening and closing the browser.
...               Every UI suite imports this file (directly or through a page resource).
# Variables first: the Library line below already uses ${TIMEOUT} from it.
Variables         ../variables/config.py
Library           SeleniumLibrary    timeout=${TIMEOUT}    run_on_failure=Capture Page Screenshot
Library           Collections


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
    ${headless}=    Set Variable If    ${HEADLESS}    add_argument("--headless=new");    ${EMPTY}
    IF    '${BROWSER.lower()}' in ['chrome', 'edge', 'headlesschrome']
        ${prefs}=    Set Variable
        ...    {"credentials_enable_service": False, "profile.password_manager_enabled": False, "profile.password_manager_leak_detection": False}
        RETURN    ${headless}add_argument("--disable-search-engine-choice-screen");add_experimental_option("prefs", ${prefs})
    END
    # Firefox: only the headless flag (Firefox uses "-headless").
    ${headless}=    Set Variable If    ${HEADLESS}    add_argument("-headless")    ${EMPTY}
    RETURN    ${headless}
