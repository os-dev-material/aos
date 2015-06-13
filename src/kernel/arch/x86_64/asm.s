/*_
 * Copyright (c) 2013 Scyphus Solutions Co. Ltd.
 * Copyright (c) 2014 Hirochika Asai
 * All rights reserved.
 *
 * Authors:
 *      Hirochika Asai  <asai@jar.jp>
 */

	.set	APIC_BASE,0xfee00000
	.set	APIC_EOI,0x0b0
	.set	APIC_LDR,0x0d0		/* Logical Destination Register */
	.set	APIC_DFR,0x0e0		/* Destination Format Register */
	.set	APIC_SIVR,0x0f0		/* Spurious Interrupt Vector Register */
	.set	APIC_LVT_TMR,0x320
	.set	APIC_LVT_PERF,0x340
	.set	APIC_INITTMR,0x380
	.set	APIC_CURTMR,0x390
	.set	APIC_TMRDIV,0x3e0
	.set	PIT_HZ,1193180

	.set    SYSCALL_MAX_NR,0x10

	.set	P_DATA_SIZE,0x10000
	.set	P_DATA_BASE,0x1000000
	.set	IDT_NR,256
	.set	P_TSS_OFFSET,(0x20 + IDT_NR * 8)
	.set	P_TSS_SIZE,104
	.set	P_CUR_TASK_OFFSET,(P_TSS_OFFSET + P_TSS_SIZE)
	.set	P_NEXT_TASK_OFFSET,(P_CUR_TASK_OFFSET + 8)
	.set	STACKFRAME_SIZE,164
	.set	TASK_RP,0
	.set	TASK_SP0,8
	.set	TASK_KTASK,32
	.set	TSS_SP0,4
	.set	GDT_RING0_CODE_SEL,0x08
	.set	GDT_RING0_DATA_SEL,0x10
	.set	GDT_RING1_CODE_SEL,0x19
	.set	GDT_RING1_DATA_SEL,0x21
	.set	GDT_RING2_CODE_SEL,0x2a
	.set	GDT_RING2_DATA_SEL,0x31
	.set	GDT_RING3_CODE_SEL,0x3b
	.set	GDT_RING3_DATA_SEL,0x43


	.file	"asm.s"

	.text
	.globl	kstart64		/* Entry point */
	.globl	apstart64		/* Application processor */
	.globl	_hlt1
	.globl	_pause
	.globl	_disable_interrupts
	.globl	_enable_interrupts
	.globl	_bswap16
	.globl	_bswap32
	.globl	_bswap64
	.globl	_movsb
	.globl	_set_cr3
	.globl	_rdtsc
	.globl	_inb
	.globl	_inw
	.globl	_inl
	.globl	_outb
	.globl	_outw
	.globl	_outl
	.globl	_sfence
	.globl	_lfence
	.globl	_mfence
	.globl	_rdmsr
	.globl	_lidt
	.globl	_lgdt
	.globl	_lldt
	.globl	_ltr
	.globl	_is_invariant_tsc
	.globl	_get_cpu_family
	.globl	_get_cpu_model
	.globl	_this_cpu
	.globl	_intr_null
	.globl	_intr_gpf
	.globl	_intr_pf
	.globl	_intr_apic_int32
	.globl	_intr_apic_int33
	.globl	_intr_apic_int34
	.globl	_intr_apic_int35
	.globl	_intr_apic_int36
	.globl	_intr_apic_int37
	.globl	_intr_apic_int38
	.globl	_intr_apic_int39
	.globl	_intr_apic_int40
	.globl	_intr_apic_int41
	.globl	_intr_apic_int42
	.globl	_intr_apic_int43
	.globl	_intr_apic_int44
	.globl	_intr_apic_int45
	.globl	_intr_apic_int46
	.globl	_intr_apic_int47
	.globl	_intr_apic_int48
	.globl	_intr_apic_int49
	.globl	_intr_apic_int50
	.globl	_intr_apic_int51
	.globl	_intr_apic_int52
	.globl	_intr_apic_int53
	.globl	_intr_apic_int54
	.globl	_intr_apic_int55
	.globl	_intr_apic_int56
	.globl	_intr_apic_int57
	.globl	_intr_apic_int58
	.globl	_intr_apic_int59
	.globl	_intr_apic_int60
	.globl	_intr_apic_int61
	.globl	_intr_apic_int62
	.globl	_intr_apic_int63
	.globl	_intr_apic_int64
	.globl	_intr_apic_loc_tmr
	.globl	_intr_apic_ipi
	.globl	_intr_crash
	.globl	_intr_apic_spurious
	.globl	_task_restart
	.globl	_asm_popcnt
	.globl	_asm_ioapic_map_intr
	.globl	_asm_lapic_read
	.globl	_asm_lapic_write
	.globl	_halt
	.globl	_idle

	.globl	_syscall_setup
	.globl	_syscall

	.globl	_sem_up
	.globl	_sem_down

	.globl	_kmemcmp
	.globl	_kmemcpy
	.globl	_kmemset

	.code64

