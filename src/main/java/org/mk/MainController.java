package org.mk;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@EnableAutoConfiguration
public class MainController {

    private static final Logger log = LoggerFactory.getLogger(MainController.class);

    @RequestMapping("/")
    public String welcome(Map<String, Object> model) {
        return "welcome";
    }

    @RequestMapping("/ping")
    @ResponseBody
    public String getPong() {
        log.info("pong");
        return "pong";
    }

    @RequestMapping("/date")
    @ResponseBody
    public String getCurrentDate() {
        SimpleDateFormat sdf = new SimpleDateFormat("dd-M-yyyy");
        String date = sdf.format(new Date()); 
        
        log.info("Current date: " + date);
        return "Current date: " + date;
    }
}
