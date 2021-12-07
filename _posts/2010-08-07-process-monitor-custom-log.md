---
layout: post
categories: essay
image: https://t1.daumcdn.net/cfile/tistory/13513D304C5C3BB16C
title: Process Monitor에 커스텀 로그를 쓰기
date: 2010-08-07 00:57:00 +0900
---
`Sysinternals`가 만든 여러 유용한 툴 중 [Process Monitor](/essay/2011/01/14/%ED%94%84%EB%A1%9C%EC%84%B8%EC%8A%A4-%EB%AA%A8%EB%8B%88%ED%84%B0-%EC%82%AC%EC%9A%A9%EB%B2%95.html)는 내가 가장 좋아하는 툴이다.  
`Process Monitor`는 잘 사용하려면 UI도 익숙해져야 하지만 Windows API를 많이 알고 있어야 하기 때문에 개발자가 아닌 QA팀 같은 곳에서는 사용하기 힘들다.  
하지만 프로세스가 수행하는 모든 동작들을 잡아채서 보여주기 때문에 어떤 응용프로그램을 분석할 때 유용한 많은 정보들을 얻어 낼 수 있다.

[DbgView](https://docs.microsoft.com/en-us/sysinternals/downloads/debugview)는 개발자들이 디버깅 할 때 많이 사용하는 애플리케이션 중 하나다.  
응용프로그램이나 디바이스 드라이버에서는 [OutputDebugString](https://docs.microsoft.com/en-us/windows/win32/api/debugapi/nf-debugapi-outputdebugstringw)이나 [DbgPrint](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/wdm/nf-wdm-dbgprint) 같은 함수로 로그를 작성한 후 `DbgView`를 통해서 프로그램의 상태를 추적하고는 한다.

파일 시스템 필터드라이버를 만들게 되면 이 두가지를 같이 병행하고 싶은 경우들이 생길 수 있다.  
1. 응용프로그램들이 어떤 Irp를 보내는지, 
2. 내 필터 드라이버는 이에 따라 어떤 동작을 하는지를 함께 보고 싶은 것이다.

두가지 툴을 번갈아 쳐다보며 로그를 확인 하기는 어렵다. 순서가 뒤죽박죽이기 때문에.  
이번에 프로세스 모니터에서 이런 기능을 해결하기 위한 인터페이스가 하나 추가되었다.

이 아이디어는 [디버깅 애플리케이션](https://www.benjaminlog.com/entry/Debugging-Applications)의 저자인 존 로빈스가 제안했는데, 현재 MS 최고의 프로그래머 중 하나인 마크 루시노비치를 자신의 개인 프로그래머라고 농담하는 것이 재밌다.

> What I really wanted was for my trace statements to be part of the Process Monitor viewing so that way it would be trivial mapping the I/O activity to operations in my code.  
> Fortunately, I have a personal developer at my disposal that is keen to tackle these kinds of challenges.  
> He’s a very nice guy named Mark Russinovich who happens to be the author of Process Monitor.  
> Mark is always eager to hear feature requests for his tools and I think he’s implemented at least 30 features in Sysinternals tools over the years that I thought would be great to have.  
> Don’t hesitate to email Mark with feature ideas so he can be your personal developer as well.

여담이지만 존 로빈스의 유머 감각은 정말 끝내준다.  
그의 디버깅 애플리케이션만큼 즐거운 컴퓨터 책을 아직도 만나보지 못했다.  
이런 멋진 해커이자 명저자가 다시는 책을 안쓰기로 결정한 것은 정말 슬픈 일이다.

어쨌거나 마크는 선뜻 제안을 받아들였고 콘트롤 코드를 하나 추가해서 [DeviceIoControl](https://docs.microsoft.com/en-us/windows/win32/api/ioapiset/nf-ioapiset-deviceiocontrol) 함수를 통해 인터페이스 할 수 있도록 해주었다.  
최신버전의 프로세스 모니터를 보면 도움말에서 아래 코드를 찾아볼 수 있다.

```c++
#define FILE_DEVICE_PROCMON_LOG 0x00009535
#define IOCTL_EXTERNAL_LOG_DEBUGOUT (ULONG) CTL_CODE( FILE_DEVICE_PROCMON_LOG, 0x81, METHOD_BUFFERED, FILE_WRITE_ACCESS )
 
int main( int argc, char * argv[] )
{
  HANDLE hDevice = CreateFile( L"\\\\.\\Global\\ProcmonDebugLogger", 
                       GENERIC_READ|GENERIC_WRITE,
                       FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_SHARE_DELETE,
                       NULL,
                       OPEN_EXISTING,
                       FILE_ATTRIBUTE_NORMAL,
                       NULL );
 
  if ( hDevice != INVALID_HANDLE_VALUE ) {
    WCHAR text[] = L"Debug out";
    DWORD textlen = (_wcslen(text)+1) *sizeof(WCHAR)
    DWORD nb = 0;
 
    BOOL ok = DeviceIoControl( hDevice,
               IOCTL_EXTERNAL_LOG_DEBUGOUT, text, textlen, NULL, 0, &nb, NULL );
 
    if ( ok ) {
      printf( "wrote %d\n", i );
    } else {
      printf( "error 0x%x\n", GetLastError() );
    }
  } else {
    printf( "error %d opening Process Monitor\n", GetLastError() );
  }
  return 0;
}
```

존 로빈스는 [.NET과 C/C++에서 좀 더 편하게 사용할 수 있는 Wrapper 코드](https://github.com/Wintellect/ProcMonDebugOutput)를 만들어서 올려놓았다.
커널 드라이버에서 사용하고 싶다면 [ZwDeviceIoControlFile](https://docs.microsoft.com/en-us/windows-hardware/drivers/ddi/ntifs/nf-ntifs-zwdeviceiocontrolfile) 함수를 통해서 직접 Wrapper를 작성해야 한다.  
존도 이제는 늙어서 커널 코드는 만들어주기가 귀찮은가보다.

![](https://t1.daumcdn.net/cfile/tistory/13513D304C5C3BB16C)

이런 식으로 애플리케이션이나 드라이버에서 프로세스 모니터에게 직접 디버그 메세지를 보낼수가 있다.  
프로세스 모니터가 이벤트와 로깅의 순서를 동기화 해주는 것은 보너스이다.

관련글: [프로세스 모니터 사용법](/essay/2011/01/14/%ED%94%84%EB%A1%9C%EC%84%B8%EC%8A%A4-%EB%AA%A8%EB%8B%88%ED%84%B0-%EC%82%AC%EC%9A%A9%EB%B2%95.html)