/*
 * Kernel main function
 */
kstart64:
	call	_kmain
	jmp	_idle

apstart64:
	call	_apmain
	jmp	_idle

_halt:
	cli
	hlt
	jmp	_halt

_crash:
	cli
	hlt
	jmp	_crash

/* Idle process */
_idle:
	hlt
	jmp	_idle

_hlt1:
	hlt
	ret

/* void disable_interrupts(void) */
_disable_interrupts:
	cli
	ret

/* void enable_interrupts(void) */
_enable_interrupts:
	sti
	ret

/* void pause(void); */
_pause:
	pause
	ret

/* int inb(int port); */
_inb:
	movw	%di,%dx
	xorq	%rax,%rax
	inb	%dx,%al
	ret

/* int inw(int port); */
_inw:
	movw	%di,%dx
	xorq	%rax,%rax
	inw	%dx,%ax
	ret

/* int inl(int port); */
_inl:
	movw	%di,%dx
	xorq	%rax,%rax
	inl	%dx,%eax
	ret

/* void outb(int port, int value); */
_outb:
	movw	%di,%dx
	movw	%si,%ax
	outb	%al,%dx
	ret

/* void outw(int port, int value); */
_outw:
	movw	%di,%dx
	movw	%si,%ax
	outw	%ax,%dx
	ret

/* void outl(int port, int value); */
_outl:
	movw	%di,%dx
	movl	%esi,%eax
	outl	%eax,%dx
	ret

_sfence:
	sfence
	ret
_lfence:
	lfence
	ret
_mfence:
	mfence
	ret

_lidt:
	lidt	(%rdi)
	ret

/* void lgdt(void *gdtr, u64 selector) */
_lgdt:
	lgdt	(%rdi)
	/* Reload GDT */
	pushq	%rsi
	pushq	$1f
	lretq
1:
	ret

_lldt:
	movw	%di,%ax
	lldt	%ax
	ret

_ltr:
	//movw	$0x48,%ax
	movw	%di,%ax
	ltr	%ax
	ret

/* void asm_ioapic_map_intr(u64 val, u64 tbldst, u64 ioapic_base); */
_asm_ioapic_map_intr:
	/* Copy arguments */
	movq	%rdi,%rax	/* src */
	movq	%rsi,%rcx	/* tbldst */
	/* rdx = ioapic_base */

	/* *(u32 *)(ioapic_base + 0x00) = tbldst * 2 + 0x10 */
	shlq	$1,%rcx		/* tbldst * 2 */
	addq	$0x10,%rcx	/* tbldst * 2 + 0x10 */
	sfence
	movl	%ecx,0x00(%rdx)	/* IOREGSEL (0x00) */
	/* *(u32 *)(ioapic_base + 0x10) = (u32)src */
	sfence
	movl	%eax,0x10(%rdx)	/* IOWIN (0x10) */
	shrq	$32,%rax
	/* *(u32 *)(ioapic_base + 0x00) = tbldst * 2 + 0x10 + 1 */
	addq	$1,%rcx		/* tbldst * 2 + 0x10 + 1 */
	sfence
	movl	%ecx,0x00(%rdx)
	/* *(u32 *)(ioapic_base + 0x10) = (u32)(src >> 32) */
	sfence
	movl	%eax,0x10(%rdx)

	ret


/* u16 bswap16(u16) */
_bswap16:
	movw	%di,%ax
	xchg	%al,%ah
	ret

/* u32 bswap32(u32) */
_bswap32:
	movl	%edi,%eax
	bswapl	%eax
	ret

/* u64 bswap64(u64) */
_bswap64:
	movq	%rdi,%rax
	bswapq	%rax
	ret

