---Класс данных авторизации
---@class AuthData
---@field private file File Инстанс класса файла с зашифрованными данными авторизации
AuthData = {}

---Создание инстанса класса
---@return AuthData
function AuthData.new()
    local state = {
        file = File.new('cache', 'authData', 'enc')
    }
    return setmetatable(state, { __index = AuthData })
end

---Возвращает содержимое файла аутентификации
---@return string|false
function AuthData:getData()
    return self.file:read()
end

---Синхронизация данных авторизации
---@param data string Зашифрованные данные для записи
function AuthData:syncData(data)
    if self.file:isExists() then
        self.file:rewrite(data)
    else
        self.file:create()
        self.file:rewrite(data)
    end
end

---Удаление файла данных авторизации
function AuthData:delete()
    self.file:delete()
end