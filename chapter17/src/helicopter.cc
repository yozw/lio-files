/*
 * Off-shore Helicopter Routing Solver
 * Copyright (C) 2013 Y. Zwols
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 


#include <assert.h>
#include <math.h>
#include <glpk.h>
#include <sys/time.h>
#include <time.h>
#include <sys/timeb.h>
#include <inttypes.h>

#include <algorithm>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <vector>
#include <unordered_map>

#include "hbitset.h"

using namespace std;

/* Maximum number of iterations to perform */
#define ITERATION_LIMIT 100000

/* Maximum number of columns to add per iteration */
#define MAX_COLUMNS_PER_ITERATION 15

/* Precision of objective value output */
#define OBJ_OUTPUT_PRECISION 3

/* Maximum number of platforms supported, INCLUDING the airport. */
#define MAXPLATFORMS 64

/* Structure for storing 2-dimensional points */
struct Point {
  double x, y;
  Point() { x = 0; y = 0; }
};

/* Structure for storing flights */
struct Flight {
  double x;
  double dS;
  vector<int> w;
};

/* Structure for storing problem data */
struct ProblemData {
  int N, R, C;                // #platforms, range, capacity
  vector<Point> P;            // list of platform coordinates
  vector<vector<double> > d;  // 2d array of pairwise distances
  vector<int> D;              // list of crew exchange demands
};

/* This is a functor that allows sorting platforms by their dual
   current variables */
class SortBy {
 private:
  const vector<double>* y_;

 public:
  explicit SortBy(const vector<double>& y) { y_ = &y; }

  bool operator() (const int lhs, const int rhs) {
    return (*y_)[lhs] > (*y_)[rhs];
  }
};

/* This function just outputs a string preceded and followed by a horizontal 
   line. */
inline void banner(const string& s)
{
  cout << endl;
  cout << string(80, '-') << endl;
  cout << s << endl;
  cout << string(80, '-') << endl;
}

/* Square of */
inline double sqr(const double x) { return x * x; }

/* This function constructs the next subset of {0, ..., K-1}, in the
   lexicographical order. If extend is set to false, then all supersets
   of the current set are skipped. */
bool next_lex_subset(vector<int> &z, const int K, const bool extend) {
  if (z.capacity() < K)
    z.reserve(K);

  int n = z.size();

  if ((extend) && (n < K) && ((n == 0) || (z[n-1] < K-1))) {
    // add one more item to the set
    z.resize(n+1);
    if (n == 0)
      z[n] = 0;
    else
      z[n] = z[n-1] + 1;
    n++;
  } else {
    // increase the current item
    z[n-1]++;
    while (z[n-1] >= K) {
      n--;
      if (n == 0) return false;
      z[n-1]++;
    }
    z.resize(n);
  }

  return true;
}

/* This function returns the objective function value corresponding to a set
   of flights. */
double solution_objective(const vector<Flight> &solution)
{
  double z = 0.0;
  for (int j = 0; j < solution.size(); j++)
    z += solution[j].dS * solution[j].x;
  return z;
}

/* This function outputs a set of flights. */
void print_solution(const vector<Flight> &solution, ostream& s)
{
  s << "Solution with z = " << fixed << setprecision(OBJ_OUTPUT_PRECISION) 
    << solution_objective(solution) << endl;
    
  for (int j = 0; j < solution.size(); j++)
  {
    s << solution[j].x << " " << solution[j].dS;
    for (int i = 1; i < solution[j].w.size(); i++)
    {
      if (solution[j].w[i] == 0) continue;
      s << " P" << i << "(" << solution[j].w[i] << ")";
    }
    s << endl;    
  }
}

