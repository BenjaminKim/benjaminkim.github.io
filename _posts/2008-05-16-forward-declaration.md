---
layout: post
categories: programming
image: /assets/img/vs2005.png
title: 전방선언과 컴파일 의존성
date: 2008-05-16 18:09:00 +0900
---

이렇게 정의된 클래스가 있다.

```c++
//S.h
class S
{
public:
	S();

private:
	AModule a;
	BModule b;
	CModule c;
}; // 컴파일이 되지 않는다.
```

클래스 `S`의 인스턴스는 `AModule`과 `BModule`, `CModule`의 상세 내용까지 알고 있어야 생성될 수 있다.  
따라서 각 모듈들에 대한 클래스 정의가 필요하다.

`#include` 지시어를 사용해 정의를 포함할 수 있다.

```c++
//S.h
#include "AModule.h" //모듈들의 정의를 끌어온다.
#include "BModule.h"
#include "CModule.h"

class S
{
public:
	S();

private:
	AModule a;
	BModule b;
	CModule c;
}; //이제는 컴파일이 가능하다.
```

하지만 `AModule`이나 `BModule` 혹은 `CModule`이 변경 될때에 `S` 클래스를 사용하는 다른 모든 파일들이 같이 컴파일 된다.  
이 정도의 작은 코드라면 상관없지만 커다란 프로젝트에서는 코드 몇 줄 고치고 컴파일 되는 동안 오랜 시간을 기다려야 할지도 모른다.

이제 이렇게 정의된 클래스를 보자.

```c++
// 전방 선언
class AModule;
class BModule;
class CModule;

class S
{  
public:
	S();

private:
	AModule* a;
	BModule* b;
	CModule* c;
};
```

멤버 변수가 포인터나 레퍼런스일 경우에는 인스턴스를 담을 주소 공간만이 필요하다.  
따라서 클래스 정의를 끌어오지 않아도 괜찮다.  
단 `S`가 알아볼 수는 있어야 하므로 각 모듈에 대한 선언만은 필요하다.  
그래서 전방선언이 되어 있다.

이렇게 되면 모듈들의 인스턴스를 만들기 위해 `S`의 **구현 파일(cpp)**에서 각 모듈들의 정의를 끌어오면 된다.

구현 파일에서 include 했기 때문에 A, B, C 모듈의 정의가 바뀌더라도 `S` 클래스를 사용하는 클라이언트 코드들은 컴파일되지 않아도 된다.

포인터와 레퍼런스로 충분한 경우에는 굳이 객체를 직접 사용하지 않도록 하여 컴파일 의존성을 줄이고 모듈간의 독립성을 높일 수 있다.