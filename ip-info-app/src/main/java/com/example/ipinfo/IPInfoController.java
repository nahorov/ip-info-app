package com.example.ipinfo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class IPInfoController {

    @Autowired
    private RestTemplate restTemplate;

    private final String ipGeolocationApiUrl = "https://api.ipgeolocation.io/ipgeo?apiKey=83ec4d1952704eebb85307e3e969eea2";

    @GetMapping("/")
    public String getIPInfo() {
        String ipInfo = restTemplate.getForObject(ipGeolocationApiUrl, String.class);
        return ipInfo;
    }
}
