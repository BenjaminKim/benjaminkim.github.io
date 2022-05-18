---
layout: post
categories: programming
image: /assets/img/jeho.jpg
title: FIELD_OFFSET 매크로
date: 2011-03-01 08:00:00 +0900
---

```c++
typedef struct tagST
{
  CHAR a;
  CHAR b;
  INT* c;
  INT64 d;
  INT cbName;
  WCHAR name[1];
} ST;
```

위와 같은 구조체가 있다고 하자. 네번째 멤버 `d`의 오프셋을 어떻게 구할수 있을까?

`INT offset = sizeof(CHAR) + sizeof(CHAR) + sizeof(INT*);`

위와 같이 생각했다면 틀렸다.  
컴파일러의 구조체 멤버 정렬값에 따라서 결과가 다르게 나올 수도 있기 때문이다.

이런 구조체의 특정 멤버에 대한 오프셋을 구해주는 서비스 매크로가 바로 `FIELD_OFFSET`이다.  
`FILED_OFFSET` 매크로는 다음과 같이 생겼다.

```c++
#define FIELD_OFFSET(type, field) ((LONG)(LONG_PTR)&(((type *)0)->field))
```

0을 `type*`으로 형변환 해서 field를 참조하는 부분이 포인트인데 문법 자체에는 너무 신경쓰지 않는게 좋을 것이다.

이 매크로는 아래 처럼 사용한다.

```c++
// 첫번째 인자에 구조체 이름을 넣고 두번째 인자로 멤버 이름을 넣는다.
INT offset = FIELD_OFFSET(ST, d);
```

이 코드는 컴파일러의 정렬 크기나, 64비트 환경들에 상관없이 모두 제대로된 결과를 반환한다.

위 구조체를 다시 한번 보자. 마지막 멤버 `name[1]`이 조금 이상하게 보일 것이다.  
이는 C언어에서 구조체 내에 가변길이의 데이터 멤버를 포함시킬 때 메모리를 두 덩어리로 할당하지 않고 한 덩어리로 할당하기 위해 [흔히 쓰이는 기법](/essay/2010/12/20/하위-디렉터리의-파일이-변경-되었는지-감지하기.html)이다.  
성능상의 이점이 있기 때문에 커널 레벨 드라이버등 로우레벨로 내려갈수록 많이 쓰이지만 하이레벨 계층으로 올라오면 거의 쓰이지 않는다. 사용하기 불편하기 때문이다.  
이런 구조체에는 2가지 법칙이 있는데 첫번째는 언제나 그 가변 길이 멤버가 맨 아래에 위치하고 있다는 것이며 2번째는 그 가변길이 변수의 크기를 나타내는 추가적인 변수가 꼭 존재한다는 것이다.  
여기서는 `cbName`이다.

이제 이 `name`이라는 변수에 L"some string"이라는 문자열을 복사해보려고 한다.  
이 구조체에 메모리를 어떻게 할당하고 값을 채워넣어야 할까.

```c++
typedef struct tagST
{
    CHAR a;
    CHAR b;
    INT* c;
    INT64 d;
    INT cbName;
    WCHAR name[1]; // 널 종료 문자열이 아니다
} ST;

int _tmain(int argc, _TCHAR* argv[])
{
    CONST WCHAR* psz = L"some string";
    INT cch = wcslen(psz);
    INT cb = cch * sizeof(WCHAR);

    // 첫번째 방법
    {     
        // 구조체 전체의 크기에 가변 문자열의 크기를 더해서 메모리를 할당한다.
        // 구조체에 name[1]이 이미 포함되어 있으므로 WCHAR 1개 만큼을 다시 빼주어야 한다.
        ST* p = (ST*)malloc(sizeof(ST) + cb - sizeof(WCHAR)));
        memcpy(p->name, psz, cb);
        p->cbName = cb;    
    }
    // 두번째 방법  
    {       
        // 처음부터 name의 오프셋까지만 얻어낸 뒤 cb를 더해주면 조금 더 간단하다.
        // 첫번째 방법처럼 중복된 WCHAR 만큼을 다시 빼줄 필요가 없다.
        ST* p = (ST*)malloc(FIELD_OFFSET(ST, name) + cb);
        memcpy(p->name, psz, cb);
        p->cbName = cb;
    }
    // 세번째 방법
    {
        // FIELD_OFFSET에 항상 멤버의 이름만 쓸수 있는 것은 아니다.
        // 아래처럼 배열의 인덱스에 변수를 명시하는 것도 가능하다.
        // 이 때 cb가 아니라 cch를 넣고 있는 것에 유의해야 한다.
        ST* p = (ST*)malloc(FIELD_OFFSET(ST, name[cch]));
        memcpy(p->name, psz, cb);
        p->cbName = cb;
    }
    
    return 0;
}
```

`FIELD_OFFSET`을 모르고 있으면 첫번째 방법으로 힘들게 코딩하는 수 밖에 없다.  
이 방식은 실수하기가 쉽다.

`FIELD_OFFSET`은 또한 `CONTAINING_RECORD` 매크로를 만들기 위해서도 쓰인다.
`CONTAINING_RECORD`는 재미있고 중요한 매크로이지만 [다른 블로그](http://www.pyrasis.com/blog/entry/PracticalContainingRecordMacro)에 이미 설명이 되어 있기 때문에 따로 쓰지 않겠다.

`FIELD_OFFSET`의 ANSI C 버전은 `offsetof`이며 `stddef.h`에 정의되어 있다.  
`CONTAINING_RECORD`는 `container_of`와 같다.
리눅스를 다루는 사람들은 `offsetof` 매크로를 많이 사용하는 것 같지만 나는 윈도 매크로가 더 익숙해서, 코드를 다른 플랫폼으로 이식할 필요가 없다면 `offsetof` 보다 `FIELD_OFFSET`을 사용하는 것을 더 선호한다.  
양쪽의 구현은 똑같다.
<br>
<br>
*비슷한 글:*
* [_countof 매크로](/essay/2011/03/15/_countof-매크로.html)
* [PAGED_CODE 매크로](/essay/2011/02/27/PAGED_CODE-매크로.html)