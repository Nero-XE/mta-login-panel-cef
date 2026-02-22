---Модуль серверных обработчиков ивентов
---@module 'handlers'
Handlers = {}

---Регистрация нового аккаунта
---@param login string Логин для нового аккаунта
---@param password string Пароль для нового аккаунта
---@param secretCode string Кодовое слово для нового аккаунта
function Handlers.onRequestSignUp(login, password, secretCode)
    local playerSerial = client:getSerial()
    local accounts = getAccountsBySerial(playerSerial)

    if #accounts == 0 then
        local addedAccount = Account.add(login, password)
        if addedAccount then
            addedAccount:setData('loginPanel.secretCode', secretCode)
            addedAccount:setSerial(playerSerial)
            triggerClientEvent(client, 'onSignUpSuccess', resourceRoot)
        else
            local attemptMessage = Server.handleAttempt(client, 'signUp')
            triggerClientEvent(client, 'onSignUpFailure', resourceRoot, 'warning', 'Введенный логин уже занят!', attemptMessage)
        end
    else
        local attemptMessage = Server.handleAttempt(client, 'signUp')
        triggerClientEvent(client, 'onSignUpFailure', resourceRoot, 'error', 'На этом устройстве уже зарегистрирован аккаунт!', attemptMessage)
    end
end

---@class TempAuthData
---@field account userdata Аккаунт
---@field password string Пароль

---Авторизация игрока с проверкой на вход с нового компьютера
---@param login string Логин от аккаунта
---@param password string Пароль от аккаунта
function Handlers.onRequestSignIn(login, password)
    local account = Account(login, password)

    if account then
        if account:getSerial() == client:getSerial() then
            client:logIn(account, password)
            triggerClientEvent(client, 'onSignInSuccess', resourceRoot)
        else
            ---@type TempAuthData
            local tempAuthData = {
                account = account,
                password = password,
            }
            client:setData('loginPanel.tempAuthData', tempAuthData, 'local')
            triggerClientEvent(client, 'onSignInNeed2FA', resourceRoot)
        end
    else
        local attemptMessage = Server.handleAttempt(client, 'signIn')
        if not isElement(client) then return end
        triggerClientEvent(client, 'onSignInFailure', resourceRoot, attemptMessage)
    end
end

---Проверка кодовой фразы
---@param secretPhrase string Кодовое слово
function Handlers.onRequestCheck2FA(secretPhrase)
    ---@type TempAuthData
    local tempAuthData = client:getData('loginPanel.tempAuthData')
    local accountSecretPhrase = tempAuthData.account:getData('loginPanel.secretCode')

    if accountSecretPhrase == secretPhrase then
        client:logIn(tempAuthData.account, tempAuthData.password)
        triggerClientEvent(client, 'onSignInSuccess', resourceRoot)
        client:setData('loginPanel.tempAuthData', false)
    else
        local attemptMessage = Server.handleAttempt(client, 'check2FA')
        triggerClientEvent(client, 'onCheck2FAFailure', resourceRoot, attemptMessage)
    end
end

---@class AuthData
---@field login string Аккаунт
---@field password string Пароль

---Шифрования данных аутентификации
---@param data string Данные, которые необходимо зашифровать
function Handlers.onRequestEncryptAuthData(data)
    ---@type AuthData
    local authData = fromJSON(data)
    local account = Account(authData.login, authData.password)

    local privateKey, publicKey = generateKeyPair('rsa', { size = 1024 })

    account:setData('loginPanel.privateKey', toJSON(privateKey))

    local encryptedData = encodeString('rsa', data, { key = publicKey })
    triggerClientEvent(client, 'onEncryptAuthDataSuccess', resourceRoot, encryptedData)
end

---Дешифровка данных аутентификации
---@param data string Данные, которые необходимо расшифровать
function Handlers.onRequestDecryptAuthData(data)
    local account = (Account.getAllBySerial(client:getSerial()) or {})[1]

    if not account then return end

    local privateKey = account:getData('loginPanel.privateKey')
    local decryptedData = decodeString('rsa', data, { key = fromJSON(privateKey )})

    triggerClientEvent(client, 'onDecryptAuthDataSuccess', resourceRoot, decryptedData)
end