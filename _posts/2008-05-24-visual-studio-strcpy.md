---
layout: post
categories: programming
image: /assets/img/vs2005.png
title: Visual C++ 문자열 함수 잘 사용하기
date: 2008-05-24 14:45:00 +0900
---

아래 코드는 에러 없이 컴파일 되지만, 경고가 발생한다.  
심지어 s2의 버퍼가 s1 보다 크더라도 잘 컴파일 된다.

```c++
void f()
{
    CHAR s1[10];
    CHAR s2[10];

    strcpy( s1, s2 );
}
// warning C4996: 'strcpy': This function or variable may be unsafe. 
// Consider using strcpy_s instead. 
// To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details.
```

경고 메시지에서 [strcpy_s](https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/strcpy-s-wcscpy-s-mbscpy-s?view=msvc-170)를 사용하라고 친절히 알려주고 있다.  
Visual Studio 2005부터는 `strcpy` 같은 보안상 취약성을 가진 문자열 함수들은 모두 경고 처리 된다.

학창 시절 Visual Studio 2005가 처음 나와서 써볼 때 `strcpy`함수가 갑자기 줄줄이 경고가 발생해 당황스러웠던 기억이 난다.  
어떤 친구들은 이 경고 때문에 VS2005는 쓰지 말아야 한다면서 VS2003을 사용했는데 지금 생각하니 재밌다.

많은 웹문서에서 올바르게 코드를 작성하는 방법이 아니라 `_CRT_SECURE_NO_WARNINGS` 옵션을 사용하여 경고 메세지를 숨기는 방법에 대해 설명한다.  
나 역시 한동안 그렇게 사용했었는데 그것은 오히려 경고인 채로 내버려 두는 것보다 더 나쁘다는 것을 [존 로빈스의 책](/programming/2008/04/06/debugging-applications-for-windows.html)을 통해서 배웠다.

경고 레벨은 항상 최대로 올린채 경고를 숨긴 곳을 찾아 모두 지워야 한다.  
그리고는 하나씩 경고를 없애 나간다.  
엄청나게 많던 경고 메세지가 점점 줄어들면서 깔끔하게 컴파일되는 모습을 보는 것은 꽤 즐거운 일이다. 나만 그런가?

그럼 `strcpy_s` 함수는 어떻게 사용하는 것일까?
조금 귀찮지만 버퍼의 크기를 함수에게 알려줘야 한다.

```c++
void f()
{
    TCHAR s1[10];
    TCHAR s2[10];

    _tcscpy_s( s1, _countof( s1 ), s2 );
}
```

이러면 경고 없이 깨끗하게 컴파일 된다.

2번째 인자로는 s1 배열 요소의 갯수를 넣어주었다.  
`strcpy_s` 함수 같은 경우 2번째 인자의 변수 이름이 `_SizeInBytes` 라서 `sizeof` 연산자를 사용하여 코드를 작성하면 될 것 같지만,  
유니코드용 함수인 `wcscpy_s` 같은 경우에는 변수 이름이 `SizeInWord`로 되어있다.  
즉, 배열의 사이즈가 아니라 배열의 요소의 갯수(문자의 갯수)를 전달해주어야 한다.  
이렇게 하면 ANSI나 유니코드 프로젝트에서 모두 잘 동작한다.

위 코드에서는 VC2005부터 제공되는 [_countof 매크로](/essay/2011/03/15/_countof-%EB%A7%A4%ED%81%AC%EB%A1%9C.html)를 통해서 배열의 요소 갯수를 구해주었다.

만일 매크로가 없는 환경이라면 단순히

```c++
#define _countof(_Array) (sizeof(_Array) / sizeof(_Array[0]))
```

이렇게 만들어 주면 된다.

바이트수(cb)와 문자의 갯수(cch)는 언제나 우리를 햇갈리게 하며 조심스럽게 접근해야 하는 부분이다.  
변수 이름 앞에 `cb`나 `cch`가 붙어있다면 눈을 크게 뜬채 한번 더 생각해보고 코딩하는 것이 좋다.

Target( 여기선 s1 )이 컴파일 타임에 크기를 잡아둔 정적 배열일 경우에는 2번째 인자를 생략해도 상관없다.  
하지만 동적으로 크기를 지정한 배열일 경우에는 컴파일러가 알 수 없으므로 인자를 생략할 수 없다.

이제 다음 함수를 보자.

```c++
void copy( WCHAR* pResultString )
{
    WCHAR str[MAX] = { 0 };
   
    // some work   

    _wcscpy( pResultString, str );
}
```

위 함수는 어떤 작업을 한 후에 그 결과 문자열을 `pResultString`에 저장해주는 기능을 한다.
역시 `strcpy` 를 사용했기 때문에 C4996 경고.

하지만 이런 함수들은 secure function으로 수정할 수도 없다.
호출하는 쪽에서 문자열 버퍼의 크기를 얼마로 잡았는지 알 수가 없기 때문이다.
따라서 2번째 인자를 넣어줄 수가 없다.

이런 경우에는 이런식으로 메소드 시그내쳐를 수정해야만 한다.

```c++
void copy( WCHAR* pResultString, size_t iMaxBuffer )
{
    WCHAR str[MAX] = { 0 };
    
    // some work    

    _wcscpy_s( pResultString, iMaxBuffer, str );
}
```

그런데 C++을 사용한다면 뭐하러 저런 방식을 쓰나.
나는 다음과 같은 방법을 더 선호한다.

```c++
void copy(std::wstring& strResult)
{
    WCHAR str[MAX] = { 0 };
   
    // some work   

    sResult = str;
}
```
<br>
<br>

*비슷한 글:*
* [TR1을 이용한 C++에서의 정규식 사용](/programming/2009/06/30/tr1-regex.html)
* [비주얼 스튜디오에서 pragma message 로 실수 방지 하기](/programming/2010/01/13/pragma-message.html)
* [C++ STL을 익히기 위해 좋은 책](/essay/2008/03/15/stl.html)