/* void movsb(void *, const void *, u64 n) */
_movsb:
	movq	%rdx,%rcx
	rep movsb
	ret

/* void set_cr3(u64); */
_set_cr3:
	movq	%rdi,%cr3
	ret

/* u64 rdtsc(void); */
_rdtsc:
	rdtscp
	shlq	$32,%rdx
	addq	%rdx,%rax
	ret

/* u64 rdmsr(u64); */
_rdmsr:
	pushq	%rbp
	movq	%rsp,%rbp
	movq	%rdi,%rcx
	movq	$1f,%rbx		/* Set reentry point */
	movq	%rbx,(gpf_reentry)
	rdmsr
	xorq	%rbx,%rbx
	movq	%rbx,(gpf_reentry)
	shlq	$32,%rdx
	addq	%rdx,%rax
	popq	%rbp
	ret
1:	xorq	%rax,%rax
	movq	%rax,(gpf_reentry)
	popq	%rbp
	ret

/* int is_invariant_tsc(void); */
_is_invariant_tsc:
	movl	$0x80000007,%eax
	cpuid
	btl	$8,%edx		/* Invariant TSC */
	jnc	1f
	movq	$1,%rax
	ret
1:	/* Invariant TSC is not supported */
	movq	$0,%rax
	ret

/* int get_cpu_family(void); */
_get_cpu_family:
	movl	$0x1,%eax
	cpuid
	movq	%rax,%rbx
	shrq	$8,%rax
	andq	$0xf,%rax
	shrq	$20,%rbx
	andq	$0x3f0,%rbx
	addq	%rbx,%rax
	ret

/* int get_cpu_model(void); */
_get_cpu_model:
	movl	$0x1,%eax
	cpuid
	movq	%rax,%rbx
	shrq	$4,%rax
	andq	$0xf,%rax
	shrq	$12,%rbx
	andq	$0xf0,%rbx
	addq	%rbx,%rax
	ret

/* int this_cpu(void); */
_this_cpu:
	/* Obtain APIC ID */
	movl	$APIC_BASE,%edx
	movl	0x20(%edx),%eax
	shrl	$24,%eax
	ret

checktsc:
	movl	$0x1,%eax
	cpuid
	btl	$4,%edx		/* TSC */
	//jnc	error
	movl	$0x80000001,%eax
	cpuid
	btl	$27,%edx	/* rdtscp */
	//jnc	error
	movl	$0x80000007,%eax
	cpuid
	btl	$8,%edx		/* Invariant TSC */
	//jnc	error
	//rdtscp
	ret

/* Null function for interrupt handler */
_intr_null:
	pushq	%rdx
	movq	%rsp,%dr0
	/* APIC EOI */
	movq	$APIC_BASE,%rdx
	//addq	$APIC_EOI,%rdx
	movq	$0,APIC_EOI(%rdx)
	popq	%rdx
	iretq


/* Interrupt handler for general protection fault */
_intr_gpf:
	pushq	%rbp
	movq	%rsp,%rbp
	pushq	%rbx
	movq	(gpf_reentry),%rbx
	cmpq	$0,%rbx
	jz	1f
	movq	%rbx,16(%rbp)	/* Overwrite the reentry point (%rip) */
1:	popq	%rbx
	popq	%rbp
	addq	$0x8,%rsp
	iretq

/* Interrupt handler for page fault */
_intr_pf:
	pushq	%rbp
	movq	%rsp,%rbp
	//movq	%rsp,%dr0
	popq	%rbp
	addq	$0x8,%rsp
	iretq


/* Beginning of interrupt handler */
	.macro	intr_lapic_isr vec
	pushq	%rax
	pushq	%rbx
	pushq	%rcx
	pushq	%rdx
	pushq	%r8
	pushq	%r9
	pushq	%r10
	pushq	%r11
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15
	pushq	%rsi
	pushq	%rdi
	pushq	%rbp
	pushw	%fs
	pushw	%gs

	movq	$\vec,%rdi
	call	_kintr_isr

	/* EOI for APIC */
	movq	$0x1b,%rcx
	rdmsr
	shlq	$32,%rdx
	addq	%rax,%rdx
	/* APIC_BASE */
	andq	$0xfffffffffffff000,%rdx
	movl	0x20(%rdx),%eax		/*APIC_ID*/

	movl	0xb0(%rdx),%eax
	xorl	%eax,%eax
	movl	%eax,0xb0(%rdx)
	.endm

	.macro	intr_lapic_isr_done
	/* Pop all registers from stackframe */
	popw	%gs
	popw	%fs
	popq	%rbp
	popq	%rdi
	popq	%rsi
	popq	%r15
	popq	%r14
	popq	%r13
	popq	%r12
	popq	%r11
	popq	%r10
	popq	%r9
	popq	%r8
	popq	%rdx
	popq	%rcx
	popq	%rbx
	popq	%rax
	.endm

