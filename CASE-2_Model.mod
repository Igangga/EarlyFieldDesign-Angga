
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



# An additional index that is used in this optimization model:

# p --> indexes for points in time prior to the production period (1 = 01/01/2019; 2 = 01/01/2020; 3 = 01/01/2021; 4 = 01/01/2022)






# -------------------------------Section 1-------------------------------
# ------------Declaration of Parameters, Sets, and Variables-------------


# In this section, we declare all parameters, sets, and variables involved in the optimization model. All parameters, sets, and variables described in "CASE-1_Model.mod: Section 1" are relevant for this optimization model, except for a parameter named "qo_F_plateau" (desired plateau rate). Some new parameters and variables that are required for NPV calculation are also introduced. A complete description of every parameter, sets, and variable is provided in the Master Thesis report:
# - sec. 3.1.1 & sec. 4.1.1 --> Parameters
# - sec. 3.1.2 --> Sets
# - sec. 3.1.3 & sec. 4.1.3 --> Variables




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



# Declare: oil price (constant throughout the production period)

param Po; # unit: USD/bbl



# Declare: exchange rate (constant throughout the production period)

param XR; # unit: NOK/USD



# Declare: volume conversion constant

param VC; # unit: bbl/m3



# Declare: discount rate

param d; # unit: frac./year



# Next, we will declare parameters associated with the cost proxy model. The cost proxy model was generated based on inputs provided by Aker Solutions. In this proxy model, the development costs were splitted into 6 categories:
# 1. Exploration Expenditure (ExpEx)
# 2. Drilling Expenditure (DrillEx)
# 3. Abandonment Expenditure (AbEx)
# 4. Capital Expenditure for Subsea Equipment (Subsea-CapEx)
# 5. Capital Expenditure for Offshore Structure & Topside Facilities (Topside-CapEx)
# 6. Operating Expenses (OpEx)



# In the cost proxy model, ExpEx was modelled as a fixed cost

# Declare: fixed exploration expenditure made at time-p (see description of index-p)

param A {p in {1,2,3,4}}; # unit: Mill. NOK



# In the cost proxy model, DrillEx was assumed to be linearly dependent on the number of wells

# Declare: drilling cost per well

param B; # unit: Mill. NOK/well



# In the cost proxy model, AbEx was estimated using the following equation:

# AbEx = fixed cost + D[1] * Nop_F[np] + D[2] * (Ngi_F[np] + Nwi_F[np])

# where Nop_F[np], Ngi_F[np], and Nwi_F[np] are the total number of oil producers, gas injectors, and water injectors in the field, respectively, at the end of the field lifetime

# Declare: fixed abandoment expenditure made at time-p (see description of index-p)

param C {p in {1,2,3,4}}; # unit: Mill. NOK

# Declare: coefficients in a linear function that estimates AbEx

param D {q in {1,2}}; # unit: Mill. NOK/oil producer (for D[1]); Mill. NOK/injector (for D[2])



# In the cost proxy model, Subsea-CapEx was estimated using the following equation:

# Subsea-CapEx = E[1] * Nt_F + E[2] * Nx_F

# where Nt_F and Nx_F are the total number of subsea templates and subsea Xmas-trees in the field, respectively

# Declare: coefficients in a linear function that estimates Subsea-CapEx

param E {r in {1,2}}; # unit: Mill. NOK/template (for E[1]); Mill. NOK/Xmas-tree (for E[2])



# In the cost proxy model, Topside-CapEx was estimated using the following equation:

# Topside-CapEx = F[1] * qo_F_hat + F[2] * qg_F_hat + F[3] * qw_F_hat

# where qo_F_hat, qg_F_hat, and qw_F_hat are the maximum oil, gas, and water production rate of the field, respectively

# Declare: coefficients in a linear function that estimates Topside-CapEx

param F {s in {1,2,3}}; # unit: Mill. NOK/(sm3/d) (for F[1] and F[3]); Mill. NOK/(1000 sm3/d) (for F[2])



# In the cost proxy model, OpEx made at time-(z) was estimated using the following equation:

