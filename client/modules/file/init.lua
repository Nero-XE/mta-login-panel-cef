---@class File
---@field private path string Директория расположения файла
---@field private name string Имя файла
---@field private extension string Расширение файла
---@field private filePath string Полный путь до файла
File = {}

---Формирование полного пути к файлу
---@param path string Директория расположения файла
---@param name string Имя файла
---@param extension string Расширение файла
---@return string # Полный путь к файлу
local function buildFullPath(path, name, extension)
    local formatPath = path:gsub("[/\\]+$", "")
    local formatExtension = extension:gsub("^%.", "")

    return string.format('%s/%s.%s', formatPath, name, formatExtension)
end

---Создание экземпляра класса
---@param path string Директория расположения файла
---@param name string Имя файла
---@param extension string Расширение файла
---@return File
function File.new(path, name, extension)
    local state = {
        path = path,
        name = name,
        extension = extension,
        filePath = buildFullPath(path, name, extension),
    }

    return setmetatable(state, { __index = File })
end

---Создание файла
---@return boolean # Возвращает true при успешном создании файла и false во всех остальных
function File:create()
    if self:isExists() then
        outputDebugString('Файл по указному пути уже существует!', 1)
        return false
    end

    local file = fileCreate(self.filePath)

    if not file then return false end
    return fileClose(file)
end

---Открытие файла
---@param path string Полный путь до файла
---@param isReadOnly boolean Открывать файл в режиме чтения
---@return userdata|false # Возвращает файл при успешном открытии файла и false во всех остальных случаях
local function openFile(path, isReadOnly)
    local file = fileOpen(path, isReadOnly)
    return file
end

---Чтение содержимого файла
---@return false|string
function File:read()
    local file = openFile(self.filePath, true)

    if not file then
        outputDebugString('Невозможно открыть файл для чтения!', 1)
        return false
    end

    local fileContent = fileRead(file, fileGetSize(file))
    fileClose(file)

    return fileContent
end

---Добавление содержимого в файл
---@param ... string Контент для записи. Можно передавать неограниченное кол-во аргументов
---@return boolean # Возвращает true при успешной записи в файл и false во всех остальных случаях
function File:append(...)
    local file = openFile(self.filePath, false)

    if not file then
        outputDebugString('Невозможно открыть файл для записи!', 1)
        return false
    end

    fileSetPos(file, fileGetSize(file))
    fileWrite(file, ...)
    return fileClose(file)
end

---Перезапись содержимого файла
---@param ... string Контент для записи. Можно передавать неограниченное кол-во аргументов
---@return boolean # Возвращает true при успешной записи в файл и false во всех остальных случаях
function File:rewrite(...)
    local file = openFile(self.filePath, false)

    if not file then
        outputDebugString('Невозможно открыть файл для записи!', 1)
        return false
    end

    fileWrite(file, ...)
    return fileClose(file)
end

---Переименование файла
---@param newName string Новое имя файла
---@return boolean # Возвращает true при успешном переименовании файла и false во всех остальных случаях
function File:rename(newName)
    local newFilePath = buildFullPath(self.path, newName, self.extension)

    local result = fileRename(self.filePath, newFilePath)

    if not result then
        outputDebugString('Невозможно переименовать файл!', 1)
        return false
    end

    return result
end

---Перемещение файла
---@param newPath string Новая директория файла
---@return boolean # Возвращает true при успешном перемещении файла и false во всех остальных случаях
function File:move(newPath)
    local newFilePath = buildFullPath(newPath, self.name, self.extension)
    outputChatBox(newFilePath)
    outputChatBox(self.filePath)

    local result = fileRename(self.filePath, newFilePath)

    if not result then
        outputDebugString('Невозможно переместить файл!', 1)
        return false
    end

    return result
end

---Удаление файла
---@return boolean # Возвращает true при успешном удалении файла и false во всех остальных случаях
function File:delete()
    return fileDelete(self.filePath)
end

---Проверка наличия файла
---@return boolean # Возвращает true при существовании файла и false при отсутствии
function File:isExists()
    return fileExists(self.filePath)
end

---@class HMACOptions
---@field algorithm 'md5'|'sha1'|'sha224'|'sha256'|'sha384'|'sha512' Алгоритм, используемый внутри HMAC
---@field key string Ключ шифрования для HMAC

---Получения хеша файла по алгоритму
---@param algorithm 'md5'|'sha1'|'sha224'|'sha256'|'sha384'|'sha512'|'hmac' Алгоритм
---@param options HMACOptions|nil Обязательное поле только при алгоритме hmac
---@return false|string
function File:getHash(algorithm, options)
    local file = openFile(self.filePath, true)

    if not file then
        outputDebugString('Невозможно открыть файл для получения хеша!', 1)
        return false
    end

    local fileHash = nil

    if algorithm == 'hmac' then
        if not options then
            outputDebugString('Для алгоритма HMAC требуется параметр options!', 1)
            return false
        end
        ---@cast algorithm 'hmac'
        fileHash = fileGetHash(file, algorithm, options)
    else
        ---@cast algorithm 'md5'|'sha1'|'sha224'|'sha256'|'sha384'|'sha512'
        fileHash = fileGetHash(file, algorithm)
    end

    if not fileHash then
        outputDebugString('Не удалось получить хеш файла!', 1)
        return false
    end

    fileClose(file)
    return fileHash
end