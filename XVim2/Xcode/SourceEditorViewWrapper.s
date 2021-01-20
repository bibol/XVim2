//
//  SourceCodeEditorViewWrapper.s
//  XVim2
//
//  Created by Ant on 23/10/2017.
//  Copyright © 2017 Shuichiro Suzuki. All rights reserved.
//

.text
    .global _scev_wrapper_call
    .global _scev_wrapper_call2
    .global _scev_wrapper_call3
    .global _scev_wrapper_call4
    .global _scev_wrapper_call5
    .global _scev_wrapper_call6
    .global _scev_wrapper_call7
    .global _scev_wrapper_call8
    .global _scev_wrapper_call9

    .global _seds_wrapper_call
    .global _seds_wrapper_call2
    .global _seds_wrapper_call3
    .global _seds_wrapper_call4
    .global _seds_wrapper_call5
    .global _seds_wrapper_call6
    .global _seds_wrapper_call7
    .global _seds_wrapper_call8
    .global _seds_wrapper_call9

_scev_wrapper_call:
_scev_wrapper_call2:
_scev_wrapper_call3:
_scev_wrapper_call4:
_scev_wrapper_call5:
_scev_wrapper_call6:
_scev_wrapper_call7:
_scev_wrapper_call8:
_scev_wrapper_call9:

_seds_wrapper_call:
_seds_wrapper_call2:
_seds_wrapper_call3:
_seds_wrapper_call4:
_seds_wrapper_call5:
_seds_wrapper_call6:
_seds_wrapper_call7:
_seds_wrapper_call8:
_seds_wrapper_call9:

#ifdef __x86_64__

# Prolog
    pushq %rbp
    movq  %rsp, %rbp

# Allocate memory on stack

    leaq    -8(%rsp), %rsp # allocate 8 byte on stack

# Save callee-save
    movq %r13, (%rsp)

# Body

    # We passed UnsafeMutablePointer that allocate 8 byte * 2 memory as 1st argument from Invoker.
    # %rdi = contextPtr[0] = self (view)
    # %rdi + 8 = contextPtr[1] = target function pointer

    # Load the target 'self', this is Swift function calling convensions
    # https://github.com/apple/swift/blob/main/docs/ABI/RegisterUsage.md
    movq  (%rdi), %r13

    # 8 + 8 = 16 bytes is ok to keeping 16-byte SP alignment, no need allocate more.
    pushq  8(%rdi)  # Push the target function pointer to stack

# Shuffle up arguments

    # rest of integer arguments (2nd~6th) from Invoker = %rsi, %rdx, %rcx, %r8, %r9
    # that must be shuffle up to call target function.
    # Currently we support up to 4 (r9 register is not shuffled up) arguments
    # for integer that passed as register.
    movq  %rsi, %rdi
    movq  %rdx, %rsi
    movq  %rcx, %rdx
    movq  %r8, %rcx
    movq  %r9, %r8

# CALL
    callq *(%rsp)

    addq $8, %rsp

# Restore registers from stack

    movq (%rsp), %r13

    // RAX, RDX Used for return values
    // RCX Used for return values
    // R8 Used for return values

    // XMM0-3 Used for return values

    leaq    8(%rsp), %rsp

# Cleanup
    movq %rbp, %rsp
    popq %rbp
    ret

#else

    // ARM64
    // Integer registers
    //
    // x0-7  : Integer arguments (volatile)
    // x8    : Struct return pointer (volatile)
    // x9-15 : Corruptible Register (volatile)
    // x16-17 : intra-procedure-call corruptible register (volatile)
    // https://developer.apple.com/documentation/xcode/writing_arm64_code_for_apple_platforms
    // x18: Platform reserve register. DON'T USE THIS REGISTER (volatile)
    // x19-28: Callee-save register (non-volatile)
    //     x20 : swift self
    //     x21 : Error return register
    // x29: Frame pointer
    // x30: Link register

    // 4 byte alignment to suppress linker warning
    // "ld: warning: arm64 function not 4-byte aligned"
    .p2align 2

// Save callee-save
    // store x20, x30 (LR) on stack
    stp x20, x30, [sp, #-16]!

    ldr x20, [x0]     // Load swift self
    ldr x30, [x0, #8] // Load target function pointer

# Slide up arguments
    mov x0, x1
    mov x1, x2
    mov x2, x3
    mov x3, x4
    mov x4, x5
    mov x5, x6
    mov x6, x7

# Call
    blr x30

# Cleanup
    ldp x20, x30, [sp], #16      // restore x20, x30 (LR)
    ret
#endif