# OpEx[z] = G[1] + G[2] * Nop_F[z-1] + G[3] * qo_F_dot[z-1;z] + G[4] * qg_F_dot[z-1;z] + G[5] * qw_F_dot[z-1;z]

# where Nop_F[z-1] is the number of oil producers in the field that are available at time-(z-1). qo_F_dot[z-1;z], qg_F_dot[z-1;z], and qw_F_dot[z-1;z] are the average production rate of oil, gas, and water, respectively, from time-(z-1) to time-(z).

# Declare: coefficients in a linear function that estimates OpEx

param G {t in {1,2,3,4,5}}; # unit: Mill. NOK (for G[1]), Mill. NOK/oil producer (for G[2]), Mill. NOK/(sm3/d) (for G[3] and G[5]); Mill. NOK/(1000 sm3/d) (for G[4])




# ------------------------------Section 1.2------------------------------
# -----------------------Declaration of Variables------------------------


# In addition to variables declaration, we have to define the constraints for each variable, such as non-negative variable and integer/binary variable (see Equation 3.13, 3.14, and 4.20 in the Master Thesis report for further details). Exception to Equation 3.13: variables DCF[z] and NPV are the only variables that can have negative values.



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



# Declare: present value of ExpEx

var PVe >= 0; # unit: Mill. NOK



# Declare: present value of DrillEx for the pre-drilled wells

var PVdp >= 0; # unit: Mill. NOK

# Declare: present value of DrillEx made at time-(z)

var PVd {z in {1..(np-1)}} >= 0; # unit: Mill. NOK



# Declare: present value of AbEx

var PVa >= 0; # unit: Mill. NOK



# Declare: number of subsea templates

var Nt {i in R} integer >= 0;

var Nt_F integer >= 0;

# Declare: number of subsea Xmas-trees

var Nx_F integer >= 0;

# Declare: present value of Subsea-CapEx

var PVsc >= 0; # unit: Mill. NOK



# Declare: maximum production rates of the field

var qo_F_hat >= 0; # unit: sm3/d

var qg_F_hat >= 0; # unit: 1000 sm3/d

var qw_F_hat >= 0; # unit: sm3/d

# Declare: present value of Topside-CapEx

var PVtc >= 0; # unit: Mill. NOK



# Declare: present value of all expenditures that are made prior to the first oil date, i.e., at 1st Jan 2023

var PVap >= 0; # unit: Mill. NOK



# Declare: present value of OpEx made at time-(z)

var PVo {z in {2..np}} >= 0; # unit: Mill. NOK



# Declare: present value of revenue obtained at time-(z)

var PVr {z in {2..np}} >= 0; # unit: Mill. NOK



# Declare: present value of cashflow at time-(z)

var DCF {z in P}; # unit: Mill. NOK



# Declare: net present value (NPV)

var NPV; # unit: Mill. NOK






# -------------------------------Section 2-------------------------------
# --------------------------Objective Function---------------------------


# The objective function of the optimization model is maximization of the net present value (NPV). It is important to note that the reference date for NPV calculation is 1st Jan 2019.

maximize eq4_5: NPV;






# -------------------------------Section 3-------------------------------
# ------------------------------Constraints------------------------------


# In this section, we define all constraints involved in the optimization model. All constraints defined in "CASE-1_Model.mod: Section 3" are relevant for this optimization model, except for the one related to the desired plateau rate (eq3_2). Some other constraints that are required for NPV calculation are also defined. A complete explanation of every constraint is provided in the Master Thesis report:
# - sec. 3.1.5 --> Operational Constraints
# - sec. 3.1.6 --> Drilling Constraints
# - sec. 3.1.7 --> Consistency Constraints
# - sec. 3.1.8 --> Integer & Binary constraints
# - sec. 3.1.9 --> Constraints Induced by PWL Approximations
# - sec. 4.1.5 --> Additional Constraints for NPV Calculation




# ------------------------------Section 3.1------------------------------
# ------------------------Operational Constraints------------------------


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




# ------------------------------Section 3.5------------------------------
# --------------Additional Constraints for NPV Calculation---------------


# Define: calculate the present value of ExpEx

subject to eq4_6: PVe = sum{p in {1,2,3,4}} A[p]/(1+d)^(p-1);



