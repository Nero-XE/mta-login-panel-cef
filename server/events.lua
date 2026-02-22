addEventHandler('onPlayerJoin', root, Server.restrictPlayerUntilAuth)

addEvent('onRequestSignUp', true)
addEventHandler('onRequestSignUp', resourceRoot, Handlers.onRequestSignUp, false)

addEvent('onRequestSignIn', true)
addEventHandler('onRequestSignIn', resourceRoot, Handlers.onRequestSignIn, false)

addEvent('onRequestCheck2FA', true)
addEventHandler('onRequestCheck2FA', resourceRoot, Handlers.onRequestCheck2FA, false)

addEvent('onRequestEncryptAuthData', true)
addEventHandler('onRequestEncryptAuthData', resourceRoot, Handlers.onRequestEncryptAuthData, false)

addEvent('onRequestDecryptAuthData', true)
addEventHandler('onRequestDecryptAuthData', resourceRoot, Handlers.onRequestDecryptAuthData, false)