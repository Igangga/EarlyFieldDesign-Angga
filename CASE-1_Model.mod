
# The optimization model is formulated in this model file. Here, all components of optimization are clearly stated, such as the parameters (optimization inputs), the sets, the variables, the objective function, and the constraints.






# -------------------------------Section 0-------------------------------
# ---------------------------Index Description---------------------------


# i --> indexes for reservoirs

# z --> indexes for points in time during the production period



# This work adapts 3D Piecewise Linear (PWL) approximations to represent some non-linear functions, i.e., qopp = f(Np, Nop, RM), Gp = f(Np, Nop, RM), Wp = f(Np, Nop, RM), Gi = f(Np, Nop, RM), and Wi = f(Np, Nop, RM). Np, Nop, and RM are cumulative oil production, number of oil producers, and recovery mechanism, respectively.

# j --> indexes for Np breakpoints

# k --> indexes for Nop breakpoints

# l --> indexes for RM breakpoints



# This work also adapts 2D PWL approximation to represent a non-linear function RM = f(zNgi, zNwi). zNgi and zNwi are binary variables which relate the number of gas and water injectors with the recovery mechanism (further explanation is given in Master Thesis report sec. 3.1.3).

# m --> indexes for zNgi breakpoints

# n --> indexes for zNwi breakpoints






# -------------------------------Section 1-------------------------------
# ------------Declaration of Parameters, Sets, and Variables-------------


# In this section, we declare all parameters, sets, and variables involved in the optimization model. A complete description of every parameter, set, and variable is provided in the Master Thesis report:
# - sec. 3.1.1 --> Parameters
# - sec. 3.1.2 --> Sets
# - sec. 3.1.3 --> Variables




# ------------------------------Section 1.1------------------------------
# ------------------Declaration of Parameters and Sets-------------------


# Declare: number of reservoirs & the set (1 = Løve; 2 = Nesehorn; 3 = Sebra)

param nr;

set R := 1..nr;



# Declare: number of points in time (resulted from discretization of the production period) & the set (1 = 01/01/2023; 2 = 01/01/2024; ...; 18 = 01/01/2040)

param np;

set P := 1..np;



# Declare: number of operational days per year

param tup;



# Declare: desired plateau rate

param qo_F_plateau; # unit: sm3/d



# Declare: the maximum number of pre-drilled wells

param Nop_pd_hat;

param Ni_pd_hat;



# Declare: the maximum number of wells that are drilled in each year

param Nwt_py_hat;



# Declare: the maximum number of injectors that are drilled in each reservoir

param Ngi_hat {i in R};

param Nwi_hat {i in R};



# Declare: the maximum injection rate for every injector

param qgi_pgi_hat; # unit: 1000 sm3/d

param qwi_pwi_hat; # unit: sm3/d



# Declare: number of breakpoints in 3D PWL approximations & the sets

param nbp_Np;

set V_Np := 1..nbp_Np;

param nbp_Nop {i in R};

set V_Nop {i in R} := 1..nbp_Nop[i];

param nbp_RM {i in R};

set V_RM {i in R} := 1..nbp_RM[i];



# Declare: PWL table to carry out 3D PWL approximations

param Np_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]}; # unit: Mill. sm3

param Nop_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};

param RMpp_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};

param qopp_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]}; # unit: sm3/d

param Gp_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]}; # unit: Mill. sm3

param Wp_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]}; # unit: Mill. sm3

param Gi_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]}; # unit: Mill. sm3

param Wi_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]}; # unit: Mill. sm3



# Declare: PWL table to carry out 2D PWL approximation

param zNgi_bar {m in {1,2}, n in {1,2}};

param zNwi_bar {m in {1,2}, n in {1,2}};

param RMds_bar {m in {1,2}, n in {1,2}};




# ------------------------------Section 1.2------------------------------
# -----------------------Declaration of Variables------------------------


# In addition to variables declaration, we have to define the constraints for each variable, such as non-negative variable and integer/binary variable (see Equation 3.13 and 3.14 in the Master Thesis report for further details).



# Declare: recovery mechanism (1 = natural depletion; 2 = water injection; 3 = gas injection; 4 = water & gas injection)

var RM {i in R} integer >= 0;



# Declare: binary variables zNgi (0 if RM = {1 or 2}; 1 if RM = {3 or 4})

var zNgi {i in R} binary >= 0;



