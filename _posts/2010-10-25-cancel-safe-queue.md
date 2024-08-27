---
layout: post
categories: essay
image: /assets/img/vs2005.png
title: Cancel-Safe Queue를 이용하여 디바이스 드라이버에서 I/O를 취소하기
date: 2010-10-25 00:36:00 +0900
---

유저모드에서는 [CancelIo](https://docs.microsoft.com/en-us/windows/win32/fileio/cancelio) 함수를 통해서 해당 장치에 들어간 모든 I/O를 취소할 수 있고 [CancelIoEx](https://docs.microsoft.com/en-us/windows/win32/fileio/cancelioex-func) 함수를 통해서 특정 비동기 I/O만을 취소할 수도 있다.  
(비스타 이후부터는 [CancelSynchronousIo](https://docs.microsoft.com/en-us/windows/win32/fileio/cancelsynchronousio-func) 함수를 통해 `CreateFile` 같은 동기 함수도 취소할 수가 있다.)  

비동기가 지원이 되지 않는 함수들은 `CreateFile` 처럼 금방 수행되는 함수들인데, 이런 함수들을 과연 취소할 필요가 있는가 생각이 들수도 있다.  
하지만 네트워크 리디렉터(윈도우의 공유 폴더)를 이용하여 원격지에 있는 파일에 접근할 경우 네트워크가 지연될 때 응용 프로그램에 꽤 오랜 블록킹이 발생할 수가 있다.  
이런 함수를 잘 알고 이용하면 조금 더 응답성이 좋은 애플리케이션을 만들 수 있다.

사실 유저모드에서야 `CancelIo`를 부를 필요도 없이 애플리케이션을 꺼버리거나 I/O를 하는 장치의 핸들을 닫아버리면 알아서 취소가 되기 때문에 I/O의 취소에 대해서 그다지 고민할 일이 없지만 디바이스 드라이버에서는 조금 다르다.  
(대부분의 응용프로그래머들은 `CancelIo`같은 함수에 관심을 갖지 않는다)

디바이스 드라이버가 I/O의 취소를 제대로 구현해주지 않으면, 애플리케이션이 종료될 때에 Irp가 취소되지 못하고 드라이버에게 계속 잡혀있어서 애플리케이션이 제대로 종료되지 않은 채 계속 좀비로 남아있다거나, 운영체제가 셧다운되지도 않는 몹시 나쁜 상황을 맞이할 수 있기 때문에 I/O 취소의 올바른 구현은 필수적이다.  
이런 경우를 조금이라도 방지하기 위해서 윈도우즈는 5분이 지나면 해당 Irp의 데이터구조는 삭제하지 않은채 취소를 시켜준다.  
이것은 엄밀히 말하면 I/O의 취소라고는 할 수 없다.

그럼 디바이스 드라이버에서는 I/O를 어떻게 취소하는가.  
디바이스 드라이버에게 I/O의 취소라는 것은 단순히 `STATUS_CANCELLED` 상태로 Irp를 완료시키는 것이다.  
Irp에는 취소 루틴의 포인터가 담겨있는데, 우리가 이곳에 취소 로직을 적절히 구현하여 넣어주면 애플리케이션이 I/O의 취소를 요청할 때 I/O 매니저가 이 취소루틴을 호출 해주고 Irp는 취소로 완료될 수 있다.  
하지만 드라이버는 취소루틴에서 `STATUS_SUCCESS`로 완료시켜버릴 수도 있고, `STATUS_CANCELLED`로 리턴하더라도 그 바로 직전 I/O가 정말로 완료되었을 수도 있기 때문에 유저모드에서 `CancelIo` 등을 사용해서 I/O가 완전히 끝났는지 잘 취소되었는지를 검사하는 것은 사실 별로 의미가 없다.  
그냥 취소 했다는 것에만 의미를 두면 된다.

취소 루틴에 대해 간단하게 이야기 했지만, 취소루틴을 구현한다는 것은 생전 만나보지 못한 어려운 경쟁 상태를 해결해야 하기 때문에 많은 어려움이 따른다.  
이런 어려움을 해소해주기 위해 마이크로소프트에서는 언제부턴가 [Cancel-Safe Queue](https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/cancel-safe-irp-queues?redirectedfrom=MSDN) 라이브러리를 제공해주고 있다.

나는 다행히도 꽤 편한 세상에서 태어났고 디바이스 드라이버의 세상에 입문한지 얼마 되지 않았기 때문에, Cancel-Safe Queue를 사용하지 않고 직접 취소를 구현하는 드라이버는 구현해보지 않았다.  
진심으로 다행이라 생각한다.

`Cancel-Safe Queue`를 이용하면 이런 골치 아픈 동기화 처리를 직접하지 않아도 된다.  
우리는 라이브러리 루틴 내에서 제공하는 몇 가지 콜백함수들만 적절히 구현해주면 되는데, Csq 라이브러리가 자신들의 취소루틴을 붙였다 떼었다 하면서 우리의 콜백 루틴들을 동기화까지 포함해서 적절히 호출해주기 때문에 우리는 취소루틴을 제공할 필요도 없다. 대단하지 않은가. 이런 방식의 라이브러리를 제공한다는 것은 보통 일이 아니다.

앞으로 점점 많이 사용될 WDF에서는 우리가 취소에 관해 알아야 할 것들이 더욱 줄어들기 때문에 이런 처리가 더욱 쉬워지는데, 아직 WDF를 공부해보지 않아서 어떻게 동작하는 것인지는 모르겠다.

`Cancel-Safe Queue`의 예제 코드는 WDK 샘플 코드의 /src/general/cancel 위치에 있다.

Csq를 사용하기 위해 우리가 구현해줘야 할 콜백함수들은 다음과 같다.

* XxxCsqInsertIrp
* XxxCsqRemoveIrp
* XxxCsqPeekNextIrp
* XxxCsqAcquireLock
* XxxCsqReleaseLock
* XxxCsqCompleteCanceledIrp

이름에서 볼 수 있듯이 자료구조에 Irp를 넣고 찾고 빼고 잠그는 루틴들을 우리가 구현해주면 되는 것이다.  
즉, 자료 구조와 동기화 방식을 우리가 결정할 수 있다. 자료구조는 보통은 링크드 리스트를 이용하며, 어떤 커널모드 동기화 방식을 써서 구현해도 상관없지만 성능을 위해 보통 스핀락을 사용한다.  
Csq를 쓰면 전역 캔슬 락을 사용해서 구현한 기존의 드라이버들 보다 성능에도 이점이 있다.

각 콜백 함수 구현에 대한 코드는 샘플 코드에서도 찾아볼 수 있지만, [이 문서](https://docs.microsoft.com/en-us/previous-versions/windows/hardware/design/dn653289(v=vs.85)?redirectedfrom=MSDN)에는 설명까지 덧붙여 잘 나와있으므로 한 번쯤 읽어보는 것이 좋겠다.  
보통의 경우에는 샘플 코드를 복사해서 쓰는 것으로 충분할 것이므로 여기에 따로 코드를 적지는 않는다.

이 루틴들을 다 구현했으면 `IoCsqInitialize` 함수로 적절한 곳에서 초기화를 하며 콜백 함수들을 등록시켜준 뒤에, Irp가 들어올 때 `IoCsqInsertIrp`함수를 통해 큐에 집어넣고 나서 I/O 작업을 한다.  
작업이 끝나면 `IoCsqRemoveIrp`함수를 통해 큐에서 빼고 잘 제거된지 확인 한 후에 여느 때처럼 `IoCompleteRequest` 함수로 Irp를 완료시켜주면 된다.  
도중에 애플리케이션들로부터 취소가 요청되면 Csq가 적절히 우리가 작성한 취소 로직들을 이용하여 취소를 수행 해줄 것이다.

위의 설명에서 몇 가지 추가 설명을 해야 할 것들이 있는데, 콜백함수는 우리가 직접 부르는 것이 아니다.  
우리 코드에서는 `IoCsqInsertIrp`처럼 `IoCsqXxx` 루틴들을 사용 한다.  
이 루틴들이 내부에서 우리의 콜백함수를 적절한 곳에서 호출해줄 것이다.

초기화 할 때 `IoCsqInitialize`가 아니라 `IoCsqInitializeEx`함수를 이용하면 `IoCsqInsertIrpEx` 함수를 통해 추가적인 컨텍스트를 담을 수 있다.  
이런 추가적인 컨텍스트는 우리가 Queue를 사용하는데 있어서 더 많은 유연함을 가능하게 한다.

Csq를 사용할 때는 Csq에 관련된 데이터구조가 `Irp->Tail.Overlay.DriverContext[3]` 에 보관된다.  
그러므로 Csq를 사용할 때는 이름이 `DriverContext`라고 해서 이 곳에 함부로 아무 데이터나 담아서는 안되겠다.

참고로 유저모드 파일시스템 드라이버 프레임워크인 [Dokan](/essay/2010/10/17/%EC%9C%A0%EC%A0%80%EB%AA%A8%EB%93%9C%EC%97%90%EC%84%9C-%ED%8C%8C%EC%9D%BC%EC%8B%9C%EC%8A%A4%ED%85%9C-%EB%93%9C%EB%9D%BC%EC%9D%B4%EB%B2%84%EB%A5%BC-%EB%A7%8C%EB%93%A4%EA%B8%B0.html)에서는 Csq를 사용하지 않고 직접 취소루틴을 구현했는데, DriverContext[2]와 [3]에 추가적인 데이터를 담아 사용하고 있다.

위에서 작업이 끝나면 `IoCsqRemoveIrp` 함수를 통해 큐에서 빼고 잘 제거되었는지 확인하라고 했는데, 이는 그 사이에 취소가 들어왔을 경우 큐에서 이미 빠져버렸을 수 있기 때문이다. 만일 NULL이 리턴되었다면 도중에 취소 요청이 들어와 큐에서 이미 빠진 것이다.  
그 Irp는 곧 `XxxCsqCompleteCanceledIrp` 루틴에 의해 완료되게 될 것이고 이 Irp를 우리가 또 완료시켜서는 안된다.

마지막으로 `IRP_MJ_CLEANUP` 디스패치 루틴에서는 내 디바이스의 핸들이 닫히는 경우에 큐에 Pending되어 있는 Irp들을 모두 완료 시켜주어야 한다.

<br>
*함께 읽으면 좋은 글:*
* [파일 시스템 테스트 도구](https://github.com/BenjaminKim/FileSystemTest)
