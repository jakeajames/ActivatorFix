
@interface SBMainSwitcherViewController
+(id)sharedInstance;
-(BOOL)toggleSwitcherNoninteractivelyWithSource:(id)source;
@end

@interface SBApplicationInfo
-(NSArray*)tags;
@end

@interface SBApplication
-(SBApplicationInfo*)info;
-(NSString*)bundleIdentifier;
@end

@interface SpringBoard
-(BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end

@interface SBApplicationIcon
-(SBApplication*)application;
@end

static id _instance;
%hook SBUserAgent
- (id) init
{
    if (_instance == nil)
    {
        _instance = %orig;
    }
    return _instance;
}
%new
+ (id) sharedUserAgent
{
    if (!_instance)
    {
        return [[%c(SBUserAgent) alloc] init];
    }
    return _instance;
}
%end

%hook SBApplication
%new
-(NSArray *)tags {
    return [[self info] tags];
}
%end

%hook SBMainSwitcherViewController
%new
-(BOOL)activateSwitcherNoninteractively {
    return [[%c(SBMainSwitcherViewController) sharedInstance] toggleSwitcherNoninteractivelyWithSource:nil];
}
%end

%hook SBApplicationIcon
%new
-(void)launch {
    [((SpringBoard*)[%c(SpringBoard) sharedApplication]) launchApplicationWithIdentifier:[[self application] bundleIdentifier] suspended:NO];
}
%end
