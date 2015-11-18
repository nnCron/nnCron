\ watch cpu usage
REQUIRE PERF-COUNTERS ~nn/lib/win/sys/perf.f
VARIABLE PerfMonitor

CLASS: ExceedCPUUsageObject <SUPER CPUUsageObject
    var vMax
    var vExceedTime
    var vBeginTime
    var vWatchObject
    CONSTR: init ( n1 n2 w -- )
        init
        vWatchObject !
        vExceedTime !
        vMax !
    ;
    VM: ?alert
\        vMax @ . CR
        get vMax @ 0< IF vMax @ ABS < ELSE vMax @ > THEN
        IF
            vBeginTime @ 0<> vExceedTime @ 0= OR
            IF
                GetTickCount vBeginTime @ - 
                vExceedTime @ >
                IF
                    vWatchObject @ qWS Put
                THEN
            ELSE
                GetTickCount vBeginTime !
            THEN
        ELSE
            vBeginTime 0!
        THEN
    ;
;CLASS
: WATCH-CPUUSAGE-START ( n1 n2 -- )
    1000 * CUR-WATCH ExceedCPUUsageObject NEW-PERF-OBJECT
    CUR-WATCH WATCH-OBJECT !
;

: WATCH-CPUUSAGE-STOP
    CUR-WATCH WATCH-OBJECT @ ->CLASS PerfObject Del
;

: WatchCPUUsage:
    POSTPONE WATCH:
    get-number POSTPONE LITERAL
    get-number POSTPONE LITERAL
    POSTPONE WATCH-CPUUSAGE-START
    ['] WATCH-CPUUSAGE-STOP WATCH-NODE WATCH-STOP !
    POSTPONE 0
    POSTPONE END-WATCH
; IMMEDIATE

WARNING @ WARNING 0!
: BeforeCrontabLoading
    BeforeCrontabLoading
;

: BeforeStop
    ?STOP-PERF-MONITOR
    BeforeStop
;

WARNING !