/* This function reads the platform coordinates and demanded crew exchanges */
bool read_data(const string &platform_file, const string &demand_file, ProblemData& data) {
  cout << "Reading platform and crew exchange data" << endl;

  /* Read platform coordinates */
  ifstream Pfile(platform_file.c_str());
  if (!Pfile) {
    cerr << "Could not open file " << platform_file << endl;
    return false;
  }

  int N = -1, R = -1, C = -1;
  
  // Read N, R, C
  Pfile >> N >> R >> C;
  if ( (N < 1) || (R <= 0) || (C <= 0) ) {
    cerr << "Invalid input values: N=" << N << ", "
         << "R=" << R << ", "
         << "C=" << C << "." << endl;
    return false;
  }
  if (N > MAXPLATFORMS-1) {
    cerr << "Too many platforms. Raise MAXPLATFORMS and recompile." << endl;
    return false;
  }
  
  vector<Point> P;
  P.push_back(Point());           // add the airport at the origin
  for (int i = 1; i <= N; i++) {
    Point point;
    int index;
    Pfile >> index >> point.x >> point.y;
    assert(index == i);
    P.push_back(point);
  }
  Pfile.close();

  /* Read demanded crew exchanges */
  ifstream Wfile(demand_file.c_str());
  if (!Wfile) {
    cerr << "Could not open file " << demand_file << endl;
    return false;
  }

  vector<int> D;
  D.push_back(0);                         // demand at the airport is zero
  for (int i = 1; i <= N; i++) {
    int index, demand;
    Wfile >> index >> demand;
    assert(index == i);
    D.push_back(demand);
  }
  Wfile.close();

  data.N = N;
  data.R = 200;
  data.C = 23;
  data.P = P;
  data.D = D;
  
  cout << "Succesfully read data for " << N << " platforms" << endl;
  
  return true;
}

/* This function calculates the distances between all pairs of airport and
   platforms */
void calculate_distances(ProblemData &data) {
  int N = data.N;

  /* Construct empty (N+1)x(N+1) matrix */
  data.d.resize(N+1);
  for (int i = 0; i <= N; i++)
    data.d[i].resize(N+1);

  /* Calculate pairwise distances */
  for (int i = 0; i <= N; i++)
    for (int j = i + 1; j <= N; j++)
    {
      Point Pi = data.P[i];
      Point Pj = data.P[j];
      data.d[i][j] = data.d[j][i] = sqrt(sqr(Pi.x-Pj.x) + sqr(Pi.y-Pj.y));
    }
}

/* This function creates a new GLPK optimizaton model.
   Initially, the model contains N rows, but no columns. */
glp_prob* create_lp(const ProblemData& data) {
  /* Construct GLPK linear optimzation model */
  glp_prob *lp = glp_create_prob();
  glp_set_prob_name(lp, "flightcrew");
  glp_set_obj_dir(lp, GLP_MIN);

  int N = data.N;

  /* Add N rows, one for each platform i */
  glp_add_rows(lp, N);
  for (int i = 1; i <= N; i++)
    glp_set_row_bnds(lp, i, GLP_FX, data.D[i], data.D[i]);

  return lp;
}

/* This function cleans up the GLPK optimization model */
void free_lp(glp_prob *lp) {
  glp_delete_prob(lp);
  glp_free_env();
}


static long tsp_count = 0;
static long tsp_cache_hit = 0;
static uint64_t tsp_solve_time = 0;
static uint64_t tsp_cache_time = 0;
static uint64_t last_tsp_report = 0;
static unordered_map<hbitset<MAXPLATFORMS>, double> tsp_cache;

// needs -lrt (real-time lib)
// 1970-01-01 epoch UTC time, 1 mcs resolution (divide by 1M to get time_t)
uint64_t ClockGetTime()
{
    timespec ts;
    clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &ts);
    return (uint64_t)ts.tv_sec * 1000000LL + (uint64_t)ts.tv_nsec / 1000LL;
}

void tsp_report() {
    cout << fixed << tsp_count << " solve_tsp calls, " 
      << "cache hit=" << setprecision(2) 
      << 100.0 * (tsp_cache_hit / static_cast<double>(tsp_count))
      << "%, solve time=" << (tsp_solve_time / 1000000.0) << " s, " 
      << "cache lookup time=" << (tsp_cache_time / 1000000.0) << " s" 
      << endl;
    last_tsp_report = ClockGetTime();
}

/* This function calculates the shortest traveling salesman tour
   starting and ending at the airport, and going through all platforms
   in S, subject to the distance being at most max_value (which will be taken
   to be slightly larger than the range). 
   Notice that the function uses a caching mechanism to store
   previously calculated values. */

