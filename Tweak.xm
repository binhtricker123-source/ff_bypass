#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <sys/ptrace.h>
#import <substrate.h>

OSStatus SecTrustEvaluate_hook(SecTrustRef trust, SecTrustResultType *result) {
    if (result) *result = kSecTrustResultProceed;
    return errSecSuccess;
}

static int (*orig_ptrace)(int request, pid_t pid, caddr_t addr, int data);
int new_ptrace(int request, pid_t pid, caddr_t addr, int data) {
    return 0;
}

%hook NSString
- (BOOL)containsString:(NSString *)str {
    if ([str isEqualToString:@"Cydia"] || [str containsString:@"jailbreak"]) {
        return NO;
    }
    return %orig;
}
%end

%ctor {
    MSHookFunction((void *)SecTrustEvaluate, (void *)SecTrustEvaluate_hook, NULL);
    MSHookFunction((void *)ptrace, (void *)new_ptrace, (void **)&orig_ptrace);
    NSLog(@"[FF] Loaded Anti-Cheat Bypass!");
}
