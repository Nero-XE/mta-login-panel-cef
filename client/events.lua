---Старт ресурса
addEventHandler('onClientResourceStart', resourceRoot, Handlers.onResourceStart, false)



---Регистраця
addEvent('requestSignUp', true)
addEventHandler('requestSignUp', resourceRoot, Handlers.onRequestSignUp, true)

addEvent('onSignUpSuccess', true)
addEventHandler('onSignUpSuccess', resourceRoot, Handlers.onSignUpSuccess, false)

addEvent('onSignUpFailure', true)
addEventHandler('onSignUpFailure', resourceRoot, Handlers.onSignUpFailure, false)



---Авторизация
addEvent('requestSignIn', true)
addEventHandler('requestSignIn', resourceRoot, Handlers.onRequestSignIn, true)

addEvent('onSignInSuccess', true)
addEventHandler('onSignInSuccess', resourceRoot, Handlers.onSignInSuccess, false)

addEvent('onSignInFailure', true)
addEventHandler('onSignInFailure', resourceRoot, Handlers.onSignInFailure, false)



---Кодовая фраза
addEvent('onSignInNeed2FA', true)
addEventHandler('onSignInNeed2FA', resourceRoot, Handlers.onSignInNeed2FA, false)

addEvent('requestCheck2FA', true)
addEventHandler('requestCheck2FA', resourceRoot, Handlers.onRequestCheck2FA, true)

addEvent('onCheck2FAFailure', true)
addEventHandler('onCheck2FAFailure', resourceRoot, Handlers.onCheck2FAFailure, true)



---Расшифровка файлов с данными аутентификации
addEvent('onEncryptAuthDataSuccess', true)
addEventHandler('onEncryptAuthDataSuccess', resourceRoot, Handlers.onEncryptAuthDataSuccess, false)

addEvent('onDecryptAuthDataSuccess', true)
addEventHandler('onDecryptAuthDataSuccess', resourceRoot, Handlers.onDecryptAuthDataSuccess, false)



---Вызов уведомлений (используется для вызова сервером)
addEvent('onSendNotifyToClient', true)
addEventHandler('onSendNotifyToClient', resourceRoot, Handlers.onSendNotifyToClient, false)