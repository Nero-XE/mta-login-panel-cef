---Модуль серверной логики аутентификации
---@module 'server'
Server = {}

---Установка ограничений для подключившихся игроков
function Server.restrictPlayerUntilAuth()
    source:setFrozen(true)
    source:setDimension(1)
    source:setCameraMatrix(-2643.740, 867.610, 76.273)
end

---Обрабатывает попытку операции с проверкой лимита
---@param player element Игрок
---@param attemptType 'signUp'|'signIn'|'check2FA' Тип операции
---@return string|nil
function Server.handleAttempt(player, attemptType)
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
            actionName = 'проверки кодовой фразы'
        }
    }

    local config = configs[attemptType]

    local limit = tonumber(get(resourceName .. "." .. config.settingKey)) or 0

    local currentAttempts = player:getData(config.dataKey) or 0
    currentAttempts = currentAttempts + 1
    player:setData(config.dataKey, currentAttempts)

    if currentAttempts >= limit then
        local kickMsg = string.format('Слишком много попыток %s', config.actionName)
        if isElement(player) then
            player:kick(kickMsg)
        end
    else
        return string.format('Попытка %s №%d из %d', config.actionName, currentAttempts, limit)
    end
end