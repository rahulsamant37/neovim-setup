local ls = require 'luasnip'

local ps = ls.parser.parse_snippet

return {
  ps({ trig = 'cpfull', dscr = 'Full-featured C++ CP template with comprehensive debugging' }, [[
/*
Author: Rahul Samant
Created: $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND
*/

#include <bits/stdc++.h>
using namespace std;

// ==================== TYPE DEFINITIONS ====================
typedef long long ll;
typedef unsigned long long ull;
typedef long double ld;
typedef pair<int, int> pii;
typedef pair<ll, ll> pll;
typedef vector<int> vi;
typedef vector<ll> vll;
typedef vector<pii> vpii;
typedef vector<pll> vpll;
typedef vector<vi> vvi;
typedef vector<vll> vvll;

// ==================== MACROS ====================
#define all(x) (x).begin(), (x).end()
#define rall(x) (x).rbegin(), (x).rend()
#define pb push_back
#define eb emplace_back
#define mp make_pair
#define fi first
#define se second
#define sz(x) (int)(x).size()
#define rep(i, a, b) for(int i = (a); i < (b); ++i)
#define per(i, a, b) for(int i = (b) - 1; i >= (a); --i)
#define trav(a, x) for(auto& a : x)
#define endl '\n'

// ==================== DEBUG CONFIGURATION ====================
#ifdef LOCAL
#define DEBUG 1
#else
#define DEBUG 0
#endif

#define debug(x) if(DEBUG) { cerr << "[DEBUG] " << #x << " = " << (x) << endl; }
#define debug2(x, y) if(DEBUG) { cerr << "[DEBUG] " << #x << " = " << (x) << ", " << #y << " = " << (y) << endl; }
#define debug3(x, y, z) if(DEBUG) { cerr << "[DEBUG] " << #x << " = " << (x) << ", " << #y << " = " << (y) << ", " << #z << " = " << (z) << endl; }

template<typename T>
void debug_vec(const string& name, const vector<T>& v, int max_items = 20) {
    if(!DEBUG) return;
    cerr << "[DEBUG] " << name << " = [";
    for(int i = 0; i < min((int)v.size(), max_items); i++) {
        if(i > 0) cerr << ", ";
        cerr << v[i];
    }
    if((int)v.size() > max_items) cerr << "... (size=" << v.size() << ")";
    cerr << "]" << endl;
}

template<typename T>
void debug_matrix(const string& name, const vector<vector<T>>& mat, int max_rows = 10) {
    if(!DEBUG) return;
    cerr << "[DEBUG] " << name << " (" << mat.size() << "x" << (mat.empty() ? 0 : mat[0].size()) << "):" << endl;
    for(int i = 0; i < min((int)mat.size(), max_rows); i++) {
        cerr << "  [" << i << "] ";
        for(auto& x : mat[i]) cerr << x << " ";
        cerr << endl;
    }
    if((int)mat.size() > max_rows) {
        cerr << "  ... (" << mat.size() - max_rows << " more rows)" << endl;
    }
}

struct Timer {
    string name;
    chrono::high_resolution_clock::time_point start;
    Timer(string n = "Block") : name(n) {
        if(DEBUG) start = chrono::high_resolution_clock::now();
    }
    ~Timer() {
        if(DEBUG) {
            auto end = chrono::high_resolution_clock::now();
            auto duration = chrono::duration_cast<chrono::milliseconds>(end - start).count();
            cerr << "[TIMER] " << name << " took " << duration << "ms" << endl;
        }
    }
};

// ==================== CONSTANTS ====================
const int MOD = 1e9 + 7;
const int MOD2 = 998244353;
const ll INF = 1e18;
const int MAXN = 2e5 + 5;
const double EPS = 1e-9;
const double PI = acos(-1.0);

// ==================== FAST I/O ====================
void setup_io() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);
    cout.tie(nullptr);
    #ifdef LOCAL
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
    freopen("error.txt", "w", stderr);
    if(DEBUG) cerr << "[DEBUG] Using input.txt and output.txt" << endl;
    #endif
}

// ==================== MATH UTILITIES ====================
ll gcd(ll a, ll b) { return b ? gcd(b, a % b) : a; }
ll lcm(ll a, ll b) { return a / gcd(a, b) * b; }

ll pow_mod(ll base, ll exp, ll mod = MOD) {
    ll result = 1;
    base %= mod;
    while(exp > 0) {
        if(exp & 1) result = (result * base) % mod;
        base = (base * base) % mod;
        exp >>= 1;
    }
    return result;
}

ll mod_inv(ll a, ll mod = MOD) {
    return pow_mod(a, mod - 2, mod);
}

bool is_prime(ll n) {
    if(n < 2) return false;
    if(n == 2) return true;
    if(n % 2 == 0) return false;
    for(ll i = 3; i * i <= n; i += 2) {
        if(n % i == 0) return false;
    }
    return true;
}

vector<int> sieve(int n) {
    vector<bool> is_prime(n + 1, true);
    vector<int> primes;
    is_prime[0] = is_prime[1] = false;
    for(int i = 2; i <= n; i++) {
        if(is_prime[i]) {
            primes.pb(i);
            for(ll j = (ll)i * i; j <= n; j += i) {
                is_prime[j] = false;
            }
        }
    }
    if(DEBUG) cerr << "[DEBUG] Sieve: Found " << primes.size() << " primes up to " << n << endl;
    return primes;
}

vector<ll> prime_factors(ll n) {
    vector<ll> factors;
    for(ll d = 2; d * d <= n; d++) {
        while(n % d == 0) {
            factors.pb(d);
            n /= d;
        }
    }
    if(n > 1) factors.pb(n);
    return factors;
}

vector<ll> fact;
void precompute_factorials(int n, ll mod = MOD) {
    fact.resize(n + 1);
    fact[0] = 1;
    for(int i = 1; i <= n; i++) {
        fact[i] = (fact[i-1] * i) % mod;
    }
    if(DEBUG) cerr << "[DEBUG] Precomputed factorials up to " << n << endl;
}

ll nCr(int n, int r, ll mod = MOD) {
    if(r > n || r < 0) return 0;
    return (fact[n] * mod_inv(fact[r], mod) % mod * mod_inv(fact[n-r], mod)) % mod;
}

// ==================== GRAPH UTILITIES ====================
vector<int> bfs(const vector<vi>& graph, int start, int n) {
    vector<int> dist(n + 1, -1);
    queue<int> q;
    dist[start] = 0;
    q.push(start);
    int visited_count = 0;

    while(!q.empty()) {
        int u = q.front();
        q.pop();
        visited_count++;
        for(int v : graph[u]) {
            if(dist[v] == -1) {
                dist[v] = dist[u] + 1;
                q.push(v);
            }
        }
    }
    if(DEBUG) cerr << "[DEBUG] BFS from " << start << ": visited " << visited_count << " nodes" << endl;
    return dist;
}

void dfs(const vector<vi>& graph, int u, vector<bool>& visited) {
    visited[u] = true;
    for(int v : graph[u]) {
        if(!visited[v]) {
            dfs(graph, v, visited);
        }
    }
}

vector<ll> dijkstra(const vector<vector<pll>>& graph, int start, int n) {
    vector<ll> dist(n + 1, INF);
    priority_queue<pll, vector<pll>, greater<pll>> pq;
    dist[start] = 0;
    pq.push({0, start});
    int visited_count = 0;

    while(!pq.empty()) {
        auto [d, u] = pq.top();
        pq.pop();
        if(d > dist[u]) continue;
        visited_count++;
        for(auto [v, w] : graph[u]) {
            if(dist[u] + w < dist[v]) {
                dist[v] = dist[u] + w;
                pq.push({dist[v], v});
            }
        }
    }
    if(DEBUG) cerr << "[DEBUG] Dijkstra from " << start << ": visited " << visited_count << " nodes" << endl;
    return dist;
}

// ==================== DSU (Union-Find) ====================
struct DSU {
    vi parent, rank, size;
    int components;

    DSU(int n) : parent(n), rank(n, 0), size(n, 1), components(n) {
        iota(all(parent), 0);
        if(DEBUG) cerr << "[DEBUG] DSU initialized with " << n << " nodes" << endl;
    }

    int find(int x) {
        return parent[x] == x ? x : parent[x] = find(parent[x]);
    }

    bool unite(int x, int y) {
        x = find(x);
        y = find(y);
        if(x == y) return false;
        if(rank[x] < rank[y]) swap(x, y);
        parent[y] = x;
        size[x] += size[y];
        if(rank[x] == rank[y]) rank[x]++;
        components--;
        return true;
    }

    int get_size(int x) { return size[find(x)]; }
    int get_components() { return components; }
};

// ==================== SEGMENT TREE ====================
struct SegmentTree {
    int n;
    vector<ll> tree;

    SegmentTree(const vector<ll>& arr) : n(arr.size()), tree(4 * n) {
        build(arr, 0, 0, n - 1);
        if(DEBUG) cerr << "[DEBUG] SegmentTree built with " << n << " elements" << endl;
    }

    void build(const vector<ll>& arr, int node, int start, int end) {
        if(start == end) {
            tree[node] = arr[start];
        } else {
            int mid = (start + end) / 2;
            build(arr, 2 * node + 1, start, mid);
            build(arr, 2 * node + 2, mid + 1, end);
            tree[node] = tree[2 * node + 1] + tree[2 * node + 2];
        }
    }

    ll query(int node, int start, int end, int l, int r) {
        if(r < start || end < l) return 0;
        if(l <= start && end <= r) return tree[node];
        int mid = (start + end) / 2;
        return query(2 * node + 1, start, mid, l, r) + query(2 * node + 2, mid + 1, end, l, r);
    }

    ll query(int l, int r) { return query(0, 0, n - 1, l, r); }

    void update(int node, int start, int end, int idx, ll val) {
        if(start == end) {
            tree[node] = val;
        } else {
            int mid = (start + end) / 2;
            if(idx <= mid) update(2 * node + 1, start, mid, idx, val);
            else update(2 * node + 2, mid + 1, end, idx, val);
            tree[node] = tree[2 * node + 1] + tree[2 * node + 2];
        }
    }

    void update(int idx, ll val) { update(0, 0, n - 1, idx, val); }
};

// ==================== SOLUTION ====================
void solve() {
    $0
}

int main() {
    setup_io();

    auto start_time = chrono::high_resolution_clock::now();

    int t;
    cin >> t;
    if(DEBUG) cerr << "[DEBUG] Running " << t << " test case(s)" << endl;

    rep(i, 0, t) {
        if(DEBUG) {
            cerr << "\n[DEBUG] === Test Case " << (i + 1) << " ===" << endl;
            auto case_start = chrono::high_resolution_clock::now();
        }

        solve();

        if(DEBUG) {
            auto case_end = chrono::high_resolution_clock::now();
            auto case_time = chrono::duration_cast<chrono::milliseconds>(case_end - case_start).count();
            cerr << "[DEBUG] Case " << (i + 1) << " completed in " << case_time << "ms" << endl;
        }
    }

    if(DEBUG) {
        auto end_time = chrono::high_resolution_clock::now();
        auto total_time = chrono::duration_cast<chrono::milliseconds>(end_time - start_time).count();
        cerr << "\n[DEBUG] Total time: " << total_time << "ms" << endl;
    }

    return 0;
}
  ]]),

  ps({ trig = 'cpbasic', dscr = 'Minimal C++ CP template with basic debugging' }, [[
/*
Author: Rahul Samant
Created: $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND
*/

#include <bits/stdc++.h>
using namespace std;

typedef long long ll;
typedef vector<int> vi;
typedef vector<ll> vll;
typedef pair<int, int> pii;

#define all(x) (x).begin(), (x).end()
#define pb push_back
#define sz(x) (int)(x).size()
#define rep(i, a, b) for(int i = (a); i < (b); ++i)
#define endl '\n'

#ifdef LOCAL
#define debug(x) cerr << "[DEBUG] " << #x << " = " << (x) << endl
#else
#define debug(x)
#endif

const int MOD = 1e9 + 7;
const ll INF = 1e18;

void setup_io() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);
    #ifdef LOCAL
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
    #endif
}

void solve() {
    int n;
    cin >> n;
    vi arr(n);
    rep(i, 0, n) cin >> arr[i];
    $0
}

int main() {
    setup_io();
    int t;
    cin >> t;
    while(t--) {
        solve();
    }
    return 0;
}
  ]]),

  ps({ trig = 'cpa', dscr = 'Simple C++ CP template - no test-case loop, no solve(), just main with array input' }, [[
/*
Author: Rahul Samant
Created: $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND
*/

#include <bits/stdc++.h>
using namespace std;

typedef long long ll;
typedef vector<int> vi;
typedef vector<ll> vll;
typedef pair<int, int> pii;

#define all(x) (x).begin(), (x).end()
#define pb push_back
#define sz(x) (int)(x).size()
#define rep(i, a, b) for(int i = (a); i < (b); ++i)
#define endl '\n'

#ifdef LOCAL
#define debug(x) cerr << "[DEBUG] " << #x << " = " << (x) << endl
#else
#define debug(x)
#endif

const int MOD = 1e9 + 7;
const ll INF = 1e18;

void setup_io() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);
    #ifdef LOCAL
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
    #endif
}

int main() {
    setup_io();
    int n;
    cin >> n;
    vi arr(n);
    rep(i, 0, n) cin >> arr[i];
    $0
    return 0;
}
  ]]),

  ps({ trig = 'cpinter', dscr = 'Interactive C++ CP template with query debugging' }, [[
/*
Author: Rahul Samant
Interactive Problem Template
*/

#include <bits/stdc++.h>
using namespace std;

typedef long long ll;
typedef vector<int> vi;

#define all(x) (x).begin(), (x).end()
#define pb push_back
#define rep(i, a, b) for(int i = (a); i < (b); ++i)
#define endl '\n'

#ifdef LOCAL
#define debug(x) cerr << "[DEBUG] " << #x << " = " << (x) << endl
#else
#define debug(x)
#endif

int query_count = 0;

int query(int x) {
    query_count++;
    debug("Query #" << query_count << ": ? " << x);
    cout << "? " << x << endl;
    cout.flush();
    int response;
    cin >> response;
    debug("Response: " << response);
    return response;
}

void answer(int x) {
    debug("Answer: ! " << x);
    cout << "! " << x << endl;
    cout.flush();
}

void solve() {
    int n;
    cin >> n;
    debug("n = " << n);
    $0
}

int main() {
    // Don't use sync_with_stdio(false) for interactive problems!
    int t;
    cin >> t;
    #ifdef LOCAL
    cerr << "[DEBUG] Test cases: " << t << endl;
    #endif
    for(int i = 1; i <= t; i++) {
        #ifdef LOCAL
        cerr << "\n[DEBUG] === Case " << i << " ===" << endl;
        query_count = 0;
        #endif
        solve();
    }
    return 0;
}
  ]]),

  ps({ trig = 'cpext', dscr = 'Extended C++ utilities with math, DSU, and debug' }, [[
/*
Author: Rahul Samant
Created: $CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND
*/

#include <bits/stdc++.h>
using namespace std;

typedef long long ll;
typedef unsigned long long ull;
typedef pair<int, int> pii;
typedef pair<ll, ll> pll;
typedef vector<int> vi;
typedef vector<ll> vll;
typedef vector<pii> vpii;
typedef vector<vi> vvi;

#define all(x) (x).begin(), (x).end()
#define rall(x) (x).rbegin(), (x).rend()
#define pb push_back
#define mp make_pair
#define fi first
#define se second
#define sz(x) (int)(x).size()
#define rep(i, a, b) for(int i = (a); i < (b); ++i)
#define per(i, a, b) for(int i = (b) - 1; i >= (a); --i)
#define endl '\n'

#ifdef LOCAL
#define debug(x) cerr << "[DEBUG] " << #x << " = " << (x) << endl
#define debug2(x, y) cerr << "[DEBUG] " << #x << " = " << (x) << ", " << #y << " = " << (y) << endl
#else
#define debug(x)
#define debug2(x, y)
#endif

const int MOD = 1e9 + 7;
const int MOD2 = 998244353;
const ll INF = 1e18;
const int MAXN = 2e5 + 5;

void setup_io() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);
    #ifdef LOCAL
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
    freopen("error.txt", "w", stderr);
    #endif
}

ll gcd(ll a, ll b) { return b ? gcd(b, a % b) : a; }
ll lcm(ll a, ll b) { return a / gcd(a, b) * b; }

ll pow_mod(ll base, ll exp, ll mod = MOD) {
    ll result = 1;
    base %= mod;
    while(exp > 0) {
        if(exp & 1) result = (result * base) % mod;
        base = (base * base) % mod;
        exp >>= 1;
    }
    return result;
}

ll mod_inv(ll a, ll mod = MOD) {
    return pow_mod(a, mod - 2, mod);
}

vi sieve(int n) {
    vector<bool> is_prime(n + 1, true);
    vi primes;
    is_prime[0] = is_prime[1] = false;
    for(int i = 2; i <= n; i++) {
        if(is_prime[i]) {
            primes.pb(i);
            for(ll j = (ll)i * i; j <= n; j += i) {
                is_prime[j] = false;
            }
        }
    }
    return primes;
}

struct DSU {
    vi parent, rank, size;
    int components;

    DSU(int n) : parent(n), rank(n, 0), size(n, 1), components(n) {
        iota(all(parent), 0);
    }

    int find(int x) {
        return parent[x] == x ? x : parent[x] = find(parent[x]);
    }

    bool unite(int x, int y) {
        x = find(x);
        y = find(y);
        if(x == y) return false;
        if(rank[x] < rank[y]) swap(x, y);
        parent[y] = x;
        size[x] += size[y];
        if(rank[x] == rank[y]) rank[x]++;
        components--;
        return true;
    }

    int get_size(int x) { return size[find(x)]; }
    int get_components() { return components; }
};

void solve() {
    int n;
    cin >> n;
    vi arr(n);
    rep(i, 0, n) cin >> arr[i];
    $0
}

int main() {
    setup_io();

    int t;
    cin >> t;
    while(t--) {
        solve();
    }

    return 0;
}
  ]]),

  ps({ trig = 'basiccpp', dscr = 'Bare-bones C++ starter with just includes, two macros, and main' }, [[
#include <bits/stdc++.h>
using namespace std;

#define endl '\n'

int main() {
    int n;
    cin >> n;
    $0
    return 0;
}
  ]]),
}
