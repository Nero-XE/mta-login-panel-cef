---Модуль логики работы с файлом аутентификации
AuthDataManager = {
    filePath = 'cache/authData.enc'
}

---Возвращает содержимое файла аутентификации
---@return string|false
function AuthDataManager:getFileContent()
    FileManager:setFilePath(self.filePath)
    return FileManager:getFileContent()
end

---Управляет содержимым файла с данными аутентификации
---@param authData string
---@return boolean|nil
function AuthDataManager:syncDataToFile(authData)
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
function AuthDataManager:deleteDataFile()
    FileManager:setFilePath(self.filePath)
    FileManager:deleteFile()
end