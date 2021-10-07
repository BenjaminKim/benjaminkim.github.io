---
layout: post
categories: essay
image: /assets/img/jeho.jpg
title: SetFilePointer 보다는 SetFilePointerEx를 사용해야 한다.
---
파일을 열 때 파일 포인터는 0으로 셋팅된다.  
이후 해당 파일에 [ReadFile](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-readfile)이나 [WriteFile](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-writefile)등의 함수를 통해서 I/O를 하게 되면 파일 포인터가 자동으로 증가하게 된다.    
물론 Windows는 사용자가 직접 오프셋을 조정할 수 있는 인터페이스도 제공해주는데 [SetFilePointer](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-setfilepointer) 가 바로 그런 함수이다.  
파일 포인터는 각 핸들별로 따로 관리된다. 즉 같은 파일이라 할지라도 2번을 열어서 핸들을 2개 가지고 있다면 각 핸들에 연결된 파일 포인터는 각각 독립적으로 움직인다.

이 `SetFilePointer`는 너무 복잡하게 만들어진 함수이다. 그래서 제대로 사용하기가 어렵다.  
지금까지 `SetFilePointer` 함수를 사용하는 곳 중 제대로 작성된 코드를 본 적이 없는 것 같다.  
그렇다면 어떤 부분이 그렇게 `SetFilePointer`의 사용을 힘들게 만드는 것일까?

`SetFilePointer` 함수는 다음과 같이 생겼다.  
그 옛날 시절에도 64비트 지원을 고려해서 위해 2번째 인수와 3번째 인수를 통해 각 4바이트씩 총 64비트 만큼의 오프셋 정보를 전달할 수 있도록 만들어졌다.

```c++
DWORD WINAPI SetFilePointer(
  __in         HANDLE hFile,
  __in         LONG lDistanceToMove,
  __inout_opt  PLONG lpDistanceToMoveHigh,
  __in         DWORD dwMoveMethod
);
```

**첫번째**로 많이 하는 실수는 오프셋이 32비트 크기를 넘어갈 수 있는 경우에도 항상 `lpDistanceToMoveHigh` 에 NULL을 넣고 있는 경우이다.  
4기가보다 큰 파일에 대해서 제대로 지원하지 못하는 경우인데 오래 전에 작성된 코드에서 흔히 볼 수 있다.

**두번째.** `SetFilePointer`의 리턴값은 변경된 오프셋 값이며 함수가 실패할 경우에는 `INVALID_SET_FILE_POINTER` 를 돌려주게 된다.  
`INVALID_SET_FILE_POINTER`의 값은 -1로 정의되어 있고, 이 값은 DWORD로 받아지기 때문에 0xFFFFFFFF가 된다.  
그런데 만약 내가 변경하고 싶었던 위치가 0xFFFFFFFF(4기가) 였다면? 사용자는 0xFFFFFFFF위치로 오프셋을 옮겨줄 것을 요청했고 함수는 사용자가 원한 동작을 제대로 수행한 뒤 0xFFFFFFFF를 리턴했다.  
이제 이 값이 에러인지 정상적인 오프셋 값인지 어떻게 구분해야할까?  

사용자는 이를 확인해보기 위해서 반드시 [GetLastError](https://docs.microsoft.com/en-us/windows/win32/api/errhandlingapi/nf-errhandlingapi-getlasterror)를 호출해야 한다.  
만일 함수가 성공했고 제대로된 오프셋이라면 LastError가 `ERROR_SUCCESS`로 셋팅되어 있을 것이다.  

[지난 번에 윈도의 LastError값은 오직 함수가 실패할 때만 셋팅된다고 했었는데](/essay/2012/01/13/GetLastError-%ED%95%A8%EC%88%98-%EC%82%AC%EC%9A%A9%EC%9D%98-%ED%9D%94%ED%95%9C-%EC%8B%A4%EC%88%98.html), `SetFilePointer`와 같은 몇몇 특별한 함수에서는 성공시에도 값을 0으로 만들어 준다.  
리턴값만으로는 모든 정보를 전달해줄 수가 없기 때문이다.

따라서 `SetFilePointer`를 사용하는 곳에서는 다음 표에 있는 것처럼 리턴값을 확인해야 한다.

| | 	If lpDistanceToMoveHigh == NULL | If lpDistanceToMoveHigh != NULL |
| --- | --- | --- |
| If success | retVal != INVALID_SET_FILE_POINTER | retVal != INVALID_SET_FILE_POINTER \|\|  GetLastError() == ERROR_SUCCESS |
|If failed	| retVal == INVALID_SET_FILE_POINTER | retVal == INVALID_SET_FILE_POINTER && GetLastError() != ERROR_SUCCESS |

아니, 진짜 이걸 이렇게 다 코딩하는 사람이 있다고?  
사람들이 틀리게 사용할 만도 하다.

이제 하고 싶었던 말을 정리하면,
* `SetFilePointer` 함수를 사용한 곳을 보게 되면 위 내용을 유심히 살펴보는 것도 재미있다. 그리고 코드가 틀렸다면 바르게 고치자.
* 위 표에 나온대로 고치려면 어렵다. 걍 [SetFilePointerEx](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-setfilepointerex) 쓰면 된다.
* [GetFileSize](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfilesize) 함수도 역시 비슷한 문제가 있다. [GetFileSizeEx](https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfilesizeex)만 사용해라