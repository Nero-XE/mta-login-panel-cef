local screenWidth, screenHeight = guiGetScreenSize()

WebBrowser = {
    webBrowser = createBrowser(screenWidth, screenHeight, true, true),
}

function WebBrowser:getBrowser()
    return self.webBrowser
end

local browser = WebBrowser:getBrowser()

if not browser then return end

local function mouseMoveHandler(_, _, absoluteX, absoluteY)
    injectBrowserMouseMove(browser, absoluteX, absoluteY)
end

local function mouseClickHandler(button, state)
    if state == 'down' then
        injectBrowserMouseDown(browser, button)
    else
        injectBrowserMouseUp(browser, button)
    end
end

local function browserRenderHandler()
    dxDrawImage(0, 0, screenWidth, screenHeight, browser)
    focusBrowser(browser)
    showCursor(true)
end

local function browserCreatedHandler()
    loadBrowserURL(browser, 'http://mta/local/html/index.html')

    -- setDevelopmentMode(true, true)
    -- toggleBrowserDevTools(browser, true)
end

function WebBrowser:initRendering()
    -- Загрузка страницы при готовности браузера
    addEventHandler('onClientBrowserCreated', browser, browserCreatedHandler)

    -- Рендер браузера
    addEventHandler('onClientRender', root, browserRenderHandler, false)

    -- Взаимодействие с мышью
    addEventHandler('onClientCursorMove', root, mouseMoveHandler, false)
    addEventHandler('onClientClick', root, mouseClickHandler)
end

---Выполнение JavaScript кода
---@param jsCode string JavaScript код
function WebBrowser:executeJavaScript(jsCode)
    executeBrowserJavascript(browser, jsCode)
end

---Удаление браузера и его хендлеров
function WebBrowser:destroyBrowser()
    removeEventHandler('onClientClick', root, mouseClickHandler)
    removeEventHandler('onClientCursorMove', root, mouseMoveHandler)
    removeEventHandler('onClientRender', root, browserRenderHandler)
    removeEventHandler('onClientBrowserCreated', root, browserCreatedHandler)
    destroyElement(browser)
end
