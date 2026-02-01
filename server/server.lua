---Модуль серверной логики аутентификации
Server = {}

---Установка ограничений для подключившихся игроков
function Server.restrictPlayerUntilAuth()
    setElementFrozen(source, true)
    setElementDimension(source, 1)
    setCameraMatrix(source, -1997.7705078125, 980.21661376953, 113.68701934814)
end

---Получает значение настройки
---@param settingName string Название настройки
---@return number
local function getSettingValue(settingName)
    return tonumber(get(string.format('%s.%s', resourceName, settingName))) or 0
end

---Обрабатывает попытку операции с проверкой лимита
---@param player element Игрок
---@param attemptType 'signUp'|'signIn'|'check2FA' Тип операции
---@return string
local function handleAttempt(player, attemptType)
    local configs = {
        signUp = {
            dataKey = 'loginPanel.signUpAttemptsCount',
            settingKey = 'SignUpAttemptsLimit',
            actionName = 'регистрации'
        },
        signIn = {
            dataKey = 'loginPanel.signInAttemptsCount',
            settingKey = 'SignInAttemptsLimit',
            actionName = 'авторизации'
        },
        check2FA = {
            dataKey = 'loginPanel.check2FAAttemptsCount',
            settingKey = 'Check2FAAttemptsLimit',
            actionName = 'проверки кодового слова'
        }
    }

    local config = configs[attemptType]

    local limit = getSettingValue(config.settingKey)

    local currentAttempts = getElementData(player, config.dataKey) or 0
    currentAttempts = currentAttempts + 1
    setElementData(player, config.dataKey, currentAttempts)

    if currentAttempts >= limit then
        local kickMsg = string.format('Слишком много попыток %s', config.actionName)
        if isElement(player) then
            kickPlayer(player, kickMsg)
        end
    else
        return string.format('Попытка %s №%d из %d', config.actionName, currentAttempts, limit)
    end
end

---Регистрация нового аккаунта
---@param login string Логин для нового аккаунта
---@param password string Пароль для нового аккаунта
---@param secretCode string Кодовое слово для нового аккаунта
function Server.onRequestSignUpHandler(login, password, secretCode)
    local playerSerial = getPlayerSerial(client)
    local accounts = getAccountsBySerial(playerSerial)

    if #accounts == 0 then
        local accountAdded = addAccount(login, password)
        if accountAdded then
            setAccountData(accountAdded, 'loginPanel.secretCode', secretCode)
            setAccountSerial(accountAdded, playerSerial)
            triggerClientEvent(client, 'onSignUpSuccess', resourceRoot)
            triggerClientEvent(client, 'onSendNotifyToClient', resourceRoot, 'success', 'Вы успешно зарегистрировались, войдите в аккаунт!')
        else
            local attemptMessage = handleAttempt(client, 'signUp')
            triggerClientEvent(client, 'onSendNotifyToClient', resourceRoot, 'warning', 'Введенный логин уже занят!', attemptMessage)
        end
    else
        local attemptMessage = handleAttempt(client, 'signUp')
        triggerClientEvent(client, 'onSendNotifyToClient', resourceRoot, 'error', 'На этом устройстве уже зарегистрирован аккаунт!', attemptMessage)
    end
end

---Завершить вход игрока
---@param player userdata Объект игрока
---@param account userdata Аккаунт MTA
---@param password string Пароль от аккаунта
local function completePlayerSignIn(player, account, password)
    logIn(player, account, password)
    triggerClientEvent(player, 'onSignInSuccess', resourceRoot)
    outputChatBox('Вы успешно авторизовались!', player, 80, 200, 120)
end

---Переменная хранящая данные авторизации. Потребуется при входе с нового компьютера
local authData = {}

---Авторизация игрока с проверкой на вход с нового компьютера
---@param login string Логин от аккаунта
---@param password string Пароль от аккаунта
function Server.onRequestSignInHandler(login, password)
    local account = getAccount(login, password)
    local playerSerial = getPlayerSerial(client)

    if account then
        local accountSerial = getAccountSerial(account)
        if accountSerial == playerSerial then
            completePlayerSignIn(client, account, password)
        else
            authData.account = account
            authData.password = password
            triggerClientEvent(client, 'onSignInNeed2FA', resourceRoot)
        end
    else
        local attemptMessage = handleAttempt(client, 'signIn');
        triggerClientEvent(client, 'onSendNotifyToClient', resourceRoot, 'error', 'Неверный логин или пароль!', attemptMessage)
    end
end

---Проверка кодового слова 
---@param secretCode string Кодовое слово
function Server.onRequestCheck2FAHandler(secretCode)
    local account, password = authData.account, authData.password
    local accountSecret = getAccountData(account, 'loginPanel.secretCode')

    if accountSecret == secretCode then
        completePlayerSignIn(client, account, password)
    else
        local attemptMessage = handleAttempt(client, 'check2FA');
        triggerClientEvent(client, 'onSendNotifyToClient', resourceRoot, 'error', 'Неверное кодовое слово!', attemptMessage)
    end
end

---Устанавливает приватный ключ
---@param account userdata
---@param rawKey string
---@return boolean
local function setPrivateKey(account, rawKey)
    local key = toJSON(rawKey)
    return setAccountData(account, 'loginPanel.privateKey', key)
end

---Получает приватный ключ
---@param account userdata Аккаунт
---@return string|nil
local function getPrivateKey(account)
    local rawKey = getAccountData(account, 'loginPanel.privateKey')

    if not rawKey then return end
    local key = fromJSON(rawKey)
    return tostring(key)
end

---Шифрования данных аутентификации
---@param data string Данные, которые необходимо зашифровать
function Server.onRequestEncryptAuthDataHandler(data)
    local player = client
    local authData = fromJSON(data)

    if not authData then return end
    local account = getAccount(authData.login, authData.password)

    local privateKey, publicKey = generateKeyPair('rsa', { size = 1024 });

    if not account or not privateKey then return end
    setPrivateKey(account, privateKey)

    local co = coroutine.create(function ()
        local encryptedData = coroutine.yield()
        triggerClientEvent(player, 'onEncryptAuthDataSuccess', resourceRoot, encryptedData)
    end)

    coroutine.resume(co)

    encodeString('rsa', data, { key = publicKey }, function (result)
        coroutine.resume(co, result)
    end)
end


---Дешифровка данных аутентификации
---@param data string Данные, которые необходимо расшифровать
function Server.onRequestDecryptAuthDataHandler(data)
    local playerSerial = getPlayerSerial(client)
    local account = (getAccountsBySerial(playerSerial) or {})[1]

    if not account then return end
    local privateKey = getPrivateKey(account)

    if not privateKey then return end
    local decryptedData = decodeString('rsa', data, { key = privateKey })

    if not decryptedData then return end
    triggerClientEvent(client, 'onDecryptAuthDataSuccess', resourceRoot, decryptedData)
end