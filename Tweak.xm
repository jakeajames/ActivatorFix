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

@interface SBRecentAppLayouts
-(id)recents;
@end

@interface SBMediaController
-(BOOL)changeTrack:(int)arg1 eventSource:(id)src;
-(BOOL)beginSeek:(int)arg1 eventSource:(id)src;
-(BOOL)endSeek:(int)arg1 eventSource:(id)src;
-(BOOL)toggleRepeatForEventSource:(id)arg1;
-(BOOL)toggleShuffleForEventSource:(id)arg1;
-(BOOL)togglePlayPauseForEventSource:(id)arg1;
@end

static id _instance;

%group Main
%hook SBUserAgent
- (id) init {
    if (_instance == nil) {
        _instance = %orig;
    }
    return _instance;
}

%new
+ (id) sharedUserAgent {
    if (!_instance) {
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

%hook _LASimpleListener
-(BOOL)clearSwitcher {
    SBAppSwitcherModel *switcher = [%c(SBAppSwitcherModel) sharedInstance];
    NSMutableArray *recents = [[switcher valueForKey:@"_recents"] recents];
    if (![recents count]) return NO;
    [recents removeAllObjects];
    
    SBMainSwitcherViewController *appSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
    if (appSwitcher) {
        if ([appSwitcher isVisible]) [appSwitcher dismissSwitcherNoninteractively];
        return YES;
    }
    return NO;
}
%end
%end

%group BSS
%hook BSSimpleAssertion
%new
-(id)operations {
    return NULL;
}
%new
-(void)setOperations:(id)op {
    return;
}
%end
%end

%group Media
%hook SBMediaController
%new
-(BOOL)changeTrack:(int)arg1 {
    return [self changeTrack:arg1 eventSource:nil];
}
%new
-(BOOL)beginSeek:(int)arg1 {
    return [self beginSeek:arg1 eventSource:nil];
}
%new
-(BOOL)endSeek:(int)arg1 {
    return [self endSeek:arg1 eventSource:nil];
}
%new
-(BOOL)toggleRepeat {
    return [self toggleRepeatForEventSource:nil];
}
%new
-(BOOL)toggleShuffle {
    return [self toggleShuffleForEventSource:nil];
}
%new
-(BOOL)togglePlayPause {
    return [self togglePlayPauseForEventSource:nil];
}
%end
%end

%ctor {
    if (![objc_getClass("BSSimpleAssertion") respondsToSelector:@selector(operations)]) {
        %init(BSS);
    }
    if (![objc_getClass("SBMediaController") respondsToSelector:@selector(changeTrack:)]) {
        %init(Media);
    }
    %init(Main);
}

