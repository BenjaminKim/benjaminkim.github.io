---
layout: post
categories: essay
image: https://image.aladin.co.kr/product/42/55/cover500/899539191x_1.gif
title: 소켓 프로그래밍을 배우기 좋은 책 - Effective TCP/IP Programming
date: 2011-03-15 06:48:00 +0900
---

![](https://image.aladin.co.kr/product/42/55/cover500/899539191x_1.gif)  
출처: [알라딘](http://www.aladin.co.kr/shop/wproduct.aspx?ISBN=6000244572&ttbkey=ttbcrazytazo1459001&COPYPaper=1)

Effective C++ 시리즈의 제목을 배낀 것(?)을 보면 알수 있듯이 스캇 마이어스의 Effective 시리즈와 똑같은 구성을 하고 있으며 C++이 아닌 TCP/IP 프로그래밍에 대한 내용을 다룬다는 것이 차이점이다.  
Effective 시리즈가 워낙 잘 쓰여진 책이라 다른 Effective 아류작들을 읽으면 실망하곤 했는데, 이 책은 아주 만족스러웠다.  
도서관에서 빌려보려 했는데 책이 없길래 그냥 한 권 구입했는데 사두길 참 잘했다는 생각이 든다.

* TCP의 신뢰성 있는 전송이라는 것은 무슨 뜻인가. 어떻게 신뢰성을 보장하는가. 얼마나 신뢰할 수 있는가.
* 데이터가 유실된줄 알고 TCP에서 재전송을 시도했는데 이미 보냈던 데이터가 그제야 잘 도착했다. 재전송한 데이터는 어떻게 처리되는가.
* 소켓 API를 통해 상대방의 응용 프로그램에 내가 보낸 데이터가 잘 도착했는지 알 수 있을까?
* `send`(혹은 `write`)함수가 성공적으로 리턴된다는 것은 무엇을 뜻하는가.
* 통신 도중 응용 프로그램이 죽어버리거나 컴퓨터가 꺼져버리면 어떻게 되는가.
* `TIME_WAIT` 상태는 무엇이고 왜 존재하는가.
* scatter/gather I/O 혹은 Vectored I/O는 무엇이고 언제 사용하는가.

위와 같은 질문들에 대해서 고민해본 적이 있다면 이 책을 읽어보는 것이 큰 도움이 될 것이다.