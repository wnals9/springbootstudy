package com.gdu.test.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class ChatController {
	
	@RequestMapping("/chat.do")
	public ModelAndView chat() {
		ModelAndView mv = new ModelAndView();
		mv.setViewName("layout/chat");
		return mv;
	}
}
