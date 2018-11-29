import ballerina/http;
import ballerina/io;
import ballerina/log;

@http:ServiceConfig {
    basePath: "/hello"
}
service httpService on new http:Listener(9090) {

    @http:ResourceConfig {
        path: "/world",
        methods: ["POST"]
    }
    resource function httpResource(http:Caller caller, http:Request req) {
        http:Response resp = new;
        var payload = req.getTextPayload();
        if (payload is error) {
            log:printError("Error sending message", err = payload);
            resp.setPayload("Error in payload");
            resp.statusCode = 500;
        } else if (payload is string) {
            io:println(payload);
            resp.setPayload(string `HTTP POST received: {{untaint payload}}\n`);
        }

        var err = caller->respond(resp);
        if (err is error) {
            log:printError("Error in responding", err = err);
        }
    }

    @http:ResourceConfig {
        webSocketUpgrade: {
            upgradePath: "/ws",
            upgradeService: wsService
        }
    }
    resource function upgrader(http:Caller caller, http:Request req) {

    }
}


// Note: When a WebSocket upgrade path is defined in HTTP resource configuration.
// - Without service configuration for WebSocketService default values are taken for sub protocols, idle timeout etc...
// - If  WebSocketServiceConfig is defined without the path, sub protocols, idle timeout etc... can be configured.
// - If path is defined in the WebSocketServiceConfig it shall be ignored.
// - This service can also be bound to a different endpoint in which case the path configuration becomes useful.
//@http:WebSocketServiceConfig {
//
//}
service wsService = @http:WebSocketServiceConfig {subProtocols: ["xml, json"],
                                   idleTimeoutInSeconds: 20} service {

    resource function onOpen(http:WebSocketCaller caller) {
        io:println("New WebSocket connection: " + caller.id);
    }

    resource function onText(http:WebSocketCaller caller, string text) {
        io:println(text);
        var err = caller->pushText(text);
        if (err is error) {
            log:printError("Error sending message", err = err);
        }
    }

    resource function onIdleTimeout(http:WebSocketCaller caller) {
        io:println("Idle timeout: " + caller.id);
    }
};
