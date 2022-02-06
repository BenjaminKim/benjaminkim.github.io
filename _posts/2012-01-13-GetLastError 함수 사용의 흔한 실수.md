---
layout: post
categories: essay
image: /assets/img/jeho.jpg
title: GetLastError 함수 사용의 흔한 실수
---

[GetLastError](https://docs.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-getlasterror)는 윈도 Api를 호출 한 뒤 해당 함수의 Win32 에러 코드를 받아오기 위한 함수이다.  
이 오류 정보는 쓰레드별로 하나만 저장되기 때문에 함수가 실패한 후 다른 함수를 실행하기 전에 에러 값을 읽어와야 한다.  
다른 함수들이 호출된 이후에는 에러 값이 덮어 씌워져 버릴 수 있다.

보통은 아래와 같이 사용한다.

```c++
HANDLE h = CreateFile(...);
if (h == INVALID_HANDLE_VALUE)
{
  DWORD dw = GetLastError();
  // ... Do something
}
```

경험이 많지 않거나 주의 깊지 않은 프로그래머들은 프로그램을 유지보수 하면서 이미 잘 만들어져있던 위와 같은 코드를 별 생각 없이 아래처럼 바꾸기도 한다.
```c++
HANDLE h = CreateFile(...);
if (h == INVALID_HANDLE_VALUE)
{
  // 뭔가 예외를 처리하기 위해 추가적인 코드를 여기에 쑤셔넣는다. 아니, 왜 하필 여기에.
  // 이 코드 때문에 GetLastError() 값이 망가져 버릴 수 있다.
  DoSomethingElse();
  DWORD dw = GetLastError();
  // ... Do something
}
```

`DoSomethingElse`안에서 윈도 Api를 사용한다면 쓰레드 저장소에 있던 LastError 가 다른 값으로 바뀔 수 있다.  
코드를 읽으면서 GetLastError를 호출하는 부분이 에러값을 확인하려고 했던 함수의 바로 아래에 붙어있지 않다면 섬뜩함을 느껴야 한다.  
하지만 잘 모르고 있으면 보이지 않는 법.

이번에는 다른 종류의 실수이다.

```c++
HANDLE h = CreateXXX(...);
DWORD dw = GetLastError();
if (dw == ERROR_SUCCESS)
{
  // ... 핸들을 가지고 다른 무엇인가를 한다.
}
else
{
  // ... 함수의 실패처리를 한다.
}
```

이번에는 한 Api를 호출 한 뒤에 바로 GetLastError를 호출해서 에러값을 얻어왔다.  
얼핏보면 맞는 것 같지만 역시 틀린 코드이다.

함수의 성공 실패 여부는 함수의 스펙에 따라 리턴 값 등으로 확인해야지 GetLastError 값으로 확인해서는 안된다.  
왜냐하면 Win32에서 제공되는 대부분의 Api들이 함수가 성공했을 때는 LastError 값을 건드리지 않기 때문이다.  

위 코드는 함수가 성공할 때는 에러 값도 0(ERROR_SUCCESS)으로 셋팅시켜 줄 것이라 믿고 있다.  
그렇지 않다. GetLastError는 함수가 실패했을 때만 호출해야 한다. (아래서 말하겠지만 예외도 있다)

대부분의 함수들은 그 성공 여부를 리턴값으로 가르쳐준다.  
리턴 값으로 성공과 실패 여부를 호출자에게 전달해주기로 했다면 뭐하러 또 SetLastError(ERROR_SUCCESS) 와 같은 추가적인 코드를 호출하겠는가.  
하지만 어떤 함수들은 굳이 SetLastError(ERROR_SUCCESS)를 호출해주기도 하는데, 이것에 대한 이야기는 [다음 포스트](/essay/2012/01/16/SetFilePointer-보다는-SetFilePointerEx를-사용해야-한다.html)에서 해보려고 한다.