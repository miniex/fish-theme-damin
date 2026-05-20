# GNU `date %N` gives ns; BSD silently drops it — fall through to gdate/python3/perl.
# divide via string-slice (drop trailing 6 digits) because fish math is f64 and
# loses precision on 19-digit ns values. shared by damin_profile + damin_bench.
function _damin_profile_now_ms
    set -l n (command date +%s%N 2>/dev/null)
    if string match -rq '^[0-9]{13,}$' -- $n
        echo (string sub --end -6 -- $n)
        return
    end
    set n (command gdate +%s%N 2>/dev/null)
    if string match -rq '^[0-9]{13,}$' -- $n
        echo (string sub --end -6 -- $n)
        return
    end
    if command -q python3
        echo (command python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null)
        return
    end
    if command -q perl
        echo (command perl -MTime::HiRes=time -e 'printf("%d\n", time()*1000)' 2>/dev/null)
        return
    end
    echo (math (command date +%s) "*" 1000)
end