double solve_tsp(vector<int> S, const vector<vector<double> > &d, double max_value) {
  int n = S.size();
  double z;
  tsp_count++;
  
  if (ClockGetTime() - last_tsp_report >= 30000000) // report statistics every 30 s
    tsp_report();

  // Sort elements of S
  sort(S.begin(), S.end());
  
  // Retrieve value from cache, if it is in there
  uint64_t start = ClockGetTime();
  hbitset<MAXPLATFORMS> hb;
  for (int i = 0; i < S.size(); i++)
    hb.set(S[i]);

  unordered_map<hbitset<MAXPLATFORMS>, double>::iterator it = tsp_cache.find(hb);
  tsp_cache_time += ClockGetTime() - start;
  if (it != tsp_cache.end()) {
    tsp_cache_hit++;
    return it->second;
  }


  // Calculate the minimum distance required to go from any platform
  // back to the airport. We use this quantity later to prune solutions.
  double min_way_back = 1e100;
  for (int i = 0; i < S.size(); i++) 
    min_way_back = min(min_way_back, d[0][S[i]]);
    
  // Here, we go through all permutations of S.
  z = max_value;
  start = ClockGetTime();
  do {
    // Since any tour and its reverse have the same total distance,
    // we only need to consider permutations with S[0] < S[n-1]
    if (S[0] > S[n-1]) 
      continue;

    // This will eventually hold the length of the current TSP tour      
    double perm_z = d[0][S[0]];
    
    // While we're at it, we calculate the smallest value of istar
    // so that the total distance from points 0, S[0], S[1], ..., S[istar]
    // is greater than our best known bound. If such an istar exists,
    // then we may ignore all permutations in S that start with
    // S[0], S[1], ..., S[istar]    
    int istar = -1;
    
    for (int i = 1; i < n; i++) {
      perm_z += d[S[i-1]][S[i]];
      if (perm_z + min_way_back >= z) {
        istar = i;
        break;
      }
    }
    
    // As described above, if istar exists (i.e. it is not -1), we may
    // prune all permutations starting with S[0], S[1], ..., S[istar],
    // which is 
    if (istar >= 0) {
      sort(S.begin() + istar + 1, S.end(), std::greater<int>());
      continue;
    }
    
    perm_z +=  d[S[n-1]][0];
      
    if (perm_z < z)
      z = perm_z;
  } while (next_permutation(S.begin(), S.end()));

  tsp_solve_time += ClockGetTime() - start;

  // Store result in cache  
  start = ClockGetTime();
  tsp_cache[hb] = z;
  tsp_cache_time += ClockGetTime() - start;
  return z;
}


int update_rhs_and_construct_basis(glp_prob* lp, const ProblemData &data)
{
  int N = data.N;
  int C = data.C;
  
  // Add initial columns
  if (glp_get_num_cols(lp) < N)
    glp_add_cols(lp, N - glp_get_num_cols(lp));
    
  for (int j = 1; j <= N; j++) {
    // set the jth entry of the jth column to min(C, D[j]),
    // or to 1 if D[j] = 0
    double w = max(min(C, data.D[j]), 1);
    int    ind[2]; ind[0] = 0; ind[1] = j;
    double val[2]; val[0] = 0; val[1] = w;
    glp_set_mat_col(lp, j, 1, ind, val);

    // set the corresponding objective coefficient to the distance
    // of flying from the airport to platform P(j) and back
    double dj = data.d[0][j] + data.d[j][0];
    glp_set_obj_coef(lp, j, dj);

    // make the corresponding variable nonnegative
    glp_set_col_bnds(lp, j, GLP_LO, 0.0, 0.0);
    
    // make the corresponding variable a basic variable
    glp_set_col_stat(lp, j, GLP_BS);
  }

  // make all rows fixed rows  
  for (int i = 1; i <= glp_get_num_rows(lp); i++)
    glp_set_row_stat(lp, i, GLP_NS);

  // make all other columns nonbasic (on lower bound)
  for (int j = N + 1; j <= glp_get_num_cols(lp); j++)
    glp_set_col_stat(lp, j, GLP_NL);
}

