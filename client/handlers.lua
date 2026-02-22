---Модуль клиентских обработчиков ивентов
---@module 'handlers'
Handlers = {}

---Обработчик события старта ресурса
function Handlers.onResourceStart()
    Client.restrictPlayerUntilAuth()
    Client.showBrowser()
    Client.decryptAuthData()
end



---РЕГИСТРАЦИЯ

---@class SignUpData
---@field login string Логин
---@field password string Пароль
---@field secretPhrase string Кодовая фраза

---Обработчик запроса на регистрацию
---@param rawSignUpData string JSON-строка с данными регистрации
function Handlers.onRequestSignUp(rawSignUpData)
    Client.setLoadingForm(true)

    ---@type SignUpData
    local signUpData = fromJSON(rawSignUpData)

    if not signUpData then return end
    triggerServerEvent( 'onRequestSignUp', resourceRoot, signUpData.login, signUpData.password, signUpData.secretPhrase)
end

---Обработчик успешной регистрации
function Handlers.onSignUpSuccess()
    Client.setLoadingForm(false)
    Client.navigateTo('signIn')
    Client.notify('info', 'Вы успешно зарегистрировались!', 'Войдите в аккаунт')
end

---Обработчик неудачной попытки регистрации
---@param type 'success'|'info'|'warning'|'error' Тип уведомления
---@param message string Сообщение уведомления
---@param description string Описание уведомления
function Handlers.onSignUpFailure(type, message, description)
    Client.notify(type, message, description)
    Client.setLoadingForm(false)
end



---АВТОРИЗАЦИЯ

---@class SignInData
---@field login string Логин
---@field password string Пароль
---@field rememberMe boolean Запоминать данные авторизации

---Обработчик запроса на авторизацию
---@param rawSignInData string JSON-строка с данными авторизации
function Handlers.onRequestSignIn(rawSignInData)
    Client.setLoadingForm(true)

    ---@type SignInData
    local signInData = fromJSON(rawSignInData)

    if not signInData then return end
    triggerServerEvent('onRequestSignIn', resourceRoot, signInData.login, signInData.password)

    if not signInData.rememberMe then return end
    Client.prepareAuthData(signInData.login, signInData.password)
end

---Обработчик успешной авторизации
function Handlers.onSignInSuccess()
    Client.notify('success', 'Вы успешно авторизовались!')
    Client.releasePlayerAfterAuth()

    if Client.preparedAuthData then
        triggerServerEvent('onRequestEncryptAuthData', resourceRoot, Client.preparedAuthData)
    else
        Client.deleteAuthData()
    end
end

---Обработчик неудачной попытки авторизации
---@param attemptMessage string Описание уведомления
function Handlers.onSignInFailure(attemptMessage)
    Client.notify('error', 'Неверный логин или пароль!', attemptMessage)
    Client.setLoadingForm(false)
end



---КОДОВАЯ ФРАЗА

---Обработчик запроса кодовой фразы
function Handlers.onSignInNeed2FA()
    Client.setLoadingForm(false)
    Client.navigateTo('verification')
end

---Обработчик запроса проверки кодовой фразы
---@param secretPhrase string Кодовая фраза
function Handlers.onRequestCheck2FA(secretPhrase)
    Client.setLoadingForm(true)
    triggerServerEvent('onRequestCheck2FA', resourceRoot, secretPhrase)
end

---Обработчик неудачной попытки проверки кодовой фразы
function Handlers.onCheck2FAFailure(attemptMessage)
    Client.notify('error', 'Неверная кодовая фраза!', attemptMessage)
    Client.setLoadingForm(false)
end



---ДАННЫЕ АУТЕНТИФИКАЦИИ

---Хендлер на успешную шифровку данных аутентификации
---@param encryptedData string Зашифрованные данные
function Handlers.onEncryptAuthDataSuccess(encryptedData)
    Client.saveAuthData(encryptedData)
end

---@class AuthData
---@field login string Логин
---@field password string Пароль

---Хендлер на успешную дешифровку файла авторизации и подстановка значений в поля ввода
---@param decryptedData string Расшифрованные данные
function Handlers.onDecryptAuthDataSuccess(decryptedData)
    ---@type AuthData
    local authData = fromJSON(decryptedData)

    Client.setFormValue(authData.login, authData.password)
end



---УВЕДОМЛЕНИЯ

---Обрабочик уведомления
---@param type 'success'|'info'|'warning'|'error' Тип уведомления
---@param message string Сообщение
---@param description string|nil Описание
function Handlers.onSendNotifyToClient(type, message, description)
    Client.notify(type, message, description)
end