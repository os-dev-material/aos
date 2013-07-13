/*_
 * Copyright 2013 Scyphus Solutions Co. Ltd.  All rights reserved.
 *
 * Authors:
 *      Hirochika Asai  <asai@scyphus.co.jp>
 */

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

	.file	"asm.s"

	.text
	.globl	kstart64		/* Entry point */
	.globl	apstart64		/* Application processor */
	.globl	_pause
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
	.globl	_ltr
	.globl	_is_invariant_tsc
	.globl	_get_cpu_family
	.globl	_get_cpu_model
	.globl	_this_cpu
	.globl	_intr_null
	.globl	_intr_test
	.globl	_intr_gpf
	.globl	_apic_test
	.globl	_asm_ioapic_map_intr

	.code64

/*
 * Kernel main function
 */
kstart64:
	call	_kmain
	jmp	idle

apstart64:
	call	_apmain
	jmp	idle

halt:
	hlt
	jmp	halt

/* Idle process */
idle:
	sti
	hlt
	cli
	jmp	idle

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
	movw	$0x48,%ax
	movw	%di,%ax
	ltr	%ax
	ret

/* void asm_ioapic_map_intr(u64 src, u64 dst, u64 ioapic_base); */
_asm_ioapic_map_intr:
	/* Copy arguments */
	movq	%rdi,%rax	/* src */
	movq	%rsi,%rcx	/* dst */
	/* rdx = ioapic_base*/

	/* *(u32 *)(ioapic_base + 0x00) = dst * 2 + 0x10 */
	shlq	$2,%rcx		/* dst * 2 */
	addq	$0x10,%rcx	/* dst * 2 + 0x10 */
	sfence
	movl	%ecx,0x00(%rdx)
	/* *(u32 *)(ioapic_base + 0x10) = (u32)src */
	sfence
	movl	%eax,0x10(%rdx)
	shrq	$32,%rax
	/* *(u32 *)(ioapic_base + 0x00) = dst * 2 + 0x10 + 1 */
	addq	$1,%rcx		/* dst * 2 + 0x10 + 1 */
	sfence
	movl	%ecx,0x00(%rdx)
	/* *(u32 *)(ioapic_base + 0x10) = (u32)(src >> 32) */
	sfence
	movl	%eax,0x10(%rdx)

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
	movl	$0xfee00000,%edx
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
	/* APIC EOI */
	movq	$0xfee00000,%rdx
	//addq	$APIC_EOI,%rdx
	movq	$0,APIC_EOI(%rdx)
	popq	%rdx

	iretq

_intr_test:
	pushq	%rdx
	/* APIC EOI */
	movq	$0xfee00000,%rdx
	//addq	$APIC_EOI,%rdx
	movq	$0,APIC_EOI(%rdx)

	movq	$0xb8000,%rdx
	addb	$'!',%al
	movb	$0x07,%ah
	movw	%ax,0xf9c(%rdx)

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

/* Beggining of interrupt handler */
	.macro	intr_lapic_irq irq
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

	/* EOI for APIC */
	movw	$0x1b,%rcx
	rdmsr
	shlq	$32,%rdx
	addq	%rax,%rdx
	/* APIC_BASE */
	andq	$0xfffffffffffff000,%rdx
	movl	0x20(%rdx),%eax	/*APIC_ID*/
	//movq	%rax,%dr0

	movl	0xb0(%rdx),%eax
	xorl	%eax,%eax
	movl	%eax,(%rdx)
	.endm

	.macro	intr_lapic_irq_done
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

_intr_lapic_int32:
	intr_lapic_irq 0
	intr_lapic_irq_done
	iretq

_intr_lapic_int33:
	ret




