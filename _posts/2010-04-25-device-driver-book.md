---
layout: post
categories: programming
image: https://image.aladin.co.kr/product/44/93/cover500/8956741476_1.gif
title: 윈도우 디바이스 드라이버에 관한 최고의 책
date: 2010-04-25 23:45:00 +0900
---

![Microsoft Windows Driver Model](https://image.aladin.co.kr/product/44/93/cover500/8956741476_1.gif)  
*[Microsoft Windows Driver Model](https://www.aladin.co.kr/shop/wproduct.aspx?ISBN=8956741476&ttbkey=ttbcrazytazo1459001&COPYPaper=1)*

드라이버 공부를 하기 위해 이런 저런 책들을 찾아봤는데 이 책 만큼 좋은 책은 없는 것 같다.

이 책은 WDM 드라이버를 만들기 위해서 알아야 할 모든 내용을 다루고 있다.  
2004년도에 국내에 번역이 되었고 Windows XP 까지 다루고 있으며 현재는 절판되었다.

비스타나 Windows 7이 나왔다고해서 이 책의 3판이 나올 것 같지는 않다.  
이제는 새 책이 나오더라도 WDF에 대한 책이나 몇 권 더 나오고 말지 않을까.  
그나마 드라이버에 관한 새 책이 나오더라도 어디에서도 번역하려하지 않을까봐 두렵다.

이 책은 전체적으로 사람들이 궁금해할만한 내용들에 대해서 잘 설명해주고 있으며 그 중 5장의 Irp의 처리과정은 이 책의 꽃이라 할 수 있다.  
나는 이 챕터를 5번도 넘게 읽은 것 같다.  
맨 처음 읽을 때는 도대체 무슨 소리인지 알수가 없었지만 한 번씩 다시 읽을 때마다 점점 명확해져 가는 것을 느낀다.

책의 내용 중 설명이 부족하거나 잘 이해가 가지 않는 내용이 있으면 [ReactOS](https://reactos.org/)의 코드를 함께 살펴보고는 하는데 이는 아주 많은 도움이 된다.  
물론 ReactOS의 구현이 윈도우즈의 구현과 완전히 같을 것이라 믿어서는 안되지만 참고용으로 보기에는 아주 훌륭하다.  
[ctags](https://en.wikipedia.org/wiki/Ctags#:~:text=Ctags%20is%20a%20programming%20tool,languages%20to%20aid%20code%20comprehension.&text=These%20tags%20allow%20definitions%20to,search%20engine%2C%20or%20other%20utility.) 같은 도구를 통해 전체 코드를 태깅 해놓고 필요할 때 빠르게 찾아갈 수 있도록 해두면 좋을 것이다.

재미있는 것은, ReactOS의 코드를 읽으면서 코드 작성자 중 눈에 익은 이름을 하나 발견했는데 바로 Windows Internals 5판의 공동저자로 참여한 Alex Ionescu 였다.  
작년에 Windows Internal 5/E이 나온다는 소식을 처음 들었을 때 나는 그의 이름을 처음 알았는데, [85년생의 젊은 친구가 5년쯤 전인 20살 때 I/O 매니저, 오브젝트 매니저, 프로세스 매니저등의 Windows executive 코드들을 거의 다 작성했다는 것에 너무 놀랐다.](https://reactos.org/wiki/User:Alex_Ionescu)

어느 날 이런 ReactOS가 잘 돌아는갈까 갑자기 궁금해져서 이미지를 받아 설치해봤었는데 Windows 95보다도 못한 그 조잡함에 경악을 하며 동시에 마이크로소프트가 얼마나 대단한지 새삼 깨달았다.
ReactOS는 10년 넘게 개발되면서 아직도 버전이 0.3인데, 얼른 얼른 발전해서 참고할 수 있는 코드들이 더 많아졌으면 좋겠다.

다음 글들은 osronline과 msdn에서 찾은 윈도우즈의 Irp 처리 방식을 다루는 좋은 문서들이다.
이 책에서 이미 이 내용들을 다 설명하고 있지만 함께 참고해서 읽다보면 이해를 도와줄 것이다.

* [The Windows XP IRP Completion Primer](http://www.opening-windows.com/techart_the_windows_xp_irp_completion_primer.htm)
* [Secrets of the Universe Revealed! - How NT Handles I/O Completion](http://www.osronline.com/article.cfm%5eid=83.htm)
* [Properly Pending IRPs - IRP Handling for the Rest of Us](http://www.osronline.com/article.cfm%5eid=21.htm)
* [The Truth About Cancel - IRP Cancel Operations (Part I)](http://www.osronline.com/article.cfm%5eid=78.htm)
* [The Truth About Cancel - IRP Cancel Operations (Part II)](http://www.osronline.com/article.cfm%5earticle=72.htm)
* [Rolling Your Own - Building IRPs to Perform I/O](http://www.osronline.com/article.cfm%5earticle=87.htm)
* [Beyond IRPs: Driver to Driver Communications](http://www.osronline.com/article.cfm%5earticle=177.htm)
* [Rules for Irp Dispatching and Completion Routines](http://www.osronline.com/article.cfm%5earticle=214.htm)
* [A Modest Proposal - A New View on I/O Cancellation](http://www.osronline.com/article.cfm%5earticle=37.htm)
* [That's Just the Way It Is - How NT Describes I/O Requests](http://www.osronline.com/article.cfm%5earticle=74.htm)
* [Handling IRPs: What Every Driver Writer Needs to Know](https://docs.microsoft.com/en-us/previous-versions/ms810023(v=msdn.10)?redirectedfrom=MSDN)
* [Different ways of handling IRPs - cheat sheet (part 1 of 2)](https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/different-ways-of-handling-irps-cheat-sheet)
* [Queuing and Dequeuing IRPs](https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/queuing-and-dequeuing-irps)
* [Canceling IRPs](https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/canceling-irps)
  <br>
  <br>
  *비슷한 글:*
* [윈도우에서 디바이스 드라이버를 만들 때 알아야 할 기초적인 내용들](/programming/2011/05/23/윈도우에서-디바이스-드라이버를-만들-때-알아야-할-기초적인-내용들.html)
* [디바이스 드라이버를 단일 실행파일로 배포하는 방법](/programming/2010/12/04/디바이스-드라이버를-단일-실행파일로-배포하는-방법.html)
* [유저모드에서 파일시스템 드라이버를 만들기](/essay/2010/10/17/유저모드에서-파일시스템-드라이버를-만들기.html)
* [윈도우 디바이스 드라이버를 개발하며 풀 태그를 확인하기](/essay/2010/11/10/pool-tag.html)
