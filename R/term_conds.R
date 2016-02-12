# Termination conditions.
# Used to evantually stop mbo optimization process

# Each stopping condition is a simple function which expects an opt.state
# and returns a list with the following three components
# * term: logical indicating whether the stopping condition is met.
# * message: String indicating the reason for termination.
# * code: integer code of stopping condition (only for build-in stopping conditions!)

# @title
# Maximum iteration stopping condition.
#
# @param max.iter [integer(1)]
#   Maximum number of iterations.
makeMBOMaxIterTermination = function(max.iter) {
  assertCount(max.iter, na.ok = FALSE, positive = TRUE)
  force(max.iter)
  function(opt.state) {
    iter = getOptStateLoop(opt.state)
    term = iter > max.iter
    message = if (!term) NA_character_ else sprintf("Maximum number of iterations %i reached with.", max.iter, iter)
    return(list(term = term, message = message, code = 1L))
  }
}

# @title
# Time budget stopping condition.
#
# @param time.budget [numeric(1)]
#   Time budget in seconds.
makeMBOMaxBudgetTermination = function(time.budget) {
  assertNumber(time.budget, na.ok = FALSE)
  force(time.budget)
  function(opt.state) {
    time.used = as.numeric(getOptStateTimeUsed(opt.state), units = "secs")
    term = (time.used > time.budget)
    message = if (!term) NA_character_ else sprintf("Time budged %f reached.", time.budget)
    return(list(term = term, message = message, code = 2L))
  }
}

# @title
# Execution time budget stopping condition.
#
# @param time.budget [numeric(1)]
#   Exceution time budget in seconds.
makeMBOMaxExecBudgetTermination = function(time.budget) {
  assertNumber(time.budget, na.ok = FALSE)
  force(time.budget)
  function(opt.state) {
    opt.path = getOptStateOptPath(opt.state)
    time.used = sum(getOptPathExecTimes(opt.path))

    term = (time.used > time.budget)
    message = if (!term) NA_character_ else sprintf("Time budged %f reached.", time.budget)
    return(list(term = term, message = message, code = 3L))
  }
}

# @title
# y-value stopping condition.
#
# @param time.budget [numeric(1)]
#   Traget function value.
#
# @note: only for single-criteria functions.
makeMBOTargetFunValueTermination = function(target.fun.value) {
  assertNumber(target.fun.value, na.ok = FALSE)
  force(target.fun.value)
  function(opt.state) {
    opt.problem = getOptStateOptProblem(opt.state)
    control = getOptProblemControl(opt.problem)
    opt.path = getOptStateOptPath(opt.state)
    opt.dir = if (control$minimize) 1L else -1L
    current.best = getOptPathEl(opt.path, getOptPathBestIndex((opt.path)))$y
    term = (current.best * opt.dir <= target.fun.value * opt.dir)
    message = if (!term) NA_character_ else sprintf("Target function value %f reached.", target.fun.value)
    return(list(term = term, message = message, code = 4L))
  }
}