int run_column_generation(glp_prob* lp, const ProblemData &data, vector<Flight> &xopt) {
  int N = data.N, R = data.R, C = data.C;
  
  // Set up some arrays that will be in the column generation procedure
  // There have been taken outside of the loop for efficiency reasons.
  vector<int> Pindex;
  Pindex.reserve(N);
  for (int i = 1; i <= N; i++)
    if (data.D[i] > 0)
      Pindex.push_back(i);
      
  int ind[N+1];
  double val[N+1];
  vector<double> y(N+1);
  vector<int> pi;
  vector<int> S;
  pi.reserve(N);
  S.reserve(N);

  // Set up GLPK simplex parameters
  glp_smcp parm;
  glp_init_smcp(&parm);
  parm.msg_lev = GLP_MSG_ERR;
  
  update_rhs_and_construct_basis(lp, data);

  // Start the column generation procedure
  bool optimal = false;
  int iteration = 1;
  while ((!optimal) && (iteration < ITERATION_LIMIT)) {
    // Solve the current linear optimization model
    glp_simplex(lp, &parm);

    // Output the objective value
    if ((iteration % 25) == 0) {
      cout << "Iteration " << setw(6) << iteration
           << ", objective = " << fixed << setprecision(OBJ_OUTPUT_PRECISION) 
           << glp_get_obj_val(lp) << endl;
    }

    // Get dual values
    for (int i = 1; i <= N; i++)
      y[i] = glp_get_row_dual(lp, i);

    // Sort platforms in descending order of dual variables
    sort(Pindex.begin(), Pindex.end(), SortBy(y));

    // Construct platform subsets S to generate columns
    bool   considerSupersets = true;
    int    columnsAdded = 0;
    pi.clear();
    while (next_lex_subset(pi, Pindex.size(), considerSupersets)
           && (columnsAdded < MAX_COLUMNS_PER_ITERATION)) {

      considerSupersets = true;

      // Construct set S
      S.clear();
      for (int i = 0; i < pi.size(); i++)
        S.push_back(Pindex[pi[i]]);

      // Calculate TSP tour length
      double dS = solve_tsp(S, data.d, R + 0.1);
      
      // If the length of the TSP tour is larger than R, then we may
      // exclude S and all its supersets
      if (dS > R) {
        considerSupersets = false;
        continue;
      }

      // Calculate reduced cost of the this column
      double c = dS;                        // reduced cost
      int Cremaining = C;                   // remaining capacity
      int sumDi = 0;                        // sum of D[i] for i in S
      for (int j = 0; j < S.size(); j++) {
        int i = S[j];                       // we are considering platform P(i)
        int w = min(Cremaining, data.D[i]); 
        ind[j+1] = i;
        val[j+1] = w;
        Cremaining -= w;                    // update remaining capacity
        c  -= w * y[i];                     // update reduced cost
        sumDi += data.D[i];                 // update sum of D[i] for i in S
      }

      // if the D[i]'s add up to more than C, we do not need to consider
      // any supersets of S anymore
      if (sumDi >= C)
        considerSupersets = false;

      // if the reduced cost is negative, add the column
      if (c < -1e-8) {
        // add the column
        int j = glp_add_cols(lp, 1);
        glp_set_mat_col(lp, j, S.size(), ind, val);
        glp_set_obj_coef(lp, j, dS);
        glp_set_col_bnds(lp, j, GLP_LO, 0.0, 0.0);
        columnsAdded++;
      }
    }
    optimal = (columnsAdded == 0);
    iteration++;
  }

  // Output the objective value
  if (optimal) {
      cout << "Optimal solution found after " << iteration
           << " iterations, objective value = " 
           << fixed << setprecision(OBJ_OUTPUT_PRECISION) << glp_get_obj_val(lp)
           << endl;
  } else {
      cout << "Too many iterations. Optimization terminated after "
           << iteration << "iterations, objective value = "
           << fixed << setprecision(OBJ_OUTPUT_PRECISION) << glp_get_obj_val(lp) << endl;
  }

  // Extract solution
  xopt.clear();
  for (int j = 1; j <= glp_get_num_cols(lp); j++) {
    double x = glp_get_col_prim(lp, j);

    // if the optimal value of x(j) is (nearly) zero,
    // continue to the column    
    if (x < 1e-8) continue;
    
    int len = glp_get_mat_col(lp, j, ind, val);
    
    Flight f;
    f.x = x;
    f.dS = glp_get_obj_coef(lp, j);
    f.w.resize(N+1);
    for (int i = 1; i <= len; i++)
      f.w[ind[i]] = val[i];
    xopt.push_back(f);
  }
  return 0;
}

