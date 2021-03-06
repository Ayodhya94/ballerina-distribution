import ballerina/lang.'string as strings;
import ballerina/io;
import ballerinax/nats;

// Creates a NATS connection.
nats:Connection conn = new;

// Initializes the NATS Streaming listener.
listener nats:StreamingListener lis = new (conn);

// Binds the consumer to listen to the messages published to the 'demo' subject.
@nats:StreamingSubscriptionConfig {
    subject: "demo"
}
service demoService on lis {
    resource function onMessage(nats:StreamingMessage message) {
       // Prints the incoming message in the console.
       string|error messageData = strings:fromBytes(message.getData());
       if (messageData is string) {
            io:println("Received message: " + messageData);
       } else {
            io:println("Error occurred while obtaining message data.");
       }
    }

    resource function onError(nats:StreamingMessage message,
                              nats:Error errorVal) {
        io:println("Error occurred while consuming the message.");
    }
}