_intr_apic_int32:
	intr_lapic_isr 32
	intr_lapic_isr_done
	iretq

_intr_apic_int33:
	intr_lapic_isr 33
	intr_lapic_isr_done
	iretq

_intr_apic_int34:
	intr_lapic_isr 34
	//jmp	_task_restart
	intr_lapic_isr_done
	iretq

_intr_apic_int35:
	intr_lapic_isr 35
	intr_lapic_isr_done
	iretq

_intr_apic_int36:
	intr_lapic_isr 36
	intr_lapic_isr_done
	iretq

_intr_apic_int37:
	intr_lapic_isr 37
	intr_lapic_isr_done
	iretq

_intr_apic_int38:
	intr_lapic_isr 38
	intr_lapic_isr_done
	iretq

_intr_apic_int39:
	intr_lapic_isr 39
	intr_lapic_isr_done
	iretq

_intr_apic_int40:
	intr_lapic_isr 40
	intr_lapic_isr_done
	iretq

_intr_apic_int41:
	intr_lapic_isr 41
	intr_lapic_isr_done
	iretq

_intr_apic_int42:
	intr_lapic_isr 42
	intr_lapic_isr_done
	iretq

_intr_apic_int43:
	intr_lapic_isr 43
	intr_lapic_isr_done
	iretq

_intr_apic_int44:
	intr_lapic_isr 44
	intr_lapic_isr_done
	iretq

_intr_apic_int45:
	intr_lapic_isr 45
	intr_lapic_isr_done
	iretq

_intr_apic_int46:
	intr_lapic_isr 46
	intr_lapic_isr_done
	iretq

_intr_apic_int47:
	intr_lapic_isr 47
	intr_lapic_isr_done
	iretq

_intr_apic_int48:
	intr_lapic_isr 48
	intr_lapic_isr_done
	iretq

_intr_apic_int49:
	intr_lapic_isr 49
	intr_lapic_isr_done
	iretq

_intr_apic_int50:
	intr_lapic_isr 50
	intr_lapic_isr_done
	iretq

_intr_apic_int51:
	intr_lapic_isr 51
	intr_lapic_isr_done
	iretq

_intr_apic_int52:
	intr_lapic_isr 52
	intr_lapic_isr_done
	iretq

_intr_apic_int53:
	intr_lapic_isr 53
	intr_lapic_isr_done
	iretq

_intr_apic_int54:
	intr_lapic_isr 54
	intr_lapic_isr_done
	iretq

_intr_apic_int55:
	intr_lapic_isr 55
	intr_lapic_isr_done
	iretq

_intr_apic_int56:
	intr_lapic_isr 56
	intr_lapic_isr_done
	iretq

_intr_apic_int57:
	intr_lapic_isr 57
	intr_lapic_isr_done
	iretq

_intr_apic_int58:
	intr_lapic_isr 58
	intr_lapic_isr_done
	iretq

_intr_apic_int59:
	intr_lapic_isr 59
	intr_lapic_isr_done
	iretq

_intr_apic_int60:
	intr_lapic_isr 60
	intr_lapic_isr_done
	iretq

_intr_apic_int61:
	intr_lapic_isr 61
	intr_lapic_isr_done
	iretq

_intr_apic_int62:
	intr_lapic_isr 62
	intr_lapic_isr_done
	iretq

_intr_apic_int63:
	intr_lapic_isr 63
	intr_lapic_isr_done
	iretq

_intr_apic_int64:
	intr_lapic_isr 64
	jmp	_task_restart
	intr_lapic_isr_done
	iretq

_intr_apic_loc_tmr:
	intr_lapic_isr 0x50
	jmp	_task_restart
	intr_lapic_isr_done
	iretq

_intr_apic_ipi:
	intr_lapic_isr 0x51
	jmp	_task_restart
	intr_lapic_isr_done
	iretq

