---
layout: post
categories: programming
image: https://t1.daumcdn.net/cfile/tistory/1250F9104CD6A09434
title: Windows의 세션, 윈도우 스테이션, 데스크탑에 대해 자세히 알아보기
date: 2010-11-07 18:23:00 +0900
---
윈도우즈의 세션과 윈도우 스테이션 그리고 윈도우 데스크탑은 많은 프로그래머들에게 생소하지만 잘 모르고 있으면 수많은 골치거리를 안겨주는 개념들이다.  
나는 지금까지 세션에 대해서만 어렴풋이 알고 있고 윈도우 스테이션과 데스크탑에 대해서는 전혀 모르고 지냈었다.  
이런 단어들은 들려올 때마다 항상 나를 부끄럽게 만들었는데, 몇일 전 인터넷에서 [잘 설명된 글](https://brianbondy.com/blog/100/understanding-windows-at-a-deeper-level-sessions-window-stations-and-desktops)을 보고는 내 블로그에 한 번 옮겨 적어 봐야겠다는 생각을 했다.

영어 실력도 변변치 않고 처음 번역을 해보는 것이라 잘못된 부분도 더러 있을 것이다.  
영어로 읽는 것이 더 편하다면 원문을 찾아가는 것이 좋을 것이고, 이 글에서 잘못된 부분을 발견해서 가르쳐 준다면 감사히 고치도록 하겠다.

이 글에서 프로그래머들이 실제로 개발하는데 있어서 가장 중요한 내용은 비스타부터 변경된 세션0의 분리이다.  
만일 비스타 이상에서 윈도우 서비스를 만들 때나 커널 오브젝트와 도스 디바이스들을 다룰 때 이에 대해서 잘 모르고 있다면 수 없이 골탕을 먹게 될 것이다.  
글 말미에 있는 더 읽을 거리 중에서 [Session 0 Isolation](https://techcommunity.microsoft.com/t5/ask-the-performance-team/application-compatibility-session-0-isolation/ba-p/372361)는 이 부분에 대해 좋은 설명을 제공한다.  
[제프리리쳐의 Windows via C/C++](/essay/2008/12/19/windows-via-cpp.html)이나 [윈도우 인터널](https://www.benjaminlog.com/entry/Windows-Internals-5th-has-been-published)의 오브젝트 매니저 챕터도 반드시 읽어봐야 한다.

자 그럼 지금부터 시작.

---


이 글은 윈도우즈가 어떻게 동작하는지에 대한 몇가지 의문점들에 대한 답변이다.  
만일 윈도우 프로그래밍에 어느 정도 익숙하다면 글을 읽기가 훨씬 수월할 것이다.

만약 아래 질문들에 대해 완벽히 답변을 할 수 없다면, 이 글을 읽어봐야 한다.  

* 컴퓨터를 잠글 때 무슨 일이 일어나는가? 열려있는 프로그램들은 어찌 되는가? 작업표시줄은?
* UAC의 특별한 것은 무엇인가? UAC는 어떻게 전체 스크린을 잠그면서 어둡게 만드는가? 그리고 그것이 실제로 우리를 보호해줄 수는 있나?
* 왜 키 로거들은 잠겨있는 컴퓨터의 비밀번호를 캡쳐해내지 못하는가?
* 스크린 세이버의 특별한 점은 무엇인가? 그것들은 어떻게 동작하는가.
* 어떻게 같은 컴퓨터에서 동시에 1명 이상 로그온 할 수 있는가?
* 터미널 서비스와 원격 데스크탑은 어떻게 동작하는가.
* 왜 대부분의 원격 제어 프로그램들은 그렇게 거지같은가.
* NT 서비스 속성창에 있는 “Allow services to interact with desktop” 체크박스는 무엇일까.
* 왜 사람들에게 비스타는 꼬졌고 윈도7은 좋다고 인식되었을까.

이 모든 것들을 이해하기 위해서는 세션, 윈도우 스테이션, 그리고 데스크탑이라는 개념을 이해해야 한다.  
조금 어려울 수도 있겠지만 윈도우즈가 어떻게 동작하는지 이해하기 위해서는 배울 가치가 있을 것이다.

컴퓨터의 들어있는 프로그램들은 그것이 실행될 때 프로세스가 된다. 프로세스는 실행되고 있는 프로그램이다. 프로세스는 프로그램 코드이며 쓰레드들의 모임이다.

윈도우즈에서 프로세스는 그 프로세스를 시작시킨 사용자에게 속하며, 또한 세션에 속한다.  
세션은 프로세스들, 윈도우들, 윈도우 스테이션들, 데스크탑들 그리고 그밖의 여러 리소스들을 포함한다.  
윈도우 스테이션과 데스크탑은 뒤에서 다룰 것이다.

작업관리자에서 프로세스 탭을 클릭하면 컴퓨터의 모든 프로세스들을 볼 수 있다.  
여기서 누가 그 프로세스를 실행시킨 유저인지 또한 알 수 있으며, 프로세스가 속한 세션이 무엇인지도 알 수 있다.  
세션ID를 보여주는 것은 디폴트로 비활성화 되어 있는데, View 메뉴에서 Select Columes를 클릭하고 Session ID 옵션을 켜면 된다.

각 프로세스들은 정확히 1개 세션에 속하고 각 세션은 세션 ID를 가지고 있다. 일단 프로세스가 한번 시작되고 나면 그 프로세스의 세션을 바꿀 수 없다.  
만일 윈도우 XP나 그 이하 버전을 사용하고 있다면 작업관리자에서 적어도 1개의 세션을 확인할 수 있을 것이며, 비스타 이상 버전이라면 최소 2개의 세션을 볼 수 있다.

윈도우즈에는 많은 세션들이 있을 수 있고 그것들은 사실 일정 숫자로 제한되지만 여기서는 무한히 많은 것으로 간주하고 이야기를 진행할 것이다.

만약 비스타 이상 버전을 사용하고 있다면, 윈도우즈 서비스가 시작하는 곳은 첫번째 세션인 Session 0이다.  
두번째 세션인 Session 1은 첫번째로 로그온한 사용자의 프로그램이 시작되는 곳이다.

한 컴퓨터에서 여러 사용자를 로그온 시킨다면 지금 말한 것보다 많은 세션들이 생겨날 것이다.  
여러 사용자를 한 컴퓨터에서 로그온 시키는 방법으로는 터미널 서비스, 원격 데스크탑, 또는 사용자 전환이 있다.  
이런 추가적인 로그인 동작으로 인해 새로운 세션이 생겨나게 된다.

[CreateProcessAsUser](https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessasuserw) 함수를 사용하면 다른 세션에 프로세스를 생성할 수도 있다.  
그렇게 하기 위해서는 반드시 그 세션을 포함하는 사용자 토큰을 사용해야만 한다.  
사용자 토큰의 세션을 설정하기 위해서는 [SetTokenInformation](https://docs.microsoft.com/en-us/windows/win32/api/securitybaseapi/nf-securitybaseapi-settokeninformation?redirectedfrom=MSDN) 함수를 사용하면 된다.

지금까지의 내용을 정리하면,
* Session 0
  * Process 0.1
  * Process 0.2
  * Process 0.3
  * ...
  * Process 0.N
* Session 1
  * Process 1.1
  * Process 1.2
  * Process 1.3
  * ...
  * Process 1.N
* ...
* Session M
  * Process M.1
  * Process M.2
  * Process M.3
  * ...
  * Process M.N

## 비스타는 어떻게 세션의 동작을 변경 하였나?
윈도우 비스타 이전에는 첫번째로 로그인한 사용자는 윈도우즈 서비스들과 첫번째 세션(Session 0)을 공유했었다.  
이 세션은 또한 상호작용이 허용되었었다.

비스타부터는 사용자 세션과 서비스 세션이 완전히 분리되었다.  
게다가 세션 0은 더이상 사용자와 상호작용도 할 수 없게 되었다.

비스타의 이러한 변화는 서비스는 애플리케이션 코드로부터 안전함을 보장하기 위한 보안적인 이유로 인해 결정된 사항이다.  
그럼 왜 서비스들은 보호되어야 하는가?  
서비스들은 상승된 권한에서 수행되고 따라서 사용자 프로그램은 제어할 수 없는 것들에도 접근할 수 있다.  
뒤에 나올 “어떻게 윈도우즈의 보안을 우회하는가" 섹션 부분에서 여기에 관한 더 많은 내용을 다룬다.

![](https://t1.daumcdn.net/cfile/tistory/12277E124CD6A0873C)  
*비스타 이전 OS에서 3명의 유저가 로그온 한 경우*

![](https://t1.daumcdn.net/cfile/tistory/1250F9104CD6A09434)  
*비스타 이후부터 3명의 유저가 로그온 한 경우*

차이점은 비스타부터는 첫번째 로그온한 유저가 서비스와 별개의 독립적인 세션을 갖게 된다는 것이다.

## 윈도우 스테이션
세션은 윈도우 스테이션들과 한 개의 클립보드를 포함한다.  
각 윈도우 스테이션은 그것이 속한 세션에서 유일한 이름을 갖는다.  
이것은 한 세션에서 각 윈도우 스테이션들은 고유하다는 것을 의미한다.  
하지만 세션들 사이에서 2개의 윈도우 스테이션은 같은 이름을 가질수 있다.  
물론 그것은 구별이 가능하다.

윈도우 스테이션을 보안 장벽으로 생각하는 것도 괜찮다.  
일단 윈도우 스테이션이 생성되면 자신이 속해있는 세션을 변경할 수는 없다.

각 프로세스는 하나의 윈도우 스테이션에 속한다.  
하지만 세션과 프로세스의 관계와는 다르게 프로세스는 시작된 이후에 자신의 윈도우 스테이션을 변경할 수 있다.

다음 API들이 이런 작업을 위해 사용 가능하다.

* [GetProcessWindowStation](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getprocesswindowstation?redirectedfrom=MSDN)
* [SetProcessWindowStation](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setprocesswindowstation?redirectedfrom=MSDN)
* [CreateWindowStation](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowstationw)
* [OpenWindowStation](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-openwindowstationw)

모든 세션에는 `Winsta0`이라고 불리는 특별한 윈도우 스테이션이 있다.  
`WinSta0`은 사용자 인터페이스를 보여주고 사용자 입력을 받을 수도 있는 윈도우 스테이션이다.  
다른 윈도우 스테이션들은 GUI를 보여줄 수도 없고 사용자 입력을 받을 수도 없다.

프로세스는 [SetProcessWindowStation](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setprocesswindowstation) 함수를 통해서 자신과 연결된 윈도우 스테이션을 설정할 수 있다.  
일단 프로세스가 자신의 윈도우 스테이션을 설정하게 되면 윈도우 스테이션 안에 있는 데스크탑이나 클립보드에 접근할 수 있다.  
데스크탑에 대해서는 뒤에서 다룬다.

모든 프로세스는 부모 프로세스를 가지고 있다.  
프로세스가 시작될 때 윈도우 스테이션을 설정하는 코드를 추가하지 않는다면 부모 프로세스의 윈도우 스테이션으로 설정된다.  
또한 프로세스는 [CreateWindowStation](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createwindowstationw) 함수를 통해 새로운 윈도우 스테이션을 생성할 수도 있다.

지금까지 내용을 정리하면,

* Session 0
  * WinSta0
    * Some Processes
  * WinSta1
    * Some Processes
  * ...
  * WinStaN
    * Some Processes
* Session 1
  * WinSta0
    * Some Processes
  * WinSta1
    * Some Processes
  * ...
  * WinStaN
    * Some Processes
* ...
* Session M
  * WinSta0
    * Some Processes
  * WinSta1
    * Some Processes
  * ...
  * WinStaN
    * Some Processes

## 윈도우 데스크탑
각 윈도우 스테이션들은 데스크탑을 여러개 갖을 수 있다.  
데스크탑은 커널 공간에 로드되며 논리적인 디스플레이 표면이라 할 수 있다.  
모든 GUI 객체들은 이 곳에 할당된다.

각 윈도우 데스크탑은 세션에 속하게 되며 또한 윈도우 스테이션에게도 속한다.

각 세션에서는 오직 한 번에 하나의 데스크탑만이 활성화 될 수 있다.  
또한 그것은 반드시 `WinSta0`에 속해야 한다.  
이런 액티브 데스크탑은 입력 데스크탑이라 불린다.  
액티브 데스크탑의 핸들을 가져오기 위해서는 [OpenInputDesktop](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-openinputdesktop?redirectedfrom=MSDN) 함수를 사용하면 된다.

WinSta0은 3개의 로드된 데스트탑을 가지고 있다:
1. 로그온 데스크탑 (로그온 화면의)
2. 기본 데스크탑 (사용자 데스크탑)
3. 스크린 세이버

비스타 이후부터는 보안 데스크탑 이라고 불리는 4번째 데스크탑이 생겼는데 이것은 UAC 프롬프트에서 사용된다.  
데스크탑을 잠글 때는 기본 데스크탑에서 로그온 데스크탑으로 스위치 되는 작업이 수행된다.

다음 함수들은 데스크탑을 다루는데 사용된다.
* 쓰레드에 대한 데스크탑을 설정하기 위해 [SetThreadDesktop](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setthreaddesktop?redirectedfrom=MSDN) 함수를 사용할 수 있다.
* [CreateDesktopEx](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-createdesktopexw) 함수를 통해 새로운 데스크탑을 생성할 수 있다. 생성되는 데스크탑은 그것을 호출하는 프로세스와 연관되어 있는 윈도우 스테이션에 할당된다.

[STARTUPINFO](https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/ns-processthreadsapi-startupinfow) 구조체와 `lpDesktop` 멤버를 사용하면 프로세스를 시작할 때 프로세스가 속할 윈도우 스테이션과 데스크탑을 직접 명시할 수도 있다.  
보통 이것은 [CreateProcessAsUser](https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessasuserw)나 [CreateProcess](https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw) 같은 함수로부터 불린다.

지금까지 내용을 다시 정리하면,
* Session 0
  * Station Winsta0
    * Desktop Winlogon
      * Some Processes
    * Desktop Default
      * Some Processes
    * Desktop Screensaver
      * Some Processes
    * Desktop UAC
      * Some Processes
    * Some other Desktops
      * Some Processes
  * Station Winsta1
    * Some other Desktops
      * Some Processes
  * ...
  * Station WinstaN
    * Some other Desktops
      * Some Processes
* Session 1
  * Station Winsta0
    * Desktop Winlogon
      * Some Processes
    * Desktop Default
      * Some Processes
    * Desktop Screensaver
      * Some Processes
    * Desktop UAC
      * Some Processes
    * Some other Desktops
      * Some Processes
  * Station Winsta1
    * Some other Desktops
      * Some Processes
  * ...
  * Station WinstaN
    * Some other Desktops
      * Some Processes
* ...
* Session M
  * Station Winsta0
    * Desktop Winlogon
      * Some Processes
    * Desktop Default
      * Some Processes
    * Desktop Screensaver
      * Some Processes
    * Desktop UAC
      * Some Processes
    * Some other Desktops
      * Some Processes
  * Station Winsta1
    * Some other Desktops
      * Some Processes
  * ...
  * Station WinstaN
    * Some other Desktops
      * Some Processes

각 서비스의 속성 페이지에는 "Allow services to interact with Desktop"라는 이상한 체크박스가 있다.  
이 체크박스는 서비스가 `Winsta0`에서 수행될지 그 밖의 다른 윈도우 스테이션에서 수행될지를 결정한다.  
이 기능은 미래에도  계속 지원되는 것이 보장되지는 않는지만 현재 윈도7까지는 지원되고 있다.  
이 기능은 레지스트리를 통해서 어느 서비스에 대해서라도 적용할 수 있다.  
따라서 보안적인 문제를 야기할 수 있기 때문에 미래에는 제거될 것이라고 생각한다.

만약 체크박스가 켜져있으면 새로운 세션이과 윈도우 스테이션 `Winsta0`이 생성된다.  
만약 서비스가 GUI를 보여주려고 한다면, 앞단의 액티브 유저 세션이 디스플레이될 다른 데스크탑이 있다는 것을 통지 받게 될 것이다.

만약 체크박스가 꺼져있으면 서비스가 GUI를 그리려 하더라도 아무일도 일어나지 않는다.  
그 서비스는 Session 0에서 시작한다.  
GUI 호출은 성공하지만 결코 보여지지는 않을 것이다.

## 윈도우 핸들
윈도우즈 운영체제 안의 윈도우들은 데스크탑 객체의 자식들이다.  
윈도우는 GUI 요소이며, 윈도우 핸들(HWND)로써 구분된다.  
윈도우 핸들이 어디에 존재하는지 이해하는 것은 여러 데스크탑들 사이에서 할 수 있는 것과 못하는 것들을 알 수 있기 때문에 중요하다고 할 수 있다.

## 세션 간의 통신
어떤 방식을 사용하느냐에 따라서 세션 간에도 통신을 할 수가 있다.  
파이프, 글로벌 이벤트, 소캣들은 세션 간에도 통신 할 수 있다.  
윈도우 메세지, 로컬 이벤트들은 세션 간에 통신할 수 없다.

윈도우 비스타부터는 모든 서비스들이 Session 0에서 시작된다고 말했었다.  
이것은 GUI를 보여주는 수많은 서비스들이 더 이상 제대로 동작하지 않는 것을 의미한다.

서비스에서 GUI를 보여주기 위한 적절한 방법은 파이프 등을 사용하여 서비스와 통신하는 다른 GUI 프로그램을 하나 만드는 것이다.

다른 방법으로는 서비스에서 다른 사용자 세션의 `Winsta0`의 기본 데스크탑 위치에 GUI를 보여주는 애플리케이션을 새로 띄워버리는 것이다.

## 데스크탑 간의 통신
윈도우 메세지는 데스크탑 사이에서는 허용되지 않으며 같은 데스크탑 내에서만 유효하다.  
여기서 더 많은 것을 확인해 볼수 있다.  
["메세지를 통한 데스크탑 사이의 통신은 불가능하다."](https://docs.microsoft.com/en-us/windows/win32/winstation/desktops?redirectedfrom=MSDN)

이것은 다른 프로세스로부터 윈도우 메세지를 모니터 하거나 알림을 받는 윈도우 훅 들이 데스크탑 레벨에서만 설치될 수 있다는 것을 의미한다.

따라서 키로거는 컴퓨터가 다른 데스크탑에서 잠겼을 때 무엇을 타이핑하는지 접근할 수가 없다.

데스크탑을 열거한 이후에는 각 데스크탑안에서 윈도우들을 열거해낼 수 있다.

[EnumDesktopWindows](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdesktopwindows) 함수는 이런 데스크탑 윈도우들을 열거해보는 함수이다.  
이 함수는 데스크탑의 핸들을 인자로 받아서 그 데스크탑 내에 존재하는 윈도우들을 돌려준다.  
이것은 아까 말했던, 윈도우가 데스크탑의 자식이라는 점을 뒷받침해준다.

## 어떻게 윈도우즈의 보안을 우회하는가.
사실 윈도의 세션, 윈도우 스테이션, 데스크탑 내에서 원한다면 하고 싶은 어떤 것도 할 수 있다.  
그 방법은 로컬 시스템 계정으로 동작하는 서비스를 만드는 것이다.

이런 서비스는 메니페스트 파일을 통해서 권한 상승된채 수행될 뿐 아니라 세션내의 어느 프로세스의 토큰과 링크된 토큰을 획득할 수도 있고, 원하는 작업을 하기위한 같은 토큰 내에서 프로그램을 실행시킬 수도 있다.  
사실 이것이 작업관리자가 동작하는 방식이다.

```c++
//UAC creates 2 tokens.  The second one is the restricted token and 
//the first one is the one returned by LogonUser
//Vista and above links the elevated token to the Logonuser token though :)
TOKEN_LINKED_TOKEN tlt;
DWORD len;
if(GetTokenInformation(hToken
    , (TOKEN_INFORMATION_CLASS)TokenLinkedToken
    , &tlt, sizeof(TOKEN_LINKED_TOKEN)
    , &len))
{
    hLinkedToken = tlt.LinkedToken;
    //From here you can start elevated processes
}
```

## 정리하기
이제 이전의 질문들에 대한 대답을 할 차례이다.

### 컴퓨터를 잠글 때 무슨 일이 일어나는가? 열려있는 프로그램들은 어찌 되는가? 작업표시줄은?
컴퓨터를 잠글 때는 기본 데스크탑에서 로그온 데스크탑으로 전환된다.  
물론 이것들은 같은 `WinSta0`내에 있는 데스크탑의 이야기이다.  
두 데스크탑은 물론 당연히 같은 세션에 속한다.  
이것이 같은 컴퓨터에서 동시에 여러 사용자가 로그인 할 수 있는 원리이다.

### UAC의 특별한 것은 무엇인가? UAC는 어떻게 전체 스크린을 잠그면서 어둡게 만드는가? 그리고 그것이 실제로 우리를 보호해줄 수는 있나?
UAC 프롬프트를 만나게 되면 기본적으로 기본 데스크탑에서 보안 데스크탑으로 변경된다.  
UAC는 기본 데스크탑의 스크린 샷을 가지고 있으며, 그것을 UAC 윈도우 뒤에 어둡게 보이게 한다.  
UAC 윈도우는 보안 데스크탑에 속한다.  
사용자는 UAC 프롬프트를 보안 데스크탑에서 실행되게 할 수도 있고 현재 데스크탑(덜 안전한) 에서 실행되도록 할 수도 있다.

### 왜 키 로거들은 잠겨있는 컴퓨터의 비밀번호를 캡쳐해내지 못하는가?
내가 키로거를 작성하고 학교에서 그것을 사용했을 때의 일이다.  
나는 모든 사람들의 로그인 패스워드를 알아낼 수 있었고, 그들의 파일조차도 볼 수 있었다.  
그 이후로 멀티 세션 운영체제가 나타났다.
소프트웨어 키로거는 윈도우 메세지와 함께하는 윈도우 훅에 기반한다.  
키로거는 윈도우 메세지에 의해 모든 키보드 입력을 잡아챈다.  
키로거가 다른 데스크탑에서 실행되는 한 더 이상 패스워드를 훔칠 수 없다.  
나는 세션 너머로도 동작하는 키로거를 만드는 것이 가능하다고 생각하지만, 그런 것이 있는지는 모른다.  
이런 것을 어떻게 하는지는 "어떻게 윈도우즈의 보안을 우회하는가" 에서 설명하였다.

### 스크린 세이버의 특별한 점은 무엇인가? 그것들은 어떻게 동작하는가.
스크린 세이버에 특별한 점이란 없다.  
스크린 세이버는 GUI 요소들을 감추지도 않을 뿐더러 그 위에 무언가를 그리는 것도 아니다.  
스크린 세이버는 단순히 데스크탑을 스크린 세이버 데스크탑으로 전환한다.  
데스크탑이 바로 논리적인 그래픽 장치라는 것을 기억해야 한다.

### 어떻게 같은 컴퓨터에서 동시에 1명 이상 로그온 할 수 있는가?
간단하다.  
각 유저는 그들만의 세션을 가지고 있고 각 세션은 그 밖의 모든 것들을 가지고 있다.  
세션을 사용하는 각 유저는 그들의 데스크탑만이 보인다.  
물론 그 데스크탑은 해당 세션의 `WinSta0`에 속할 것이다.

### 터미널 서비스와 원격 데스크탑은 어떻게 동작하는가.
터미널 서비스와 원격 데스크탑은 이미 열려있는 세션에 접근권한을 주거나 새로운 세션을 생성하는 방식으로 동작한다.  
각 세션은 연결된 상태일 수도 있고 끊어진 상태일 수도 있다.

### 왜 대부분의 원격 제어 프로그램들은 그렇게 거지같은가.
몇몇 원격 제어 프로그램은(터미널 서비스와 원격 데스크탑 말고) 세션을 인지하지 못하고 오직 첫번째 세션에서만 동작한다.  
이것은 FogCreek Copilot을 포함한 대부분의 VNC 서버들에 해당된다.

만약 멀티 세션 머신을 사용하고 있다면 그런 각각의 세션들을 제어할 수 없을 것이다.

### 다른 세션들 사이에 존재하는 프로세스끼리 통신할 수가 있는가?
적절한 통신 방법을 사용한다면 가능하다.

### 다른 데스크탑 사이에 존재하는 프로그램들은 윈도우 메세지로 통신할 수 있는가?
없다.

### 왜 사람들에게 비스타는 별로고 윈도7은 좋다고 인식되었을까.
윈도우 비스타는 이러한 변화들의 첫번째 구현이었기 때문이다. 비스타는 호환성을 깨버렸다.  
많은 프로그램 개발 회사들은 세션 0의 분리와 같은 변화를 구현하기 위해 오랜 시간을 쏟았다.  
아직도 대부분의 사람들은 이것을 완벽하게 이해하고 있지는 못하다.  
이 때부터 윈도우 비스타는 꼬졌다는 불명예를 안았다. 물론 호환성을 깬 것은 비스타의 잘못이 맞다.

## 더 읽을 거리
* [Sessions, Desktops and Windows Stations](https://techcommunity.microsoft.com/t5/ask-the-performance-team/sessions-desktops-and-windows-stations/ba-p/372473)
* [How can I log users off after a period of inactivity, rather than merely locking the workstation? Is there a “logoff” screen saver?](https://devblogs.microsoft.com/oldnewthing/20190723-00/?p=102727)
* [Session 0 Isolation](https://techcommunity.microsoft.com/t5/ask-the-performance-team/application-compatibility-session-0-isolation/ba-p/372361)
* [Exploring handle security in Windows](https://docs.microsoft.com/en-us/archive/msdn-magazine/2000/march/security-briefs-exploring-handle-security-in-windows)