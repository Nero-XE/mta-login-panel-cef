---Модуль клиентской логики
---@module 'client'
Client = {}

---Веб-браузер отвечающий за интерфейс
local webBrowser = WebBrowser.new('http://mta/local/html/index.html')

---Инстанс класса для работы с файлом с данными авторизации
local authData = AuthData.new()

---Установка ограничений для подключившихся игроков
function Client.restrictPlayerUntilAuth()
    setPlayerHudComponentVisible('all', false)
    showChat(false)
end

---Инициализировать и отобразить браузер
function Client.showBrowser()
    webBrowser:init()
    webBrowser:focus()
end

---Расшифровать файл с данными для авторизации
function Client.decryptAuthData()
    local fileContent = authData:getData()

    if not fileContent then return end
    triggerServerEvent('onRequestDecryptAuthData', resourceRoot, fileContent)
end

---Установка состояния формы
---@param state boolean
function Client.setLoadingForm(state)
    local jsCode = string.format('formApi.setLoading(%s)', tostring(state))
    webBrowser:executeJavaScript(jsCode)
end

---Подготавливает данные аутентификации для сохранения
---@param login any
---@param password any
function Client.prepareAuthData(login, password)
    ---Хранит данные аутентификации для сохранения
    Client.preparedAuthData = toJSON({ login = login, password = password })
end

---Навигация по форме
---@param page 'signIn'| 'signUp'|'verification'
function Client.navigateTo(page)
    local jsCode = string.format('routerApi.navigateTo%sPage()', page:gsub('^%l', string.upper))
    webBrowser:executeJavaScript(jsCode)
end

---Подстановка значений в форму
---@param login string
---@param password string
function Client.setFormValue(login, password)
    local jsCode = string.format('formApi.setSignInFormValues("%s", "%s")', login, password)

    ---Ожидаем загрузки страницы, иначе функция подстановки значений не сработает
    addEventHandler('onClientBrowserDocumentReady', webBrowser:get(), function()
        webBrowser:executeJavaScript(jsCode)
    end)
end

---Вызов уведомлений
---@param type 'success'|'info'|'warning'|'error' Тип уведомления
---@param message string Сообщение уведомления
---@param description string|nil Описание уведомления
function Client.notify(type, message, description)
    local messageType = {
        ['success'] = 'Success',
        ['info'] = 'Info',
        ['warning'] = 'Warning',
        ['error'] = 'Error',
    }

    local jsCode

    if description then
        jsCode = string.format('toastApi.show%sToast("%s", "%s")', messageType[type], message, description)
    else
        jsCode = string.format('toastApi.show%sToast("%s")', messageType[type], message)
    end

    webBrowser:executeJavaScript(jsCode)
end

---Удаление файла с данымми авторизации
function Client.deleteAuthData()
    authData:delete()
end

---Сохранить данные авторизации
---@param encryptedData string Зашифрованные данные
function Client.saveAuthData(encryptedData)
    authData:syncData(encryptedData)
end

---Удаление хендлеров
local function destroyEventHandlers()
    local handlers = {
        ['onClientResourceStart'] = Handlers.onResourceStart,
        ['requestSignUp'] = Handlers.onRequestSignUp,
        ['onSignUpSuccess'] = Handlers.onSignUpSuccess,
        ['onSignUpFailure'] = Handlers.onSignUpFailure,
        ['requestSignIn'] = Handlers.onRequestSignIn,
        ['onSignInSuccess'] = Handlers.onSignInSuccess,
        ['onSignInFailure'] = Handlers.onSignInFailure,
        ['onSignInNeed2FA'] = Handlers.onSignInNeed2FA,
        ['requestCheck2FA'] = Handlers.onRequestCheck2FA,
        ['onCheck2FAFailure'] = Handlers.onCheck2FAFailure,
        ['onDecryptAuthDataSuccess'] = Handlers.onDecryptAuthDataSuccess,
    }

    for eventName, handlerFunc in pairs(handlers) do
        removeEventHandler(tostring(eventName), resourceRoot, handlerFunc)
    end

    ---Удаляем позже, т.к. ивенты используются после входа
    setTimer(function ()
        removeEventHandler('onEncryptAuthDataSuccess', resourceRoot, Handlers.onEncryptAuthDataSuccess)
        removeEventHandler('onSendNotifyToClient', resourceRoot, Handlers.onSendNotifyToClient)
    end, 5000, 1)
end

---Снимает ограничения с игрока после успешной авторизации
function Client.releasePlayerAfterAuth()
    outputDebugString(inspect(localPlayer))
    destroyEventHandlers()
    setElementFrozen(localPlayer, false)
    setElementDimension(localPlayer, 0)
    setCameraTarget(localPlayer)
    setPlayerHudComponentVisible('all', true)
    webBrowser:blur()
    webBrowser:executeJavaScript('formApi.hideForm()')
    showChat(true, false)
    showCursor(false)

    setTimer(function ()
        webBrowser:destroy()
    end, 5000, 1)
end