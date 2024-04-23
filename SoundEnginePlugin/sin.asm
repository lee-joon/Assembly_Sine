.data
align 16									; �����͸� 16����Ʈ ��迡 ����
values dd 1.0, 2.0, 3.0, 4.0				; ���� �ε� �Ҽ��� ��ġ���� �޸𸮿� �ʱ�ȭ
one dd 1.0, 1.0, 1.0, 1.0 
Ione dd 1, 1, 1, 1
Sone dd 1.0
scale dd 1024.0

.code
;rcx	: lookuptable /1024(2^10)
;rdx	: ������ ����
;r8		: bufferSize
;r9		: nowpoint
;xmm0	: Hz * 1 / sampleRate


Sin_func PROC

    push rbp								; ���� ���̽� ������ ����
    mov rbp, rsp							; ���� �����͸� ���̽� �����Ϳ� ����
    sub rsp, 36								; ���� ���� �� �ӽ� ������ ���� ���� ���� Ȯ��

    ; �������� ����
	push rbx
    push rcx								; ù ��° ������ rcx ����
    push rdx								; �� ��° ������ rdx ����
    push r8									; �� ��° ������ r8 ����
    push r9									; �� ��° ������ r9 ����

	mov rbx, rcx
	movaps xmm1, xmm0
	movd xmm2, r9d							; xmm1 ���������ͷ� �̵�
	cvtdq2ps xmm2, xmm2						; ���� �����͸� �Ҽ��� ��ȯ
	mulss xmm1, xmm2

_start:
	
	mov ecx, 0								; �ݺ� ī���͸� 0���� �ʱ�ȭ

loop_start:
	addss xmm1, xmm0
	movss xmm3, xmm1
	movss xmm4, dword ptr [scale]
	mulss xmm3, xmm4
	cvttss2si eax, xmm3						; EAX�� ���� �κ� ����
	cvtsi2ss xmm2, eax						; xmm2�� ���� �κ��� �ε� �Ҽ��� ���� ����
	subss xmm3, xmm2						; �Ҽ� �κи� ����

    and eax, 1023							; EAX�� ���������� 10��Ʈ ��� ����Ʈ

	mov	r9d, dword ptr [rbx + rax * 4]		; rbx�� �ִ� ���� rax�� �������� ����Ͽ� ����
	mov dword ptr [rbp - 16], r9d			; ���ÿ� ����
	movd dword ptr [rbp - 32], xmm3			; xmm���� ���ÿ� ����
	
	inc eax									; eax�� 1������
	mov	r9d, dword ptr [rbx + rax * 4]		; �ٽ� ���� ������ ����Ͽ�
	mov dword ptr [rbp - 12], r9d			; ���ÿ� ����

	movss xmm4, dword ptr [Sone]			; 1 - ����ġ�� ���� ����
	subss xmm4, xmm3
	movd dword ptr [rbp - 28], xmm4

	; �ѹ��� �ݺ�
	addss xmm1, xmm0
	movss xmm3, xmm1
	movss xmm4, dword ptr [scale]
	mulss xmm3, xmm4
	cvttss2si eax, xmm3						; EAX�� ���� �κ� ����
	cvtsi2ss xmm2, eax						; xmm2�� ���� �κ��� �ε� �Ҽ��� ���� ����
	subss xmm3, xmm2						; �Ҽ� �κи� ����

    and eax, 1023							; EAX�� ���������� 10��Ʈ ��� ����Ʈ

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

	; �������� ����
    pop r9									; �� ��° ������ r9 ����
    pop r8									; �� ��° ������ r8 ����
    pop rdx									; �� ��° ������ rdx ����
    pop rcx									; ù ��° ������ rcx ����
	pop rbx

    ; ���� �����Ϳ� ���̽� ������ ����
    mov rsp, rbp							; ���� �����͸� ���̽� �����ͷ� ����
    pop rbp									; ���� ���̽� ������ ����

    ret										; ȣ���ڷ� ���� ��ȯ


Sin_func ENDP

END