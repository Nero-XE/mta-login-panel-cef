---Менеджер файлов
FileManager = {
    filePath = nil
}

---Устанавливает путь к файлу
---@param path string
---@return true
function FileManager:setFilePath(path)
    self.filePath = path
    return true
end

---Создает файл
---@return boolean
function FileManager:createFile()
    local file = fileCreate(self.filePath)

    if not file then return false end
    fileClose(file)

    return true
end

---Передает ссылку на файл
---@param mode 'read'|'write' Режим работы с файлом
---@return false|userdata
function FileManager:getFile(mode)
    local parsedMode = { read = true, write = false }

    local file = fileOpen(self.filePath, parsedMode[mode])

    if not file then return false end
    return file
end

---Проверка наличия файла
---@return boolean
function FileManager:isFileExists()
    local isFileExists = fileExists(self.filePath)

    return isFileExists
end

---Получает данные из файла
---@return false|string
function FileManager:getFileContent()
    local file = self:getFile('read')

    if not file then return false end
    local fileSize = fileGetSize(file)
    local fileContent = fileRead(file, fileSize)

    fileClose(file)
    return fileContent
end

---Помещает данные в файл
---@param content string
---@return boolean
function FileManager:setFileContent(content)
    local file = self:getFile('write')

    if not file then return false end
    fileWrite(file, content)

    fileClose(file)
    return true
end

---Удаляет файл
---@return boolean
function FileManager:deleteFile()
    local result = fileDelete(self.filePath)
    return result
end