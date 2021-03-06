# Initial settings
rm(list = ls())
gc()
sapply(list.files("R", full.names = TRUE, pattern = ".R$"), source)
sapply(list.files("src", full.names = TRUE, pattern = ".cpp$"), Rcpp::sourceCpp)

# 0) DEFAULT EXAMPLE ##########################################################################################
data(meuse.grid, package = "sp")
candi <- meuse.grid[1:1000, 1:2]
nadir <- list(sim = 10, seeds = 1:10)
utopia <- list(user = list(DIST = 0, CORR = 0))
covars <- meuse.grid[1:1000, 5]
schedule <- scheduleSPSANN(
  chains = 1, initial.temperature = 5, x.max = 1540, y.max = 2060, 
  x.min = 0, y.min = 0, cellsize = 40)
set.seed(2001)
res <- optimACDC(
  points = 10, candi = candi, covars = covars, nadir = nadir, use.coords = TRUE, 
  utopia = utopia, schedule = schedule, weights = list(DIST = 1/2, CORR = 1/2))
objSPSANN(res) - objACDC(
  points = res, candi = candi, covars = covars, use.coords = TRUE, nadir = nadir, 
  utopia = utopia, weights = list(DIST = 1/2, CORR = 1/2))

# 1) FACTOR COVARIATES USING THE COORDINATES, WITH USER-DEFINED NADIR #########################################
rm(list = ls())
gc()
sapply(list.files("R", full.names = TRUE, pattern = ".R$"), source)
sapply(list.files("src", full.names = TRUE, pattern = ".cpp$"), Rcpp::sourceCpp)
data(meuse.grid)
candi <- meuse.grid[, 1:2]
nadir <- list(user = list(DIST = 10, CORR = 1))
utopia <- list(user = list(DIST = 0, CORR = 0))
covars <- meuse.grid[, 6:7]
schedule <- scheduleSPSANN(chains = 1, initial.temperature = 1)
set.seed(2001)
res <- optimACDC(
  points = 100, candi = candi, covars = covars, nadir = nadir, use.coords = TRUE, utopia = utopia, 
  schedule = schedule, plotit = TRUE, weights = list(CORR = 1/2, DIST = 1/2))
objSPSANN(res) -
  objACDC(points = res, candi = candi, covars = covars, use.coords = TRUE, nadir = nadir, utopia = utopia,
          weights = list(DIST = 1/2, CORR = 1/2))

# 2) FACTOR COVARIATES USING THE COORDINATES WITH A FEW POINTS ################################################
# Tue 9 Jun: objACDC() does not return the same criterion value if 'iterations = 100'
rm(list = ls())
gc()
sapply(list.files("R", full.names = TRUE, pattern = ".R$"), source)
sapply(list.files("src", full.names = TRUE, pattern = ".cpp$"), Rcpp::sourceCpp)
data(meuse.grid)
candi <- meuse.grid[, 1:2]
covars <- meuse.grid[, 6:7]
nadir <- list(sim = 10, seeds = 1:10)
utopia <- list(user = list(CORR = 0, DIST = 0))
schedule <- scheduleSPSANN(chains = 1, initial.temperature = 1)
set.seed(2001)
res <- optimACDC(
  points = 10, candi = candi, covars = covars, nadir = nadir, use.coords = TRUE, utopia = utopia, 
  schedule = schedule, plotit = TRUE, weights = list(CORR = 1/2, DIST = 1/2))
objSPSANN(res) -
  objACDC(points = res, candi = candi, covars = covars, use.coords = TRUE, nadir = nadir, utopia = utopia,
          weights = list(CORR = 1/2, DIST = 1/2))

# 3) CATEGORICAL COVARIATES WITH MANY COVARIATES AND MANY POINTS ##############################################
rm(list = ls())
gc()
sapply(list.files("R", full.names = TRUE, pattern = ".R$"), source)
sapply(list.files("src", full.names = TRUE, pattern = ".cpp$"), Rcpp::sourceCpp)
data(meuse.grid)
candi <- meuse.grid[, 1:2]
covars <- meuse.grid[, rep(c(6, 7), 10)]
nadir <- list(sim = 10, seeds = 1:10)
utopia <- list(user = list(CORR = 0, DIST = 0))
schedule <- scheduleSPSANN(chains = 1, initial.temperature = 1)
set.seed(2001)
res <- optimACDC(
  points = 500, candi = candi, covars = covars, nadir = nadir, use.coords = TRUE, utopia = utopia, 
  schedule = schedule, plotit = TRUE, weights = list(CORR = 1/2, DIST = 1/2))
objSPSANN(res) -
  objACDC(points = res, candi = candi, covars = covars, use.coords = TRUE, nadir = nadir, utopia = utopia,
          weights = list(DIST = 1/2, CORR = 1/2))

# 4) NUMERIC COVARIATES USING THE COORDINATES, WITH USER-DEFINED NADIR ########################################
rm(list = ls())
gc()
sapply(list.files("R", full.names = TRUE, pattern = ".R$"), source)
sapply(list.files("src", full.names = TRUE, pattern = ".cpp$"), Rcpp::sourceCpp)
data(meuse.grid)
candi <- meuse.grid[, 1:2]
nadir <- list(user = list(DIST = 10, CORR = 1))
utopia <- list(user = list(DIST = 0, CORR = 0))
covars = meuse.grid[, 5]
schedule <- scheduleSPSANN(chains = 1, initial.temperature = 1)
set.seed(2001)
res <- optimACDC(
  points = 100, candi = candi, covars = covars, nadir = nadir, use.coords = TRUE, utopia = utopia, 
  schedule = schedule, plotit = TRUE, weights = list(DIST = 1/2, CORR = 1/2))
objSPSANN(res) -
  objACDC(points = res, candi = candi, covars = covars, nadir = nadir, use.coords = TRUE, utopia = utopia,
          weights = list(CORR = 1/2, DIST = 1/2))

# 5) ADD TEN POINTS TO EXISTING FIXED SAMPLE CONFIGURATION ####################################################
rm(list = ls())
gc()
sapply(list.files("R", full.names = TRUE, pattern = ".R$"), source)
sapply(list.files("src", full.names = TRUE, pattern = ".cpp$"), Rcpp::sourceCpp)
data(meuse.grid)
candi <- meuse.grid[, 1:2]
nadir <- list(user = list(DIST = 10, CORR = 1))
utopia <- list(user = list(DIST = 0, CORR = 0))
covars = meuse.grid[, 5]
schedule <- scheduleSPSANN(chains = 300, initial.temperature = 5)
free <- 10
set.seed(1984)
id <- sample(1:nrow(candi), 40)
fixed <- cbind(id, candi[id, ])
objACDC(points = fixed, candi = candi, covars = covars, nadir = nadir, use.coords = TRUE, utopia = utopia,
        weights = list(CORR = 1/2, DIST = 1/2))
set.seed(2001)
res <- optimACDC(
  points = list(free = free, fixed = fixed), candi = candi, covars = covars, nadir = nadir, use.coords = TRUE,
  utopia = utopia, schedule = schedule, plotit = TRUE, weights = list(CORR = 1/2, DIST = 1/2))
objSPSANN(res) -
  objACDC(points = res, candi = candi, covars = covars, nadir = nadir, use.coords = TRUE, utopia = utopia,
          weights = list(CORR = 1/2, DIST = 1/2))
