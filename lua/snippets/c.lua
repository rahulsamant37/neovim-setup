local ls = require 'luasnip'

local ps = ls.parser.parse_snippet
local function s(trig, dscr, body)
  return ps({ trig = trig, dscr = dscr }, body)
end

return {
  s('cpbasic', 'Minimal C CP template with basic debugging', [[
/*
Author: Rahul Samant
Created: $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND
*/

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef LOCAL
#define debug(...) fprintf(stderr, __VA_ARGS__)
#else
#define debug(...)
#endif

static void setup_io(void) {
#ifdef LOCAL
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
#endif
}

static void solve(void) {
    int n;
    if (scanf("%d", &n) != 1) {
        return;
    }

    int *arr = (int *)malloc((size_t)n * sizeof(int));
    if (!arr) {
        return;
    }

    for (int i = 0; i < n; ++i) {
        scanf("%d", &arr[i]);
    }

    $0

    free(arr);
}

int main(void) {
    setup_io();

    int t = 1;
    if (scanf("%d", &t) != 1) {
        return 0;
    }

    while (t--) {
        solve();
    }

    return 0;
}
  ]]),

  s('cpa', 'Simple C CP template with single-case main', [[
/*
Author: Rahul Samant
Created: $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND
*/

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>

#ifdef LOCAL
#define debug(...) fprintf(stderr, __VA_ARGS__)
#else
#define debug(...)
#endif

static void setup_io(void) {
#ifdef LOCAL
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
#endif
}

int main(void) {
    setup_io();

    int n;
    if (scanf("%d", &n) != 1) {
        return 0;
    }

    int arr[n];
    for (int i = 0; i < n; ++i) {
        scanf("%d", &arr[i]);
    }

    $0

    return 0;
}
  ]]),

  s('basicc', 'Bare-bones C starter', [[
#include <stdio.h>

int main(void) {
    $0
    return 0;
}
  ]]),
}
