---@class Client Модуль клиентской логики аутентификации
---@field private webBrowser WebBrowser 
Client = {
    webBrowser = WebBrowser.new('http://mta/local/html/index.html')
}

---Ограничение пользователя при подключении
local function restrictPlayerUntilAuth()
    setPlayerHudComponentVisible('all', false)
    showChat(false)
end

---Запрос на дешифровку данных аутентификации (если файл с данными существует у клиента)
local function decryptAuthData()
    local fileContent = AuthDataManager:getFileContent()

    if not fileContent then return end
    triggerServerEvent('onRequestDecryptAuthData', resourceRoot, fileContent)
end

---Хендлер на старт ресурса
function Client.resourceStartHandler()
    Client.webBrowser:init()
    Client.webBrowser:focus()
    restrictPlayerUntilAuth()
    decryptAuthData()
end

---Хендлер на успешную дешифровку файла авторизации и подстановка значений в поля ввода
---@param decryptedData string
function Client.onDecryptAuthDataSuccessHandler(decryptedData)
    local authData = fromJSON(decryptedData)

    if not authData then return end
    local jsCode = string.format('formApi.setSignInFormValues("%s", "%s")', authData.login, authData.password)

    local browser = Client.webBrowser:get()

    if not browser then return end
    -- Ожидаем загрузки страницы, иначе функция подстановки значений не успеет инициализироваться
    addEventHandler('onClientBrowserDocumentReady', browser, function()
        Client.webBrowser:executeJavaScript(jsCode)
    end)
end

---Обрабатывает запрос на регистрацию нового пользователя
function Client.requestSignUpHandler(rawRegData)
    Client.webBrowser:executeJavaScript('formApi.setLoading(true)')
    local authData = fromJSON(rawRegData)

    if not authData then return end
    local login, password, secretWord = authData['login'], authData['password'], authData['secretPhrase']

    triggerServerEvent('onRequestSignUp', resourceRoot, login, password, secretWord)
end

---Хендлер на успешную регистрацию игрока
function Client.onSignUpSuccessHandler()
    Client.webBrowser:executeJavaScript('formApi.setLoading(false)')
    Client.webBrowser:executeJavaScript('routerApi.navigateToSignInPage()')
end

---Хендлер на неудачную попытку регистрации
function Client.onSignUpFailureHandler(type, message, description)
    local messageType = {
        ['success'] = 'Success',
        ['info'] = 'Info',
        ['warning'] = 'Warning',
        ['error'] = 'Error',
    }
    local jsCode = string.format('toastApi.show%sToast("%s", "%s")', messageType[type], message, description)
    Client.webBrowser:executeJavaScript(jsCode)
    Client.webBrowser:executeJavaScript('formApi.setLoading(false)')
end

---Хранит данные аутентификации для сохранения
local preparedAuthData = nil

---Подготавливает данные аутентификации для сохранения
---@param login any
---@param password any
local function prepareAuthData(login, password)
    preparedAuthData = toJSON({ login = login, password = password })
end

---Обрабатывает запрос на авторизацию пользователя
---@param rawAuthData string
function Client.requestSignInHandler(rawAuthData)
    Client.webBrowser:executeJavaScript('formApi.setLoading(true)')

    local authData = fromJSON(rawAuthData)

    if not authData then return end
    local login, password, isRememberAuthData = authData['login'], authData['password'], authData['rememberMe']

    triggerServerEvent('onRequestSignIn', resourceRoot, login, password)

    if not isRememberAuthData then return end
    prepareAuthData(login, password)
end

