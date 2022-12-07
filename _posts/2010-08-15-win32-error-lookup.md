---
layout: post
categories: programming
image: https://t1.daumcdn.net/cfile/tistory/186279354C66B14586
title: Windows Api의 에러 번호를 확인하는 가장 간편한 방법
date: 2010-08-15 00:15:00 +0900
---

Windows 프로그래머라면 Windows Api의 에러코드에 익숙해야 한다.  
[자주 쓰이는 에러코드는 숫자만 봐도 그냥 외우고 있어야 한다.](https://devblogs.microsoft.com/oldnewthing/20100127-00/?p=15163)  

하지만 모든 에러 코드를 외울 수는 없는 법.  
빨리 빨리 찾아볼 수 있는 방법은 없을까?

많은 사람들이 비주얼 스튜디오의 Error Lookup 도구를 사용하는 걸 보고 이 방법을 모르는 사람들이 많다는 걸 알게 되었다.

![net helpmsg](https://t1.daumcdn.net/cfile/tistory/186279354C66B14586)

이보다 더 편할 방법이 있을까?

여담이지만, 응용 프로그램 레벨에서는 Win32 에러를 받게 되지만 커널 모드에서 디바이스 드라이버를 만드는 사람들은 `NTSTATUS` 에러값과 더 친숙해야 한다.  
[이 페이지](https://www.osr.com/blog/2020/04/23/ntstatus-to-win32-error-code-mappings/)에 커널 코드에서 리턴 되는 `NTSTATUS` 에러 코드가 어떤 Win32 에러 코드로 매핑되는지 나와있다.