_apic_test:
	mov	$0x61,%dx
	inb	%dx,%al
	andb	$0xfc,%al
	outb	%al,%dx
	orb	$3,%al
	outb	%al,%dx
	andb	$0xfc,%al
	outb	%al,%dx

	movw	$0x1b,%rcx
	rdmsr
	
	//movq	%rax,%dr0
	//movq	%rdx,%dr1
	
	shlq	$32,%rdx
	addq	%rax,%rdx
	andq	$0xfffffffffffff000,%rdx
	movq	%rdx,apic_base

	btl	$11,%eax	/* xAPIC */
	btl	$10,%eax	/* x2APIC */
	btl	$8,%eax		/* BSP */

	/* Initialize */
	//movq	apic_base,%rbx
	//addq	$APIC_DFR,%rbx
	//movl	$0xffffffff,(%rbx)	/* Flat */

	//movq	apic_base,%rbx
	//addq	$APIC_LDR,%rbx
	//movl	(%rbx),%eax
	//andl	$0x00ffffff,%eax	/* Logical APIC ID = 0 */


	movl	apic_base,%edx
	//addl	$APIC_LVT_TMR,%edx
	movl	$0x10,APIC_LVT_TMR(%edx)	/* Disable */

	movl	apic_base,%edx
	//addl	$APIC_LVT_PERF,%edx
	movl	$0x100,APIC_LVT_PERF(%edx)	/* NMI */

	/* GLOBAL APIC ENABLE FLAG MUST BE 1 */

	/* Spurious interrupt vector register: default vector 0xff */
	movl	apic_base,%edx
	//addl	$APIC_SIVR,%edx
	movl	APIC_SIVR(%edx),%eax
	orl	$0x100,%eax	/* Enable */
	movl	%eax,APIC_SIVR(%edx)

	/* APIC Timer */
	movl	apic_base,%edx
	//addl	$APIC_LVT_TMR,%edx
	movl	$0,%eax
	movl	%eax,APIC_LVT_TMR(%edx)

	/* Divide configuration register */
	movl	apic_base,%edx
	//addl	$APIC_TMRDIV,%edx
	movl	$0x03,%eax
	movl	%eax,APIC_TMRDIV(%edx)

	xorl	%ebx,%ebx
	decl	%ebx

	/* Enable PIT Counter2 */
	movw	$0x61,%dx
	inb	%dx,%al
	andb	$0xfd,%al		/* Clear bit 1 (disable speaker) */
	orb	$1,%al			/* Set bit 0 */
	outb	%al,%dx
	/* 1/100 sec */
	movb	$0xb2,%al		/* CNTR2, RL_DATA, Oneshot mode */
	outb	%al,$0x43		/* Write to command reg */
	movb	$0x9b,%al		/* Set clock (LSB) */
	outb	%al,$0x42
	movb	$0x2e,%al		/* Set clock (MSB) */
	outb	%al,$0x42
	/* Reset PIT one-shot counter */
	inb	%dx,%al			/* %dx=0x61 */
	andb	$0xfe,%al		/* Clean bit 0 */
	outb	%al,%dx
	orb	$1,%al
	outb	%al,%dx
	/* Reset APIC timer*/
	movq	apic_base,%rdx
	//addq	$APIC_INITTMR,%rdx
	movl	%ebx,APIC_INITTMR(%rdx)
	/* Wait until PIT counter reaches zero */
	movw	$0x61,%dx
1:
	pause
	inb	%dx,%al
	andb	$0x20,%al		/* Bit 5: Out-pin of counter 2 */
	jz	1b
	/* Stop APIC Timer */
	movq	apic_base,%rdx
	//addq	$APIC_LVT_TMR,%rdx
	movw	$0x10,APIC_LVT_TMR(%rdx)		/* APIC disable */
	/* Get current counter value (from 0xffffffff) */
	movq	apic_base,%rdx
	//addq	$APIC_CURTMR,%rdx
	movl	APIC_CURTMR(%rdx),%ebx

	/* To positive value */
	xorl	%eax,%eax
	subl	%ebx,%eax
	incl	%eax
	/* Multiply by 16 */
	shll	$4,%eax
	/* Multiply by 100 (100Hz) */
	movl	$100,%ebx
	mull	%ebx		/* %edx:%eax <- %eax * %ebx */
	//movq	%rax,%dr0

	movl	%eax,(apic_hz)

	ret


/*
 * Write to local APIC
 *   * Input
 *     - %eax: Value
 *     - %rbx: APIC offset
 *   * Output
 *     - void
 */
lapic_write:
	pushq	%rdx
	movq	apic_base,%rdx
	addq	%rbx,%rdx
	movl	%eax,(%rdx)
	popq	%rdx
	ret

/*
 * Read from local APIC
 *   * Input
 *     - %rbx: APIC offset
 *   * Output
 *     - %eax: Value
 */
lapic_read:
	pushq	%rdx
	movq	apic_base,%rdx
	addq	%rbx,%rdx
	movl	(%rdx),%eax
	popq	%rdx
	ret

lapic_uwait:
	pushq	%rbp
	movq	%rsp,%rbp

	leaveq
	ret

lapic_set_timer_one_shot:
	pushq	%rbp
	movq	%rsp,%rbp
	
	leaveq


	.data
apic_base:
	.quad	0x0
apic_hz:
	.long

gpf_reentry:
	.quad	0x0
