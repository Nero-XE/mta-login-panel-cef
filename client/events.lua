addEventHandler('onClientResourceStart', resourceRoot, Client.resourceStartHandler, false)

--Хендлеры регистрации
addEvent('requestSignUp', true)
addEventHandler('requestSignUp', resourceRoot, Client.requestSignUpHandler, true)

addEvent('onSignUpSuccess', true)
addEventHandler('onSignUpSuccess', resourceRoot, Client.onSignUpSuccessHandler, false)

addEvent('onSignUpFailure', true)
addEventHandler('onSignUpFailure', resourceRoot, Client.onSignUpFailureHandler, false)

--Хендлеры авторизации
addEvent('requestSignIn', true)
addEventHandler('requestSignIn', resourceRoot, Client.requestSignInHandler, true)

addEvent('onSignInSuccess', true)
addEventHandler('onSignInSuccess', resourceRoot, Client.onSignInSuccessHandler, false)

addEvent('onSignInFailure', true)
addEventHandler('onSignInFailure', resourceRoot, Client.onSignInFailureHandler, false)

--Хендлеры кодового слова
addEvent('onSignInNeed2FA', true)
addEventHandler('onSignInNeed2FA', resourceRoot, Client.onSignInNeed2FAHandler, false)

addEvent('requestCheck2FA', true)
addEventHandler('requestCheck2FA', resourceRoot, Client.requestCheck2FAHandler, true)

addEvent('onCheck2FAFailure', true)
addEventHandler('onCheck2FAFailure', resourceRoot, Client.onCheck2FAFailureHandler, true)

--Хендлеры на расшифровку файла с данными аутентификации
addEvent('onEncryptAuthDataSuccess', true)
addEventHandler('onEncryptAuthDataSuccess', resourceRoot, Client.onEncryptAuthDataSuccessHandler, false)

addEvent('onDecryptAuthDataSuccess', true)
addEventHandler('onDecryptAuthDataSuccess', resourceRoot, Client.onDecryptAuthDataSuccessHandler, false)

--Ивент уведомлений (используется для вызова сервером)
addEvent('onSendNotifyToClient', true)
addEventHandler('onSendNotifyToClient', resourceRoot, Client.onSendNotifyToClientHandler, false)