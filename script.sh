#!/bin/bash

# Create directory structure
mkdir -p ip-info-app/src/main/{java/com/example/ipinfo,resources}

# Create the main application class
cat << EOF > ip-info-app/src/main/java/com/example/ipinfo/IPInfoApplication.java
package com.example.ipinfo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class IPInfoApplication {

    public static void main(String[] args) {
        SpringApplication.run(IPInfoApplication.class, args);
    }
}
EOF

# Create the controller class
cat << EOF > ip-info-app/src/main/java/com/example/ipinfo/IPInfoController.java
package com.example.ipinfo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class IPInfoController {

    @Autowired
    private RestTemplate restTemplate;

    private final String ipGeolocationApiUrl = "https://api.ipgeolocation.io/ipgeo?apiKey=YOUR_API_KEY";

    @GetMapping("/")
    public String getIPInfo() {
        String ipInfo = restTemplate.getForObject(ipGeolocationApiUrl, String.class);
        return ipInfo;
    }
}
EOF

# Create the application properties file
cat << EOF > ip-info-app/src/main/resources/application.properties
# Set server port
server.port=8080
EOF

# Print instructions
echo "Directory structure and files created successfully."