# Declare: binary variables zNwi (0 if RM = {1 or 3}; 1 if RM = {2 or 4})

var zNwi {i in R} binary >= 0;



# Declare: the number of wells from time to time (indicate the drilling schedule)

var Nop {i in R, z in P} integer >= 0;

var Nop_F {z in P} integer >= 0;

var Ngi {i in R, z in P} integer >= 0;

var Ngi_F {z in P} integer >= 0;

var Nwi {i in R, z in P} integer >= 0;

var Nwi_F {z in P} integer >= 0;

var Nwt {i in R, z in P} integer >= 0;

var Nwt_F {z in P} integer >= 0;



# Declare: oil production potential, which is defined as the maximum rate a reservoir/field can deliver at a particular time. Further explanation is provided in the Master Thesis report sec. 2.1.

var qopp {i in R, z in P} >= 0; # unit: sm3/d

var qopp_F {z in P} >= 0; # unit: sm3/d



# Declare: production/injection rates

var qo {i in R, z in {2..np}} >= 0; # unit: sm3/d

var qo_F {z in {2..np}} >= 0; # unit: sm3/d

var qg {i in R, z in {2..np}} >= 0; # unit: 1000 sm3/d

var qg_F {z in {2..np}} >= 0; # unit: 1000 sm3/d

var qw {i in R, z in {2..np}} >= 0; # unit: sm3/d

var qw_F {z in {2..np}} >= 0; # unit: sm3/d

var qgi {i in R, z in {2..np}} >= 0; # unit: 1000 sm3/d

var qgi_F {z in {2..np}} >= 0; # unit: 1000 sm3/d

var qwi {i in R, z in {2..np}} >= 0; # unit: sm3/d

var qwi_F {z in {2..np}} >= 0; # unit: sm3/d



# Declare: cumulatives production/injection

var Np {i in R, z in P} >= 0; # unit: Mill. sm3

var Np_F {z in P} >= 0; # unit: Mill. sm3

var Gp {i in R, z in P} >= 0; # unit: Mill. sm3

var Gp_F {z in P} >= 0; # unit: Mill. sm3

var Wp {i in R, z in P} >= 0; # unit: Mill. sm3

var Wp_F {z in P} >= 0; # unit: Mill. sm3

var Gi {i in R, z in P} >= 0; # unit: Mill. sm3

var Gi_F {z in P} >= 0; # unit: Mill. sm3

var Wi {i in R, z in P} >= 0; # unit: Mill. sm3

var Wi_F {z in P} >= 0; # unit: Mill. sm3



# Declare: other variables associated with 3D PWL approximations

var lambda {i in R, z in P, j in V_Np, k in V_Nop[i], l in V_RM[i]} >= 0;

var eta_Np {i in R, z in P, j in V_Np} >= 0;

var eta_Nop {i in R, z in P, k in V_Nop[i]} >= 0;

var eta_RM {i in R, z in P, l in V_RM[i]} >= 0;



# Declare: other variables associated with 2D PWL approximation

var omega {i in R, m in {1,2}, n in {1,2}} >= 0;

var tau_zNgi {i in R, m in {1,2}} >= 0;

var tau_zNwi {i in R, n in {1,2}} >= 0;






# -------------------------------Section 2-------------------------------
# --------------------------Objective Function---------------------------


# The objective function of the optimization model is maximization of the plateau duration. This function is equavalent to the following objective function (eq3_1). Visualization of the objective function is given in the Master Thesis report (fig. 3.2). In principal, the optimization is aimed to move the oil production rates as close as possible to the desired plateau rate (but still satisfy the given constaints).

minimize eq3_1: sum{z in {2..np}} (qo_F_plateau - qo_F[z]);






# -------------------------------Section 3-------------------------------
# ------------------------------Constraints------------------------------


# In this section, we define all constraints involved in the optimization model. A complete explanation of every constraint is provided in the Master Thesis report:
# - sec. 3.1.5 --> Operational Constraints
# - sec. 3.1.6 --> Drilling Constraints
# - sec. 3.1.7 --> Consistency Constraints
# - sec. 3.1.8 --> Integer & Binary constraints
# - sec. 3.1.9 --> Constraints Induced by PWL Approximations




# ------------------------------Section 3.1------------------------------
# ------------------------Operational Constraints------------------------


# Define: the field should be produced at any rates no higher than the desired plateau rate

