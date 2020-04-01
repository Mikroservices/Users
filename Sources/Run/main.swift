import App
import Vapor
import Recaptcha

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
defer { app.shutdown() }

app.server.configuration.port = 8082

try configure(app)
try app.run()