_intr_crash:
	jmp	_halt

/* Spurious interrupt does not require EOI */
_intr_apic_spurious:
	iretq


_task_restart:
	/* Obtain current CPU ID */
	call	_this_cpu
	movq	%rax,%rcx
	/* Calculate the base address */
	movq	%rcx,%rax
	movq	$P_DATA_SIZE,%rbx
	mulq	%rbx	/* [rdx:rax] <= rax * rbx */
	addq	$P_DATA_BASE,%rax
	movq	%rax,%rbp
	/* If the next task is not scheduled, immediately restart this */
	cmpq	$0,P_NEXT_TASK_OFFSET(%rbp)
	jz	1f
	cmpq	$0,P_CUR_TASK_OFFSET(%rbp)
	jz	0f
	/* Save stack pointer */
	movq	P_CUR_TASK_OFFSET(%rbp),%rax
	movq	%rsp,TASK_RP(%rax)
0:
	/* Notify that the current task is switched */
	pushq	%rbp
	movq	P_CUR_TASK_OFFSET(%rbp),%rdi
	movq	P_NEXT_TASK_OFFSET(%rbp),%rsi
	callq	_arch_task_switched
	popq	%rbp

	/* Task switch (set the stack frame of the new task) */
	movq	P_NEXT_TASK_OFFSET(%rbp),%rax
	movq	%rax,P_CUR_TASK_OFFSET(%rbp)
	movq	TASK_RP(%rax),%rsp
	movq	$0,P_NEXT_TASK_OFFSET(%rbp)
	/* ToDo: Load LDT if necessary */
	/* Setup sp0 in TSS */
	//leaq	STACKFRAME_SIZE(%rsp),%rdx
	movq	P_CUR_TASK_OFFSET(%rbp),%rax
	movq	TASK_SP0(%rax),%rdx
	leaq	P_TSS_OFFSET(%rbp),%rax
	movq	%rdx,TSS_SP0(%rax)
	//clts
1:
//	movq    P_CUR_TASK_OFFSET(%rbp),%rax
//	movq    %rax,%dr0
//	movq    124(%rsp),%rax
//	movq    %rax,%dr1
//	movq    124+24(%rsp),%rax
//	movq    %rax,%dr2
//	movq    124+32(%rsp),%rax
//	movq    %rax,%dr3
	intr_lapic_isr_done
	iretq



_asm_popcnt:
	popcntq	%rdi,%rax
	ret
	/* The following routine is the software implementation of popcnt */
	movq	%rdi,%rax
	/* x = x - ((x>>1) & 0x5555555555555555) */
	movq	%rax,%rbx
	shrq	$1,%rbx
	movq	$0x5555555555555555,%rcx
	andq	%rcx,%rbx
	subq	%rbx,%rax
	/* x = (x & 0x3333333333333333) + ((x>>2) & 0x3333333333333333) */
	movq	%rax,%rbx
	movq	$0x3333333333333333,%rcx
	andq	%rcx,%rax
	shrq	$2,%rbx
	andq	%rcx,%rbx
	addq	%rbx,%rax
	/* x = (x + (x>>4)) & 0x0f0f0f0f0f0f0f0f */
	movq	%rax,%rbx
	movq	$0x0f0f0f0f0f0f0f0f,%rcx
	shrq	$4,%rbx
	addq	%rbx,%rax
	andq	%rcx,%rax
	/* x = x + (x>>8) */
	movq	%rax,%rbx
	shrq	$8,%rbx
	addq	%rbx,%rax
	/* x = x + (x>>16) */
	movq	%rax,%rbx
	shrq	$16,%rbx
	addq	%rbx,%rax
	/* x = x + (x>>32) */
	movq	%rax,%rbx
	shrq	$32,%rbx
	addq	%rbx,%rax
	/* x = x & 0x7f */
	andq	$0x7f,%rax
	ret

/* void asm_lapic_write(void *addr, u32 val); */
_asm_lapic_write:
	mfence		/* Prevent out-of-order execution */
	movl	%esi,(%rdi)
	ret

/* u32 asm_lapic_read(void *addr); */
_asm_lapic_read:
	mfence		/* Prevent out-of-order execution */
	movl	(%rdi),%eax
	ret

lapic_set_timer_one_shot:
	pushq	%rbp
	movq	%rsp,%rbp
	
	leaveq



