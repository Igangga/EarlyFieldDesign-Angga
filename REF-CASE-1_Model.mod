
# -------------------------------Section 1-------------------------------
# ------------Declaration of Parameters, Sets, and Variables-------------




# ------------------------------Section 1.1------------------------------
# ------------------Declaration of Parameters and Sets-------------------


param nr;

set R := 1..nr;



param np;

set P := 1..np;



param tup;



param qo_F_plateau;



param RM {i in R, z in P};



param Nop {i in R, z in P};

param Nwi {i in R, z in P};

param Ngi {i in R, z in P};



param qgi_pgi_hat;

param qwi_pwi_hat;



param nbp_Np;

set V_Np := 1..nbp_Np;

param nbp_Nop {i in R};

set V_Nop {i in R} := 1..nbp_Nop[i];

param nbp_RM {i in R};

set V_RM {i in R} := 1..nbp_RM[i];



param Np_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};

param Nop_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};

param RMpp_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};

param qopp_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};

param Gp_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};

param Wp_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};

param Gi_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};

param Wi_bar {i in R, j in V_Np, k in V_Nop[i], l in V_RM[i]};




# ------------------------------Section 1.2------------------------------
# -----------------------Declaration of Variables------------------------


var Nop_F {z in P} integer >= 0;

var Ngi_F {z in P} integer >= 0;

var Nwi_F {z in P} integer >= 0;

var Nwt {i in R, z in P} integer >= 0;

var Nwt_F {z in P} integer >= 0;



var qopp {i in R, z in P} >= 0;

var qopp_F {z in P} >= 0;



var qo {i in R, z in {2..np}} >= 0;

var qo_F {z in {2..np}} >= 0;

var qg {i in R, z in {2..np}} >= 0;

var qg_F {z in {2..np}} >= 0;

var qw {i in R, z in {2..np}} >= 0;

var qw_F {z in {2..np}} >= 0;

var qgi {i in R, z in {2..np}} >= 0;

var qgi_F {z in {2..np}} >= 0;

var qwi {i in R, z in {2..np}} >= 0;

var qwi_F {z in {2..np}} >= 0;



var Np {i in R, z in P} >= 0;

var Np_F {z in P} >= 0;

var Gp {i in R, z in P} >= 0;

var Gp_F {z in P} >= 0;

var Wp {i in R, z in P} >= 0;

var Wp_F {z in P} >= 0;

var Gi {i in R, z in P} >= 0;

var Gi_F {z in P} >= 0;

var Wi {i in R, z in P} >= 0;

var Wi_F {z in P} >= 0;



var lambda {i in R, z in P, j in V_Np, k in V_Nop[i]} >= 0;

var eta_Np {i in R, z in P, j in V_Np} >= 0;

var eta_Nop {i in R, z in P, k in V_Nop[i]} >= 0;






# -------------------------------Section 2-------------------------------
# --------------------------Objective Function---------------------------


minimize eq3_1: sum{z in {2..np}} (qo_F_plateau - qo_F[z]);






# -------------------------------Section 3-------------------------------
# ------------------------------Constraints------------------------------




# ------------------------------Section 3.1------------------------------
# ------------------------Operational Constraints------------------------


subject to eq3_2 {z in {2..np}}: qo_F[z] <= qo_F_plateau;



subject to eq3_3a {i in R, z in {2..np}}: qo[i,z] <= qopp[i,z];

subject to eq3_3b {i in R, z in {2..np}}: qo[i,z] <= qopp[i,z-1];



subject to eq3_4a {i in R, z in {2..np}}: qgi[i,z] <= Ngi[i,z-1]*qgi_pgi_hat;

subject to eq3_4b {i in R, z in {2..np}}: qwi[i,z] <= Nwi[i,z-1]*qwi_pwi_hat;




# ------------------------------Section 3.2------------------------------
# ------------------------Consistency Constraints------------------------


subject to eq3_9 {i in R}: Np[i,1] = 0;



subject to eq3_10a {i in R, z in {2..np}}: Np[i,z] = Np[i,z-1] + tup*qo[i,z]/1000000;

subject to eq3_10b {i in R, z in {2..np}}: Gp[i,z] = Gp[i,z-1] + tup*qg[i,z]/1000;

subject to eq3_10c {i in R, z in {2..np}}: Wp[i,z] = Wp[i,z-1] + tup*qw[i,z]/1000000;

subject to eq3_10d {i in R, z in {2..np}}: Gi[i,z] = Gi[i,z-1] + tup*qgi[i,z]/1000;

subject to eq3_10e {i in R, z in {2..np}}: Wi[i,z] = Wi[i,z-1] + tup*qwi[i,z]/1000000;



subject to eq3_11 {i in R, z in P}: Nwt[i,z] = Nop[i,z] + Ngi[i,z] + Nwi[i,z];



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




# ------------------------------Section 3.3------------------------------
# ---------------Constraints Induced by PWL Approximations---------------


subject to eq3_15a {i in R, z in P}: Np[i,z] = sum{j in V_Np, k in V_Nop[i]} lambda[i,z,j,k]*Np_bar[i,j,k,RM[i,z]];

subject to eq3_15b {i in R, z in P}: Nop[i,z] = sum{j in V_Np, k in V_Nop[i]} lambda[i,z,j,k]*Nop_bar[i,j,k,RM[i,z]];

subject to eq3_15d {i in R, z in P}: qopp[i,z] = sum{j in V_Np, k in V_Nop[i]} lambda[i,z,j,k]*qopp_bar[i,j,k,RM[i,z]];

subject to eq3_15e {i in R, z in P}: 1 = sum{j in V_Np, k in V_Nop[i]} lambda[i,z,j,k];

subject to eq3_15f {i in R, z in P, j in V_Np}: eta_Np[i,z,j] = sum{k in V_Nop[i]} lambda[i,z,j,k];

subject to eq3_15g {i in R, z in P, k in V_Nop[i]}: eta_Nop[i,z,k] = sum{j in V_Np} lambda[i,z,j,k];

subject to eq3_16a {i in R, z in P}: Gp[i,z] = sum{j in V_Np, k in V_Nop[i]} lambda[i,z,j,k]*Gp_bar[i,j,k,RM[i,z]];

subject to eq3_16b {i in R, z in P}: Wp[i,z] = sum{j in V_Np, k in V_Nop[i]} lambda[i,z,j,k]*Wp_bar[i,j,k,RM[i,z]];

subject to eq3_16c {i in R, z in P}: Gi[i,z] = sum{j in V_Np, k in V_Nop[i]} lambda[i,z,j,k]*Gi_bar[i,j,k,RM[i,z]];

subject to eq3_16d {i in R, z in P}: Wi[i,z] = sum{j in V_Np, k in V_Nop[i]} lambda[i,z,j,k]*Wi_bar[i,j,k,RM[i,z]];