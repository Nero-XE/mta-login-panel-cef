---@class WebBrowser
---@field private screenW integer Ширина клиентского дисплея
---@field private screenH integer Высота клиентского дисплея
---@field private browser userdata Браузер
---@field private url string Путь загружаемой страницы
---@field private useDevTools boolean Использовать DevTools браузера
---@field private handlers BrowserHandlers Хендлеры браузера
---@field private eventHandlers table Таблица для хранения обработчиков
---@field private registerHandler function
---@field private removeEventHandlers function
---@field private onBrowserCreated function
---@field private onRender function
---@field private onCursorMove function
---@field private onMouseWheel function
---@field private onMouseClick function
WebBrowser = {}

---Создает экземпляр класса браузера
---@param url string Путь загружаемой страницы
---@param useDevTools boolean|nil Использовать DevTools браузера
---@return WebBrowser
function WebBrowser.new(url, useDevTools)
    local screenW, screenH = guiGetScreenSize()
    local state = {
        screenW = screenW,
        screenH = screenH,
        browser = createBrowser(screenW, screenH, true, true),
        url = url,
        useDevTools = useDevTools or false,
        eventHandlers = {},
    }
    return setmetatable(state, { __index = WebBrowser })
end

---Возвращает браузер
---@return userdata
function WebBrowser:get()
    return self.browser
end

---Регистрирует обработчик события с сохранением ссылки
---@param event string Название события
---@param element element Элемент
---@param handler function Функция-обработчик
---@param propagated boolean|nil
function WebBrowser:registerHandler(event, element, handler, propagated)
    propagated = propagated or false
    addEventHandler(event, element, handler, propagated)

    self.eventHandlers[event] = self.eventHandlers[event] or {}
    table.insert(self.eventHandlers[event], {
        element = element,
        handler = handler,
        propagated = propagated
    })
end

---Удаляет все зарегистрированные обработчики события
---@param event string Название события
function WebBrowser:removeEventHandlers(event)
    if not self.eventHandlers[event] then return end

    for _, handlerData in ipairs(self.eventHandlers[event]) do
        removeEventHandler(event, handlerData.element, handlerData.handler)
    end

    self.eventHandlers[event] = nil
end

---Инициализирует и отрисовывает браузер
function WebBrowser:init()
    if not isElement(self.browser) then return end

    self.handlers = BrowserHandlers.new(self.browser, self.screenW, self.screenH, self.url, self.useDevTools)

    self.onBrowserCreated = function () self.handlers:onBrowserCreated() end
    self.onRender = function () self.handlers:onRender() end

    self:registerHandler('onClientBrowserCreated', self.browser, self.onBrowserCreated)
    self:registerHandler('onClientRender', root, self.onRender)
end

---Фокус на браузер
function WebBrowser:focus()
    if not isElement(self.browser) then return end

    focusBrowser(self.browser)
    showCursor(true)
    guiSetInputMode('no_binds')

    self.onCursorMove = function (_, _, absoluteX, absoluteY) self.handlers:onCursorMove(absoluteX, absoluteY) end
    self.onMouseWheel = function (state) self.handlers:onMouseWheel(state) end
    self.onMouseClick = function (button, state) self.handlers:onMouseClick(button, state) end

    self:registerHandler('onClientCursorMove', root, self.onCursorMove)
    self:registerHandler('onClientKey', root, self.onMouseWheel)
    self:registerHandler('onClientClick', root, self.onMouseClick)
end

---Блюр на браузер и освобождение мыши
function WebBrowser:blur()
    focusBrowser(nil)
    showCursor(false)
    guiSetInputMode('allow_binds')

    self:removeEventHandlers('onClientClick')
    self:removeEventHandlers('onClientKey')
    self:removeEventHandlers('onClientCursorMove')
end

---Выполнение JavaScript кода в браузере
---@param jsCode string Строка содержащая JS код
function WebBrowser:executeJavaScript(jsCode)
    if not isElement(self.browser) then return end
    executeBrowserJavascript(self.browser, jsCode)
end

---Уничтожает браузер
function WebBrowser:destroy()
    if not isElement(self.browser) then return end

    self:blur()
    self:removeEventHandlers('onClientRender')
    self:removeEventHandlers('onClientBrowserCreated')
    destroyElement(self.browser)
end