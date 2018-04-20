// This is server implementation for secured connection (HTTPS) scenario
import ballerina/io;
import ballerina/log;
import ballerina/grpc;

endpoint grpc:Listener ep {
    host:"localhost",
    port:9090,
    secureSocket: {
                      keyStore: {
                                    filePath: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
                                    password: "ballerina"
                                },
                      trustStore: {
                                      filePath: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
                                      password: "ballerina"
                                  },
                      protocol: {
                                    name: "TLSv1.2",
                                    versions: ["TLSv1.2","TLSv1.1"]
                                },
                      ciphers:["TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"],
                      sslVerifyClient:"require"
                  }

};
@grpc:serviceConfig
service<grpc:Service> HelloWorld bind ep {
    hello(endpoint caller, string name) {
        io:println("name: " + name);
        string message = "Hello " + name;
        error? err = caller->send(message);
        io:println(err.message but { () => "Server send response : " + message });
        _ = caller->complete();
    }
}
