addEventHandler('onPlayerJoin', root, Server.restrictPlayerUntilAuth)

addEvent('onRequestSignUp', true)
addEventHandler('onRequestSignUp', resourceRoot, Server.onRequestSignUpHandler, false)

addEvent('onRequestSignIn', true)
addEventHandler('onRequestSignIn', resourceRoot, Server.onRequestSignInHandler, false)

addEvent('onRequestCheck2FA', true)
addEventHandler('onRequestCheck2FA', resourceRoot, Server.onRequestCheck2FAHandler, false)

addEvent('onRequestEncryptAuthData', true)
addEventHandler('onRequestEncryptAuthData', resourceRoot, Server.onRequestEncryptAuthDataHandler, false)

addEvent('onRequestDecryptAuthData', true)
addEventHandler('onRequestDecryptAuthData', resourceRoot, Server.onRequestDecryptAuthDataHandler, false)