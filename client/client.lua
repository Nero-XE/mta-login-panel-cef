---Модуль клиентской логики аутентификации
Client = {}

---Ограничение пользователя при подключении
local function restrictPlayerUntilAuth()
    setPlayerHudComponentVisible('all', false)
    guiSetInputMode('no_binds')
    showChat(false)
end

---Запрос на дешифровку данных аутентификации (если файл с данными существует у клиента)
local function decryptAuthData()
    local fileContent = AuthData:getFileContent()

    if not fileContent then return end
    triggerServerEvent('onRequestDecryptAuthData', resourceRoot, fileContent)
end

---Хендлер на старт ресурса
function Client.resourceStartHandler()
    WebBrowser:initRendering()
    restrictPlayerUntilAuth()
    decryptAuthData()
end

---Хендлер на успешную дешифровку файла авторизации и подстановка значений в поля ввода
---@param decryptedData string
function Client.onDecryptAuthDataSuccessHandler(decryptedData)
    local authData = fromJSON(decryptedData)

    if not authData then return end
    local jsCode = string.format('setFormValues("%s", "%s", true)', authData.login, authData.password)

    local browser = WebBrowser:getBrowser()

    if not browser then return end
    -- Ожидаем загрузки страницы, иначе функция подстановки значений не успеет инициализироваться
    addEventHandler('onClientBrowserDocumentReady', browser, function()
        WebBrowser:executeJavaScript(jsCode)
    end)
end

---Обрабатывает запрос на регистрацию нового пользователя
function Client.requestSignUpHandler(rawRegData)
    local authData = fromJSON(rawRegData)

    if not authData then return end
    local login, password, secretWord = authData['login'], authData['password'], authData['secretPhrase']

    triggerServerEvent('onRequestSignUp', resourceRoot, login, password, secretWord)
end

---Хендлер на успешную регистрацию игрока
function Client.onSignUpSuccessHandler()
    WebBrowser:executeJavaScript('goToSignInPage()')
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
        ['requestSignIn'] = Client.requestSignInHandler,
        ['onSignInSuccess'] = Client.onSignInSuccessHandler,
        ['onSignInNeed2FA'] = Client.onSignInNeed2FAHandler,
        ['requestCheck2FA'] = Client.requestCheck2FAHandler,
        -- ['onEncryptAuthDataSuccess'] = Client.onEncryptAuthDataSuccessHandler,
        ['onDecryptAuthDataSuccess'] = Client.onDecryptAuthDataSuccessHandler,
        ['onSendNotifyToClient'] = Client.onSendNotifyToClientHandler,
    }

    for eventName, handlerFunc in pairs(handlers) do
        removeEventHandler(tostring(eventName), resourceRoot, handlerFunc)
    end
end

---Снимает ограничения с игрока после успешной авторизации
local function releasePlayerAfterAuth()
    destroyEventHandlers()
    setElementFrozen(localPlayer, false)
    setElementDimension(localPlayer, 0)
    setCameraTarget(localPlayer)
    setPlayerHudComponentVisible('all', true)
    guiSetInputMode('allow_binds')
    WebBrowser:destroyBrowser()
    showChat(true, false)
    showCursor(false)
end

---Хендлер на успешную шифровку данных аутентификации
---@param encryptedData string
function Client.onEncryptAuthDataSuccessHandler(encryptedData)
    AuthData:syncDataToFile(encryptedData)
end

---Хендлер на успешную авторизацию игрока
function Client.onSignInSuccessHandler()
    releasePlayerAfterAuth()

    if preparedAuthData then
        triggerServerEvent('onRequestEncryptAuthData', resourceRoot, preparedAuthData)
    else
        AuthData:deleteDataFile()
    end
end

---Хендлер на запрос кодового слова
function Client.onSignInNeed2FAHandler()
    WebBrowser:executeJavaScript('goToVerificationPage()')
end

---Обрабатывает запрос на проверку кодового слова
function Client.requestCheck2FAHandler(secretCode)
    triggerServerEvent('onRequestCheck2FA', resourceRoot, secretCode)
end

---Хендлер на уведомления
---@param type 'error'|'success'|'warning' Тип уведомления
---@param message string Сообщение
---@param description string|nil Описание
function Client.onSendNotifyToClientHandler(type, message, description)
    local messageType = {
        ['error'] = 'Error',
        ['success'] = 'Success',
        ['warning'] = 'Warning',
    }

    local jsCode = nil

    if description then
        jsCode = string.format('show%s("%s", "%s")', messageType[type], message, description)
    else
        jsCode = string.format('show%s("%s")', messageType[type], message)
    end

    WebBrowser:executeJavaScript(jsCode)
end