subject to eq3_2 {z in {2..np}}: qo_F[z] <= qo_F_plateau;



# Define: the production rate at any point in time never exceeds the production potential

subject to eq3_3a {i in R, z in {2..np}}: qo[i,z] <= qopp[i,z];

subject to eq3_3b {i in R, z in {2..np}}: qo[i,z] <= qopp[i,z-1];



# Define: the injection rates do not surpass the injection capabilities, which are defined as the number of injectors multiplied by the maximum injection rate for every injector

subject to eq3_4a {i in R, z in {2..np}}: qgi[i,z] <= Ngi[i,z-1]*qgi_pgi_hat;

subject to eq3_4b {i in R, z in {2..np}}: qwi[i,z] <= Nwi[i,z-1]*qwi_pwi_hat;




# ------------------------------Section 3.2------------------------------
# -------------------------Drilling Constraints--------------------------


# Define: the numbers of wells (oil producers, gas injectors, or water injectors) are non-decreasing from time to time

subject to eq3_5a {i in R, z in {2..np}}: Nop[i,z] - Nop[i,z-1] >= 0;

subject to eq3_5b {i in R, z in {2..np}}: Ngi[i,z] - Ngi[i,z-1] >= 0;

subject to eq3_5c {i in R, z in {2..np}}: Nwi[i,z] - Nwi[i,z-1] >= 0;



# Define: the number of injectors is controlled by two factors, i.e., 1) the binary variables zNgi & zNwi that depend on the recovery mechanism, and 2) the maximum number of injectors that are drilled in each reservoir.

subject to eq3_6a {i in R, z in P}: Ngi[i,z] <= zNgi[i]*Ngi_hat[i];

subject to eq3_6b {i in R, z in P}: Nwi[i,z] <= zNwi[i]*Nwi_hat[i];



# Define: the number of wells that are available at the beginning of the production period is no greater than the maximum number of pre-drilled wells

subject to eq3_7a: Nop_F[1] <= Nop_pd_hat;

subject to eq3_7b: Ngi_F[1] + Nwi_F[1] <= Ni_pd_hat;



# Define: at most, four wells can be drilled every year

subject to eq3_8 {z in {2..np}}: Nwt_F[z] - Nwt_F[z-1] <= Nwt_py_hat;




# ------------------------------Section 3.3------------------------------
# ------------------------Consistency Constraints------------------------


# Define: at the beginning of the production period, the cumulative oil production equals to zero

subject to eq3_9 {i in R}: Np[i,1] = 0;



# Define: cumulatives production/injection at a particular point in time are numerically estimated using backward rectangular integration method. In this method, production/injection rates at time t[z] represent constant productio/injection rates from time t[z-1] until time t[z]

subject to eq3_10a {i in R, z in {2..np}}: Np[i,z] = Np[i,z-1] + tup*qo[i,z]/1000000;

subject to eq3_10b {i in R, z in {2..np}}: Gp[i,z] = Gp[i,z-1] + tup*qg[i,z]/1000;

subject to eq3_10c {i in R, z in {2..np}}: Wp[i,z] = Wp[i,z-1] + tup*qw[i,z]/1000000;

subject to eq3_10d {i in R, z in {2..np}}: Gi[i,z] = Gi[i,z-1] + tup*qgi[i,z]/1000;

subject to eq3_10e {i in R, z in {2..np}}: Wi[i,z] = Wi[i,z-1] + tup*qwi[i,z]/1000000;



# Define: the total number of wells is equal to the summation of numbers of oil producers, gas injectors, and water injectors

subject to eq3_11 {i in R, z in P}: Nwt[i,z] = Nop[i,z] + Ngi[i,z] + Nwi[i,z];



# Define: any variable corresponds for the field is equal to the summation from each reservoir

subject to eq3_12a {z in P}: Nop_F[z] = sum{i in R} Nop[i,z];

subject to eq3_12b {z in P}: Ngi_F[z] = sum{i in R} Ngi[i,z];

subject to eq3_12c {z in P}: Nwi_F[z] = sum{i in R} Nwi[i,z];

subject to eq3_12d {z in P}: Nwt_F[z] = sum{i in R} Nwt[i,z];

subject to eq3_12e {z in P}: qopp_F[z] = sum{i in R} qopp[i,z];

subject to eq3_12f {z in {2..np}}: qo_F[z] = sum{i in R} qo[i,z];