int solve_LP_relaxation(const ProblemData &data, vector<Flight> &xopt) {
  int N = data.N, C = data.C, R = data.R;
  
  // Construct LP model
  glp_prob* lp = create_lp(data);
  run_column_generation(lp, data, xopt);

  // Clean up
  free_lp(lp);
  return 0;
}

int round_solution(ProblemData data, vector<Flight> &xopt, double *z_relax) {
    
  int N = data.N, C = data.C;
  xopt.clear();

  // Construct LP model
  glp_prob* lp = create_lp(data);

  int sumD = 0;
  for (int i = 1; i <= N; i++)
    sumD += data.D[i];
    
  int iteration = 1;
  while (sumD > 0) {
    cout << "*** Round-off algorithm, iteration " << iteration 
         << " (remaining total demand=" << sumD << ")" << endl;

    vector<Flight> lp_xopt;
    run_column_generation(lp, data, lp_xopt);
    if (iteration == 1)
    {
      *z_relax = solution_objective(lp_xopt);
      cout << "LP-relaxation objective value: "
           << fixed << setprecision(OBJ_OUTPUT_PRECISION) << *z_relax << endl;
    }
    
    // pick an arbitrary column of lp_xopt that has positive value
    int j = rand() % lp_xopt.size();
    Flight f = lp_xopt[j];

    // round x value
    f.x = (lp_xopt[j].x > 1) ? floor(lp_xopt[j].x) : 1;
    xopt.push_back(f);

    // update D[i]'s and update right hand sides
    for (int i = 1; i <= N; i++) {
      data.D[i] -= f.x * f.w[i];
      sumD -= f.x * f.w[i];
      glp_set_row_bnds(lp, i, GLP_FX, data.D[i], data.D[i]);
    }

    // delete all infeasible columns
    vector<int> del_cols(0);
    for (int j = N+1; j <= glp_get_num_cols(lp); j++)
    {
      // check if column j is feasible
      int ind[N];
      double val[N];
      int len = glp_get_mat_col(lp, j, ind, val);
      for (int k = 1; k <= len; k++)
        if (val[k] > data.D[ind[k]])
        {
          del_cols.push_back(j);
          break;
        }
    }
    
    // if we marked any columns to delete, delete them now
    if (del_cols.size() > 1) 
      glp_del_cols(lp, del_cols.size()-1, &del_cols.front());
    iteration++;
  }
  
  // Clean up
  free_lp(lp);
  return 0;
}


/* Main function */
int main(int argc, char* argv[]) {

  timeval time;
  gettimeofday(&time, NULL);
  srand((time.tv_sec * 1000) + (time.tv_usec / 1000));
  
  // problem parameters
  int C = 23;
  int R = 200;
  int N = 51;
  
  if (argc != 3) {
    cerr << "Usage: helicopter <platform file> <demand file>" << endl;
    return 1;
  }
  string platform_file(argv[1]);
  string demand_file(argv[2]);

  ProblemData data;

  // Read the input data
  if (!read_data(platform_file, demand_file, data))
    return 1;

  // Calculate distances between platforms
  calculate_distances(data);
  
  for (int trial = 1; trial <= 16; trial++) {

    uint64_t start = ClockGetTime();

    cout << endl << "---- TRIAL " << trial << " ----" << endl;

    banner("RUNNING ROUND-OFF ALGORITHM");

    vector<Flight> xopt;
    double z_relax;
    round_solution(data, xopt, &z_relax);
    double z_round = solution_objective(xopt);

    banner("INTEGER SOLUTION PRODUCED BY ROUND-OFF ALGORITHM");
    print_solution(xopt, cout);
    
    cout << "Rounded solution is at most " 
         << fixed << setprecision(2) << 100.0 * (z_round - z_relax) / z_relax 
         << "% more expensive than the optimal solution." << endl;
         
    cout << "Total computation time: " << ((ClockGetTime() - start) / 1000000.0) << " seconds." << endl;
    cout << endl;
  }
         
  tsp_report();
}
