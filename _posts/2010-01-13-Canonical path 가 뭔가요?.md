---
layout: post
categories: essay
image: /assets/img/DSCN0049.jpg
date: 2010-01-13 19:18:00 +0900
---

Java API에 있는 `File` 클래스의 메소드를 보다가 `getAbsolutePath`와 `getCanonicalPath`를 보고는 이상하다 생각했다. 
결과가 항상 같은 절대경로로 나왔던 것이다.  
하지만 `Canonical`과 `Absolute` 는 분명한 차이점이 있다.

문자열을 통해서 어떤 객체를 표현 한다고 해보자.  
`5`라는 정수는 "5", "000005", "+5", "5.0", "0.5e+01" 등으로 표현할 수 있다.  
이 중 Canonical한 표현은 딱 하나다. 여기서는 "5" 이다.  

`/home/originfile`
이런 파일이 있다고 생각해보자. 현재 디렉토리가 /home 이라고 할 때 이 파일의 상대경로는 무수히 많다.

* `./originfile`
* `../home/originfile`
* `././././originfile` 등등

절대경로는 `/home/originfile`이 될 것이다.  
그런데 절대경로가 `/home/originfile` 1개만 존재할까? 그렇지만도 않다.  
`/home/../home/originfile`  
`/home/./././originfile`  
등도 모두 적법한 절대 경로이다.

이 뿐만 아니다.  
`/home/originfile`을 가리키는 `/home/symlink` 라는 파일을 하나 생성했다고 하자.  
`/home/symlink`도 역시 이 파일 객체에 대한 절대 경로가 된다.  
따라서 절대 경로 역시 상대 경로와 마찬가지로 무수히 많은 경우의 수를 가질 수 있다.

이들과는 다르게 Canonical Path는 어떤 파일의 경로를 나타내기 위한 유일한 심볼이다.  
절대 경로가 어떻든지 상관없이 이 파일에 대한 Canonical path는 항상 `/home/originfile` 이며 이것은 유일하다.  

아래에 이해를 돕는 간단한 코드가 있다.
```java
System.setProperty("user.dir", "/home");
File f = new File("/home/originfile");
System.out.println("Abs path : " + f.getAbsolutePath());
System.out.println("Can path : " + f.getCanonicalPath());
f = new File("/home/symlink");
System.out.println("Abs path : " + f.getAbsolutePath());
System.out.println("Can path : " + f.getCanonicalPath());
f = new File("./././originfile");
System.out.println("Abs path : " + f.getAbsolutePath());
System.out.println("Can path : " + f.getCanonicalPath());
```

```text
Abs path : /home/originfile
Can path : /home/originfile
Abs path : /home/symlink
Can path : /home/originfile
Abs path : /home/./././originfile
Can path : /home/originfile
```

이제 Canonical Path와 Absolute Path가 어떤 차이가 있는지 이해할 수 있을 것이다.  
이것은 Java에서 프로그래밍 할 때만 나오는 것이 아니라 일반적인 개념이기 때문에 알아두면 유용하다.

윈도우 비스타 부터는 [mklink](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/mklink)라는 명령이 추가되었는데 심볼릭 링크와 하드링크를 만들 수 있다.  
심볼릭 링크를 만들어서 테스트해보면 윈도우즈에서도 아마도 위와 같은 결과가 나올 것이다.

윈도우즈 프로그래밍을 하다보면 MSDN을 읽게 될 때 `fully-qualified path`라는 용어를 자주 볼 수 있다.
어떤 함수는 인자로서 꼭 `fully-qualified path`를 요구한다.  
`fully-qualified path`는 그냥 절대 경로를 뜻하는 것이 아니라 canonical path와 비슷하다.

MSDN에는 `fully-qualified path`가 [2개의 역슬래시로 시작하거나, 드라이브 레터와 역슬래시로 시작해야 한다고](https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file?redirectedfrom=MSDN#fully-qualified-vs-relative-paths) 말하고 있다.
예를 들면 다음과 같다.

```powershell
\\server\share\directory\file.txt
C:\directory\file.txt
```

그렇지만 다음은 fully-qualified path가 아니다.
```powershell
C:\directory\..\directory\file.txt
```