---Удаление хендлеров
local function destroyEventHandlers()
    local handlers = {
        ['onClientResourceStart'] = Client.resourceStartHandler,
        ['requestSignUp'] = Client.requestSignUpHandler,
        ['onSignUpSuccess'] = Client.onSignUpSuccessHandler,
        ['onSignUpFailure'] = Client.onSignUpFailureHandler,
        ['requestSignIn'] = Client.requestSignInHandler,
        ['onSignInSuccess'] = Client.onSignInSuccessHandler,
        ['onSignInFailure'] = Client.onSignInFailureHandler,
        ['onSignInNeed2FA'] = Client.onSignInNeed2FAHandler,
        ['requestCheck2FA'] = Client.requestCheck2FAHandler,
        ['onCheck2FAFailure'] = Client.onCheck2FAFailureHandler,
        ['onDecryptAuthDataSuccess'] = Client.onDecryptAuthDataSuccessHandler,
    }

    for eventName, handlerFunc in pairs(handlers) do
        removeEventHandler(tostring(eventName), resourceRoot, handlerFunc)
    end

    ---Удаляем позже, т.к. ивенты используются после входа
    setTimer(function ()
        removeEventHandler('onEncryptAuthDataSuccess', resourceRoot, Client.onEncryptAuthDataSuccessHandler)
        removeEventHandler('onSendNotifyToClient', resourceRoot, Client.onSendNotifyToClientHandler)
    end, 5000, 1)
end

---Снимает ограничения с игрока после успешной авторизации
local function releasePlayerAfterAuth()
    destroyEventHandlers()
    setElementFrozen(localPlayer, false)
    setElementDimension(localPlayer, 0)
    setCameraTarget(localPlayer)
    setPlayerHudComponentVisible('all', true)
    Client.webBrowser:blur()
    Client.webBrowser:executeJavaScript('formApi.hideForm()')
    showChat(true, false)
    showCursor(false)

    setTimer(function ()
        Client.webBrowser:destroy()
    end, 5000, 1)
end

---Хендлер на успешную шифровку данных аутентификации
---@param encryptedData string
function Client.onEncryptAuthDataSuccessHandler(encryptedData)
    AuthDataManager:syncDataToFile(encryptedData)
end

---Хендлер на успешную авторизацию игрока
function Client.onSignInSuccessHandler()
    releasePlayerAfterAuth()

    if preparedAuthData then
        triggerServerEvent('onRequestEncryptAuthData', resourceRoot, preparedAuthData)
    else
        AuthDataManager:deleteDataFile()
    end
end

---Хендлер на неудачную попытку авторизации
function Client.onSignInFailureHandler(attemptMessage)
    local jsCode = string.format('toastApi.showErrorToast("Неверный логин или пароль!", "%s")', attemptMessage)
    Client.webBrowser:executeJavaScript(jsCode)
    Client.webBrowser:executeJavaScript('formApi.setLoading(false)')
end

---Хендлер на запрос кодового слова
function Client.onSignInNeed2FAHandler()
    Client.webBrowser:executeJavaScript('formApi.setLoading(false)')
    Client.webBrowser:executeJavaScript('routerApi.navigateToVerificationPage()')
end

---Обрабатывает запрос на проверку кодового слова
function Client.requestCheck2FAHandler(secretCode)
    Client.webBrowser:executeJavaScript('formApi.setLoading(true)')
    triggerServerEvent('onRequestCheck2FA', resourceRoot, secretCode)
end

---Хендлер на неудачную попытку проверки кодового слова
function Client.onCheck2FAFailureHandler(attemptMessage)
    local jsCode = string.format('toastApi.showErrorToast("Неверное кодовое слово!", "%s")', attemptMessage)
    Client.webBrowser:executeJavaScript(jsCode)
    Client.webBrowser:executeJavaScript('formApi.setLoading(false)')
end

---Хендлер на уведомления
---@param type 'success'|'info'|'warning'|'error' Тип уведомления
---@param message string Сообщение
---@param description string|nil Описание
function Client.onSendNotifyToClientHandler(type, message, description)
    local messageType = {
        ['success'] = 'Success',
        ['info'] = 'Info',
        ['warning'] = 'Warning',
        ['error'] = 'Error',
    }

    local jsCode = nil

    if description then
        jsCode = string.format('toastApi.show%sToast("%s", "%s")', messageType[type], message, description)
    else
        jsCode = string.format('toastApi.show%sToast("%s")', messageType[type], message)
    end

    Client.webBrowser:executeJavaScript(jsCode)
end