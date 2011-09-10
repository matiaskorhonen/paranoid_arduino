/*
  Paranoid Arduino Client

  MIT licensed. Copyright 2011 Matias Korhonen.
*/

#include <SPI.h>
#include <Ethernet.h>
#include <HTTPClient.h>
#include <stdio.h>
#include <stdlib.h>

byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 10, 0, 1, 11 };
byte server[] = { 109, 74, 197, 203 };

// Initialize the Ethernet client library
Client client(server, 80);

void setup() {
  Serial.begin(9600);
  Ethernet.begin(mac, ip);
  delay(1000);

  connect();
}

void loop() {
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

    int start_of_content_length = response.indexOf("Content-Length: ");
    int end_of_content_length = response.indexOf("\n", start_of_content_length + 17);

    String length_str = response.substring(start_of_content_length + 16, end_of_content_length);

    char length_buf[10];
    length_str.toCharArray(length_buf, 10);
    int length = atoi(length_buf);
    int body_start = response.length() - length;

    String body = response.substring(body_start, response.length());
    Serial.print("Latest Tweet mentioning @paranoid_arduino: ");
    Serial.println(body);
  }

  delay(5000);

  // If the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println();
    Serial.println("Disconnected. Reconnecting.");
    connect();
  }
}

void connect() {
  // If you get a connection, report back via serial:
  if (client.connect()) {
    Serial.println("Connected.");
    client.println("GET /latest.txt HTTP/1.1");
    client.println("Host: paranoid_proxy.matiaskorhonen.fi");
    client.println("User-Agent: ParanoidArduino");
    client.println();
  }
  else {
    // If you didn't get a connection to the server:
    Serial.println("Connection failed. Retrying in 5000 milliseconds.");
    delay(5000);
    connect();
  }
}