# Define: calculate the present value of DrillEx for the pre-drilled wells. DrillEx for the pre-drilled wells is made at 1st Jan 2022.

subject to eq4_7: PVdp = B*Nwt_F[1]/(1+d)^3;

# Define: calculate the present value of DrillEx that is made at time-(z)

subject to eq4_8 {z in {1..(np-1)}}: PVd[z] = B*(Nwt_F[z+1] - Nwt_F[z])/(1+d)^(z+3);



# Define: calculate the present value of AbEx. The last 2 terms in the following equation represent the well P&A cost. These terms are not discounted because the expenditure for well P&A is made at once at 1st Jan 2019.

subject to eq4_9: PVa = (sum{p in {1,2,3,4}} C[p]/(1+d)^(p-1)) + D[1]*Nop_F[np] + D[2]*(Ngi_F[np] + Nwi_F[np]);



# Define: each subsea template has 4 available slots for oil producers. In each reservoir, the total number of oil producers is less than or equal to the available slots (4 * number of subsea templates).

subject to eq4_10a {i in R}: Nop[i,np] <= 4*Nt[i];

# Define: the number of subsea templates in the field is equal to the sum of the number of subsea templates in each reservoir

subject to eq4_10b: Nt_F = sum{i in R} Nt[i];

# Define: each injector is equipped with a subsea Xmas-tree. Therefore, the number of Xmas-trees in the field is equal to the number of all injectors in the field

subject to eq4_11: Nx_F = Ngi_F[np] + Nwi_F[np];

# Define: calculate the present value of Subsea-CapEx. In the following equation, we have "4" in the denominator. It is because the Subsea-CapEx is splitted evenly from 2019 until 2022 (4 years).

subject to eq4_12: PVsc = sum{p in {1,2,3,4}} (E[1]*Nt_F + E[2]*Nx_F)/(4*(1+d)^(p-1));



# Define: the field production rates are always less than or equal to the field maximum production rates 

subject to eq4_13a {z in {2..np}}: qo_F[z] <= qo_F_hat;

subject to eq4_13b {z in {2..np}}: qg_F[z] <= qg_F_hat;

subject to eq4_13c {z in {2..np}}: qw_F[z] <= qw_F_hat;

# Define: calculate the present value of Topside-CapEx. In the following equation, we have "4" in the denominator. It is because the Topside-CapEx is splitted evenly from 2019 until 2022 (4 years).

subject to eq4_14: PVtc = sum{p in {1,2,3,4}} (F[1]*qo_F_hat + F[2]*qg_F_hat + F[3]*qw_F_hat)/(4*(1+d)^(p-1));



# Define: calculate the present value of all expenditures that are made before the field enters the production period, i.e., before 1st Jan 2023.

subject to eq4_15: PVap = PVe + PVdp + PVa + PVsc + PVtc;



# Define: calculate the present value of OpEx made at time-(z). In the cost proxy model, the coefficients G[3], G[4], and G[5] are multiplied to the average production rate of oil, gas, and water, respectively, from time-(z-1) to time-(z). Since we use backward rectangular integration method for computing the cumulatives production, those average production rates are substituted with the production rates at time-(z).

subject to eq4_16 {z in {2..np}}: PVo[z] = (G[1] + G[2]*Nop_F[z-1] + G[3]*qo_F[z] + G[4]*qg_F[z] + G[5]*qw_F[z])/(1+d)^(z+3);



# Define: calculate the present value of revenue obtained at time-(z). In this optimization model, the revenues only come from the sales of oil production.

subject to eq4_17 {z in {2..np}}: PVr[z] = Po*XR*VC*(Np_F[z] - Np_F[z-1])/(1+d)^(z+3);



# Define: calculate the present value of cashflow at time-(z)

subject to eq4_18a: DCF[1] = -PVd[1];

subject to eq4_18b {z in {2..(np-1)}}: DCF[z] = PVr[z] - PVo[z] - PVd[z];

subject to eq4_18c: DCF[np] = PVr[np] - PVo[np];



# Define: calculate the net present value (NPV)

subject to eq4_19: NPV = -PVap + (sum{z in P} DCF[z]);