/* Setup system call*/
_syscall_setup:
	/* Write syscall entry point */
	movq    $0xc0000082,%rcx        /* IA32_LSTAR */
	//rdmsr
	movq    $syscall_entry,%rax
	movq    %rax,%rdx
	shrq    $32,%rdx
	wrmsr
	/* Segment register */
	movq    $0xc0000081,%rcx
	movq    $0x0,%rax
	//movq  $0x6148,%rdx    /* sysret cs/ss, syscall cs/ss */
	//movq    $0x00590048,%rdx/* sysret cs/ss, syscall cs/ss */
	//movq    $0x003b0008,%rdx /* sysret cs/ss, syscall cs/ss */
	movq	$(GDT_RING0_CODE_SEL | (GDT_RING3_CODE_SEL<<16)),%rdx
	wrmsr
	/* Enable syscall */
	movl    $0xc0000080,%ecx        /* EFER MSR number */
	rdmsr
	btsl    $0,%eax                 /* SYSCALL ENABLE bit = 1 */
	wrmsr
	ret


/* void syscall(u64); */
_syscall:
	cli
	syscall
	sti
	ret

/* Syscall entry */
syscall_entry:
	cli
	movw	%cs,%ax
	andw	$3,%ax
	cmpw	$3,%ax
	jz	syscall_r3
	cmpw	$2,%ax
	jz	syscall_r2
	cmpw	$1,%ax
	jz	syscall_r1

syscall_r0:
	// RIP=>RCX, RFLAGS==>R11
	pushq   %rsp
	pushq   %rbp
	pushq   %rcx
	pushq   %r11

	/* Check the system call number */
	cmpq    $SYSCALL_MAX_NR,%rdi
	jg      1f
	/* Find the corresponding system call function */
	shlq    $3,%rdi /* Add sizeof(struct syscall) */
	movq    (_syscall_table),%rdx
	addq    %rdi,%rdx
	movq    (%rdx),%rax
	/* Call it */
	callq   *%rax
1:
	popq	%r11
	popq	%rcx
	popq	%rbp
	popq	%rsp
	/* Use iretq because sysretq cannot return to ring 0. */
	movq	$GDT_RING0_DATA_SEL,%rax /* SS: RING 0 */
	pushq	%rax
	leaq	8(%rsp),%rax /* SP */
	pushq	%rax
	pushq	%r11 /* remove IA32_FMASK; RFLAGS <- (R11 & 3C7FD7H) | 2; */
	movq    $GDT_RING0_CODE_SEL,%rax /* CS */
	pushq   %rax
	pushq   %rcx /* IP */
	sti
	iretq

syscall_r1:
	// RIP=>RCX, RFLAGS==>R11
	pushq   %rsp
	pushq   %rbp
	pushq   %rcx
	pushq   %r11

	/* Check the system call number */
	cmpq    $SYSCALL_MAX_NR,%rdi
	jg      1f
	/* Find the corresponding system call function */
	shlq    $3,%rdi /* Add sizeof(struct syscall) */
	movq    (_syscall_table),%rdx
	addq    %rdi,%rdx
	movq    (%rdx),%rax
	/* Call it */
	callq   *%rax
1:
	popq	%r11
	popq	%rcx
	popq	%rbp
	popq	%rsp
	/* Use iretq because sysretq cannot return to ring 1. */
	movq	$GDT_RING1_DATA_SEL,%rax /* SS: RING 1 */
	pushq	%rax
	leaq	8(%rsp),%rax /* SP */
	pushq	%rax
	pushq	%r11 /* remove IA32_FMASK; RFLAGS <- (R11 & 3C7FD7H) | 2; */
	movq    $GDT_RING1_CODE_SEL,%rax /* CS */
	pushq   %rax
	pushq   %rcx /* IP */
	sti
	iretq

syscall_r2:
	// RIP=>RCX, RFLAGS==>R11
	pushq   %rsp
	pushq   %rbp
	pushq   %rcx
	pushq   %r11

	/* Check the system call number */
	cmpq    $SYSCALL_MAX_NR,%rdi
	jg      1f
	/* Find the corresponding system call function */
	shlq    $3,%rdi /* Add sizeof(struct syscall) */
	movq    (_syscall_table),%rdx
	addq    %rdi,%rdx
	movq    (%rdx),%rax
	/* Call it */
	callq   *%rax
