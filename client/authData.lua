---Модуль логики работы с файлом аутентификации
AuthData = {
    filePath = 'cache/authData.enc'
}

---Возвращает содержимое файла аутентификации
---@return string|false
function AuthData:getFileContent()
    FileManager:setFilePath(self.filePath)
    return FileManager:getFileContent()
end

---Управляет содержимым файла с данными аутентификации
---@param authData string
---@return boolean|nil
function AuthData:syncDataToFile(authData)
    FileManager:setFilePath(self.filePath)
    local isAuthDataFileExists = FileManager:isFileExists()

    if isAuthDataFileExists then
        FileManager:setFileContent(authData)
    else
        FileManager:createFile()
        FileManager:setFileContent(authData)
    end
end

---Удаляет файл с данными аутентификации
function AuthData:deleteDataFile()
    FileManager:setFilePath(self.filePath)
    FileManager:deleteFile()
end