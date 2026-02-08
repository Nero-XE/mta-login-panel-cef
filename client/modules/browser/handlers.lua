---@class BrowserHandlers
---@field private screenW integer Ширина клиентского дисплея
---@field private screenH integer Высота клиентского дисплея
---@field private browser userdata Браузер
---@field private url string Путь загружаемой страницы
---@field private useDevTools boolean Использовать DevTools браузера
BrowserHandlers = {}

---Создает экземпляр класса хендлеров браузера
---@param browser userdata Браузер для которого нужно создать обработчики
---@param url string Путь загружаемой страницы
---@param useDevTools boolean Использовать DevTools браузера
---@return BrowserHandlers
function BrowserHandlers.new(browser, screenW, screenH, url, useDevTools)
    local state = {
        screenW = screenW,
        screenH = screenH,
        browser = browser,
        url = url,
        useDevTools = useDevTools,
    }
    return setmetatable(state, { __index = BrowserHandlers })
end

---Обработчик события создания браузера
function BrowserHandlers:onBrowserCreated()
    if not isElement(self.browser) then return end

    loadBrowserURL(self.browser, self.url)

    if not self.useDevTools then return end

    setDevelopmentMode(true, true)
    toggleBrowserDevTools(self.browser, true)
end

---Обработчик рендеринга браузера
function BrowserHandlers:onRender()
    if not isElement(self.browser) then return end
    dxDrawImage(0, 0, self.screenW, self.screenH, self.browser)
end

---Обработчик движения курсора. Инжектирует курсор в браузер
function BrowserHandlers:onCursorMove(x, y)
    injectBrowserMouseMove(self.browser, x, y)
end

---Обработчик прокрутки страницы. Инжектирует прокрутку в браузер
function BrowserHandlers:onMouseWheel(wheelState)
    if wheelState == "mouse_wheel_down" then
    	injectBrowserMouseWheel(self.browser, -40, 0)
    elseif wheelState == "mouse_wheel_up" then
    	injectBrowserMouseWheel(self.browser, 40, 0)
    end
end

---Обработчик клика. Инжектирует клик в браузер
function BrowserHandlers:onMouseClick(button, state)
    if state == 'down' then
        injectBrowserMouseDown(self.browser, button)
    else
        injectBrowserMouseUp(self.browser, button)
    end
end