1:
	popq	%r11
	popq	%rcx
	popq	%rbp
	popq	%rsp
	/* Use iretq because sysretq cannot return to ring 2. */
	movq	$GDT_RING2_DATA_SEL,%rax /* SS: RING 2 */
	pushq	%rax
	leaq	8(%rsp),%rax /* SP */
	pushq	%rax
	pushq	%r11 /* remove IA32_FMASK; RFLAGS <- (R11 & 3C7FD7H) | 2; */
	movq    $GDT_RING2_CODE_SEL,%rax /* CS */
	pushq   %rax
	pushq   %rcx /* IP */
	sti
	iretq


syscall_r3:
	// RIP=>RCX, RFLAGS==>R11
	pushq   %rsp
	pushq   %rbp
	pushq   %rcx
	pushq   %r11
	/* Check the system call number */
	cmpq    $SYSCALL_MAX_NR,%rdi
	jg      1f
	/* Find the corresponding system call function */
	shlq    $3,%rdi /* Add sizeof(struct syscall) */
	movq    (_syscall_table),%rdx
	addq    %rdi,%rdx
	movq    (%rdx),%rax
	/* Call it */
	callq   *%rax
1:
	popq	%r11
	popq	%rcx
	popq	%rbp
	popq	%rsp
	sysretq



/* System call routine */
syscall_routine:
	//cli
	// RIP=>RCX, RFLAGS==>R11
	pushq   %rsp
	pushq   %rbp
	pushq   %rcx
	pushq   %r11
	/* Check the system call number */
	cmpq    $SYSCALL_MAX_NR,%rax
	jg      1f
	pushq   %rdx
	/* Find system call function */
	shlq    $3,%rax /* Add sizeof(struct syscall) */
	movq    (_syscall_table),%rdx
	addq    %rax,%rdx
	movq    (%rdx),%rax
	callq   *%rax
	popq    %rdx
1:	popq    %r11
	popq    %rcx
	popq    %rbp
	popq    %rsp
	//sti
	//sysretq
	/* Use iretq because sysretq cannot return to ring 1. */
	movq	$0x21,%rax /* SS: RING 1 */
	pushq	%rax
	leaq	8(%rsp),%rax /* SP */
	pushq	%rax
	pushq	%r11 /* remove IA32_FMASK; RFLAGS <- (R11 & 3C7FD7H) | 2; */
	movq    $0x19,%rax /* CS */
	pushq   %rax
	pushq   %rcx /* IP */
	sti
	iretq


/* void sem_up(u64 *) */
_sem_up:
	incq	(%rdi)
	ret
/* int sem_down(u64 *) */
_sem_down:
	movq	(%rdi),%rax
	movq	%rax,%rdx
	decq	%rdx
	/* If %rax==(%rdi) %rdi<-%rdx, else %rax<-(%rdi) */
	lock cmpxchg	%rdx,(%rdi)
	jnz	1f
	/* Succeeded */
	movq	$1,%rax
	ret
1:
	/* Failed */
	movq	$-1,%rax
	ret


_kmemcmp:
        xorq    %rax,%rax
        movq    %rdx,%rcx       /* n */
        cld                     /* Ensure the DF cleared */
        repe    cmpsb           /* Compare byte at (%rsi) with byte at (%rdi) */
        jz      1f
        decq    %rdi            /* rollback one */
        decq    %rsi            /* rollback one */
        movb    (%rdi),%al      /* *s1 */
        subb    (%rsi),%al      /* *s1 - *s2 */
1:
        ret

/* int kmemcpy(void *__restrict dst, void *__restrict src, size_t n) */
_kmemcpy:
        movq    %rdi,%rax       /* Return value */
        movq    %rdx,%rcx       /* n */
        cld                     /* Ensure the DF cleared */
        rep     movsb           /* Copy byte at (%rsi) to (%rdi) */
        ret

/* void * kmemset(void *b, int c, size_t len) */
_kmemset:
        pushq   %rdi
        pushq   %rsi
        movl    %esi,%eax       /* c */
        movq    %rdx,%rcx       /* len */
        cld                     /* Ensure the DF cleared */
        rep     stosb           /* Set %al to (%rdi)-(%rdi+%rcx) */
        popq    %rsi
        popq    %rdi
        movq    %rdi,%rax       /* Restore for the return value */
        ret

	.data
apic_base:
	.quad	0x0

gpf_reentry:
	.quad	0x0


