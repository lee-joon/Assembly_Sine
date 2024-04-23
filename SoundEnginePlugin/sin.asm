.data
align 16									; 데이터를 16바이트 경계에 정렬
values dd 1.0, 2.0, 3.0, 4.0				; 실제 부동 소수점 수치들을 메모리에 초기화
one dd 1.0, 1.0, 1.0, 1.0 
Ione dd 1, 1, 1, 1
Sone dd 1.0
scale dd 1024.0

.code
;rcx	: lookuptable /1024(2^10)
;rdx	: 저장할 공간
;r8		: bufferSize
;r9		: nowpoint
;xmm0	: Hz * 1 / sampleRate


Sin_func PROC

    push rbp								; 기존 베이스 포인터 저장
    mov rbp, rsp							; 스택 포인터를 베이스 포인터에 복사
    sub rsp, 36								; 로컬 변수 및 임시 공간을 위해 스택 공간 확보

    ; 레지스터 보존
	push rbx
    push rcx								; 첫 번째 인자인 rcx 보존
    push rdx								; 두 번째 인자인 rdx 보존
    push r8									; 세 번째 인자인 r8 보존
    push r9									; 네 번째 인자인 r9 보존

	mov rbx, rcx
	movaps xmm1, xmm0
	movd xmm2, r9d							; xmm1 번레지스터로 이동
	cvtdq2ps xmm2, xmm2						; 정수 데이터를 소수로 변환
	mulss xmm1, xmm2

_start:
	
	mov ecx, 0								; 반복 카운터를 0으로 초기화

loop_start:
	addss xmm1, xmm0
	movss xmm3, xmm1
	movss xmm4, dword ptr [scale]
	mulss xmm3, xmm4
	cvttss2si eax, xmm3						; EAX에 정수 부분 저장
	cvtsi2ss xmm2, eax						; xmm2에 정수 부분의 부동 소수점 형태 저장
	subss xmm3, xmm2						; 소수 부분만 추출

    and eax, 1023							; EAX를 오른쪽으로 10비트 산술 시프트

	mov	r9d, dword ptr [rbx + rax * 4]		; rbx에 있는 값을 rax를 색인으로 사용하여 접근
	mov dword ptr [rbp - 16], r9d			; 스택에 저장
	movd dword ptr [rbp - 32], xmm3			; xmm값을 스택에 저장
	
	inc eax									; eax을 1증가후
	mov	r9d, dword ptr [rbx + rax * 4]		; 다시 색인 값으로 사용하여
	mov dword ptr [rbp - 12], r9d			; 스택에 저장

	movss xmm4, dword ptr [Sone]			; 1 - 가중치를 위한 세팅
	subss xmm4, xmm3
	movd dword ptr [rbp - 28], xmm4

	; 한번더 반복
	addss xmm1, xmm0
	movss xmm3, xmm1
	movss xmm4, dword ptr [scale]
	mulss xmm3, xmm4
	cvttss2si eax, xmm3						; EAX에 정수 부분 저장
	cvtsi2ss xmm2, eax						; xmm2에 정수 부분의 부동 소수점 형태 저장
	subss xmm3, xmm2						; 소수 부분만 추출

    and eax, 1023							; EAX를 오른쪽으로 10비트 산술 시프트

	mov	r9d, dword ptr [rbx + rax * 4]
	mov dword ptr [rbp - 8], r9d
	movd dword ptr [rbp - 24], xmm3
	
	inc eax
	mov	r9d, dword ptr [rbx + rax * 4]
	mov dword ptr [rbp - 4], r9d

	movss xmm4, dword ptr [Sone]
	subss xmm4, xmm3
	movd dword ptr [rbp - 20], xmm4

	movups xmm2, [rbp - 16]
	movups xmm3, [rbp - 32]

	;
	;
	;

	mulps xmm2, xmm3
	haddps xmm2, xmm2

	mov rax, rcx
	imul rax, 4
	add rax, rdx

	movsd qword ptr [rax], xmm2

    inc ecx
	inc ecx
	cmp ecx, r8d
    jne loop_start

	; 레지스터 복원
    pop r9									; 네 번째 인자인 r9 복원
    pop r8									; 세 번째 인자인 r8 복원
    pop rdx									; 두 번째 인자인 rdx 복원
    pop rcx									; 첫 번째 인자인 rcx 복원
	pop rbx

    ; 스택 포인터와 베이스 포인터 복구
    mov rsp, rbp							; 스택 포인터를 베이스 포인터로 설정
    pop rbp									; 이전 베이스 포인터 복원

    ret										; 호출자로 제어 반환


Sin_func ENDP

END