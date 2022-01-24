---
layout: post
categories: programming
image: https://t1.daumcdn.net/cfile/tistory/143B83374F863E110A
title: 쉘의 파일 오퍼레이션을 잡아챌 수 있는 ICopyHook 인터페이스
date: 2012-04-06 14:55:00 +0900
---
[ICopyHook](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/legacy/bb776049(v=vs.85)?redirectedfrom=MSDN)은 윈도에서 제공하는 COM 인터페이스이다.  
이 인터페이스를 구현해서 시스템에 등록시키면 쉘을 통한 파일 오퍼레이션이 발생할 때 내가 설치해 놓은 코드가 실행되도록 할 수 있다.

구현해야 할 함수는 이런 모양으로 생겼다.

```c++
UINT CopyCallback(
  [in, optional] HWND hwnd,
  UINT wFunc,
  UINT wFlags,
  [in] PCTSTR pszSrcFile,
  DWORD dwSrcAttribs,
  [in, optional] LPCTSTR pszDestFile,
  DWORD dwDestAttribs
);
```

파일 오퍼레이션을 잡아챌 수 있다고 해서 이 훅을 사용해 파일 삭제 등을 감시하는 모니터 용도로 사용하려는 아이디어는 좋지 못하다.  
이 기능은 모든 파일 시스템 오퍼레이션에 훅을 제공하는 것이 아니라 폴더 삭제와 같은 특정한 몇몇 동작에 대해서만 동작하기 때문이다.  
어떤 파일 오퍼레이션이 발생하는가 궁금한 거라면 [파일 시스템에서 제공하는 파일 변경 알림 기능](https://jeho.page/essay/2010/12/20/%ED%95%98%EC%9C%84-%EB%94%94%EB%A0%89%ED%84%B0%EB%A6%AC%EC%9D%98-%ED%8C%8C%EC%9D%BC%EC%9D%B4-%EB%B3%80%EA%B2%BD-%EB%90%98%EC%97%88%EB%8A%94%EC%A7%80-%EA%B0%90%EC%A7%80%ED%95%98%EA%B8%B0.html)을 사용하는 것이 올바른 방법이다.

그럼 이 인터페이스는 도대체 어디에 쓰라고 만든 물건인가.

윈도우 탐색기에서 폴더를 삭제하게 되면 탐색기는 폴더 안에 있는 **파일들부터** 모두 지우고 마지막에 폴더를 삭제한다.  
이는 NTFS 같은 파일 시스템이 폴더 안에 파일이 있으면 삭제하지 못하도록 하고 있기 때문이다.  
[RemoveDirectory](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-removedirectoryw) 함수를 호출했을 때 해당 디렉터리 내에 파일이 존재한다면 파일 시스템 드라이버는 `STATUS_DIRECTORY_IS_NOT_EMPTY` 에러를 돌려주도록 구현해야 한다.

윈도 탐색기의 이런 동작은 네트워크 파일 시스템 위에서는 치명적이다.  
로컬 파일 시스템이라면 `Irp`가 몇 백번쯤 왔다갔다해도 금새 끝나겠지만 레이턴시가 긴 네트워크 파일 시스템은 저 멀리 미국까지 수 백번을 왔다 갔다 해야 할 수도 있는 것이다.

`ICopyHook` 을 사용하면 이런 폴더 삭제나 이동 명령들을 먼저 잡아채서 내 마음대로 원하는 동작을 수행 한 뒤 `ID_NO`를 리턴함으로서 쉘에게는 더 이상 오퍼레이션을 하지 않도록 할 수 있다.

예를 들어 네트워크 파일 시스템 드라이버를 만든다면 쉘에서 폴더 삭제 같은 오퍼레이션이 발생할 때 이를 잡아채서 서버로 폴더 삭제 명령을 딱 한번만 보낼 수 있는 것이다.    
물론 서버는 하위에 파일들이 있더라도 폴더를 삭제할 수 있는 기능을 지원해야 한다.  

주의 해야 할 점은 내 훅이 실행될 때 어떤 에러가 발생하면 에러메세지를 사용자에게 보여주는 것도 내 책임이 된다는 것이다.  
`ID_NO`를 리턴하면 쉘은 해당 오퍼레이션에 대해서 더 이상 신경쓰지 않는다.    
함수의 첫 번째 인자로 들어오는 `HWND`는 바로 그런 사용자 인터랙션을 위해서 존재한다.

`ICopyHook`을 구현하면서 실수로 버그를 만든다면 사용자는 윈도 탐색기 프로세스가 자꾸 비정상 종료되는 경우를 겪을 수 있다.  
이는 사용자뿐 아니라 개발자들에게도 귀신이 곡할 노릇일 수 있다.  
어떤 머신에서는 잘 동작하는데 특정 컴퓨터에만 가면 내 응용 프로그램이 파일 오퍼레이션을 할 때마다 윈도 탐색기가 죽어버리니 말이다.  
경험이 어느 정도 있는 개발자라면 먼저 윈도 탐색기에 `ICopyHook`이나 쉘 확장 플러그인이 설치되어 있는지를 먼저 살펴보겠지만, 잘 모르고 있다면 크래시 덤프를 눈으로 보면서도 원인을 모를 수 있다.

[FOFX_NOCOPYHOOKS 플래그를 사용하면 훅을 완전히 무시하고](https://devblogs.microsoft.com/oldnewthing/20120330-00/?p=7963) 오퍼레이션을 수행할 수도 있다.