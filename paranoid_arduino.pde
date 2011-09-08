/* Paranoid Arduino Client */

#include <SPI.h>
#include <Ethernet.h>
#include <HTTPClient.h>
#include <stdio.h>
#include <stdlib.h>

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 10, 0, 1, 11 };
byte server[] = { 109, 74, 197, 203 };

#define HOSTNAME "paranoid_proxy.matiaskorhonen.fi"
#define TWEETS_URI "/tweets.json"

// Initialize the Ethernet client library
// with the IP address and port of the server 
// that you want to connect to (port 80 is default for HTTP):
Client client(server, 80);

void setup() {
  Serial.begin(9600);
  Ethernet.begin(mac, ip);
  delay(1000);

  // if you get a connection, report back via serial:
  if (client.connect()) {
    Serial.println("Connected");
    client.println("GET /tweets.json HTTP/1.0");
    client.println("Host: paranoid_proxy.matiaskorhonen.fi");
    client.println("User-Agent: ParanoidArduino");
    client.println();
  }
  else {
    // kf you didn't get a connection to the server:
    Serial.println("Connection failed");
  }
}

void loop() {
  // if there are incoming bytes available 
  // from the server, read them and print them:
  String response = "";

  if (client.available()) {
    bool more = true;
    while (more) {
      char c = client.read();
      if (c != -1) {
        response = response + String(c);
      } else {
        more = false;
      }
    }

    Serial.print(response);

    int start_of_content_length = response.indexOf("Content-Length: ");
    int end_of_content_length = response.indexOf("\n", start_of_content_length + 17);
    String content_length = response.substring(start_of_content_length + 16, end_of_content_length);

    char buf[10];
    content_length.toCharArray(buf, 10);
    int cl_int = atoi ( buf );
    int body_start = response.length() - cl_int;

    Serial.print("CL:");
    Serial.println(cl_int);

    String body = response.substring(body_start, response.length());
    Serial.println(body.length());
    Serial.println("BODY:");
    Serial.println(body);
  }

  delay(5000);

  // if the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();

    // do nothing forevermore:
    for(;;)
      ;
  }
}

void connect() {
  
}