subject to eq3_12g {z in {2..np}}: qg_F[z] = sum{i in R} qg[i,z];

subject to eq3_12h {z in {2..np}}: qw_F[z] = sum{i in R} qw[i,z];

subject to eq3_12i {z in {2..np}}: qgi_F[z] = sum{i in R} qgi[i,z];

subject to eq3_12j {z in {2..np}}: qwi_F[z] = sum{i in R} qwi[i,z];

subject to eq3_12k {z in P}: Np_F[z] = sum{i in R} Np[i,z];

subject to eq3_12l {z in P}: Gp_F[z] = sum{i in R} Gp[i,z];

subject to eq3_12m {z in P}: Wp_F[z] = sum{i in R} Wp[i,z];

subject to eq3_12n {z in P}: Gi_F[z] = sum{i in R} Gi[i,z];

subject to eq3_12o {z in P}: Wi_F[z] = sum{i in R} Wi[i,z];




# ------------------------------Section 3.4------------------------------
# ---------------Constraints Induced by PWL Approximations---------------


# The fundamental of PWL approximation is to replace a non-linear function with a set of linear functions. Using PWL approximations, one can transform an NLP problem into an MILP problem, which is easier to solve. Further explanation about PWL approximation is provided in the Master Thesis report sec. 2.3.



# As mentioned before, 3D PWL approximations are used to represent some non-linear functions. The following constraints are associated with the implementation of the 3D PWL approximations.

subject to eq3_15a {i in R, z in P}: Np[i,z] = sum{j in V_Np, k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l]*Np_bar[i,j,k,l];

subject to eq3_15b {i in R, z in P}: Nop[i,z] = sum{j in V_Np, k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l]*Nop_bar[i,j,k,l];

subject to eq3_15c {i in R, z in P}: RM[i] = sum{j in V_Np, k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l]*RMpp_bar[i,j,k,l];

subject to eq3_15d {i in R, z in P}: qopp[i,z] = sum{j in V_Np, k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l]*qopp_bar[i,j,k,l];

subject to eq3_15e {i in R, z in P}: 1 = sum{j in V_Np, k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l];

subject to eq3_15f {i in R, z in P, j in V_Np}: eta_Np[i,z,j] = sum{k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l];

subject to eq3_15g {i in R, z in P, k in V_Nop[i]}: eta_Nop[i,z,k] = sum{j in V_Np, l in V_RM[i]} lambda[i,z,j,k,l];

subject to eq3_15h {i in R, z in P, l in V_RM[i]}: eta_RM[i,z,l] = sum{j in V_Np, k in V_Nop[i]} lambda[i,z,j,k,l];

subject to eq3_16a {i in R, z in P}: Gp[i,z] = sum{j in V_Np, k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l]*Gp_bar[i,j,k,l];

subject to eq3_16b {i in R, z in P}: Wp[i,z] = sum{j in V_Np, k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l]*Wp_bar[i,j,k,l];

subject to eq3_16c {i in R, z in P}: Gi[i,z] = sum{j in V_Np, k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l]*Gi_bar[i,j,k,l];

subject to eq3_16d {i in R, z in P}: Wi[i,z] = sum{j in V_Np, k in V_Nop[i], l in V_RM[i]} lambda[i,z,j,k,l]*Wi_bar[i,j,k,l];



# 2D PWL approximation is used to represent a non-linear function RM = f(zNgi, zNwi). The following constraints are associated with the implementation of the 2D PWL approximation.

subject to eq3_17a {i in R}: zNgi[i] = sum{m in {1,2}, n in {1,2}} omega[i,m,n]*zNgi_bar[m,n];

subject to eq3_17b {i in R}: zNwi[i] = sum{m in {1,2}, n in {1,2}} omega[i,m,n]*zNwi_bar[m,n];

subject to eq3_17c {i in R}: RM[i] = sum{m in {1,2}, n in {1,2}} omega[i,m,n]*RMds_bar[m,n];

subject to eq3_17d {i in R}: 1 = sum{m in {1,2}, n in {1,2}} omega[i,m,n];

subject to eq3_17e {i in R, m in {1,2}}: tau_zNgi[i,m] = sum{n in {1,2}} omega[i,m,n];

subject to eq3_17f {i in R, n in {1,2}}: tau_zNwi[i,n] = sum{m in {1,2}} omega[i,m,n];