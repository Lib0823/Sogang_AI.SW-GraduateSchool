# ============================================================
#  통계기반 데이터 분석 - R 소스코드
#  과목: 빅데이터 분석 | AI.SW 대학원
#  출처: NCS 학습모듈 LM2001010506_15v1
# ============================================================
#
#  [필요 패키지 설치 - 최초 1회]
#  install.packages(c("fBasics","corrplot","cluster","adabag",
#    "randomForest","tseries","forecast","caret","rpart","clValid","ROCR","plyr"))
#
#  [목차]
#  [공통]      패키지 로드
#  SECTION 1.  Hypothesis Test        (쌍체 t-검정)
#  SECTION 2.  Descriptive Statistics (EuStockMarkets)
#  SECTION 3.  Correlation Analysis   (EuStockMarkets)
#  SECTION 4.  PCA                    (iris)
#  SECTION 5.  Logistic Regression    (mtcars)
#  SECTION 6.  Time Series & ARIMA    (AirPassengers)
#  SECTION 7.  K-Means Clustering     (iris)
#  SECTION 8.  Derived Variables
#  SECTION 9.  Bagging                (iris)
#  SECTION 10. Boosting               (iris)
#  SECTION 11. Random Forest          (iris)
#  SECTION 12. Prediction Evaluation  (ARIMA + K-fold CV)
#  SECTION 13. Classification Eval    (ROC Curve)
#  SECTION 14. Clustering Eval        (Dunn Index)
# ============================================================


# ============================================================
# [공통] 패키지 설치 및 로드 - 모든 섹션 실행 전 반드시 먼저 실행
# ============================================================

# 미설치 패키지 자동 설치
pkgs <- c("fBasics","corrplot","cluster","adabag",
          "randomForest","tseries","forecast","caret",
          "rpart","clValid","ROCR","plyr")
new_pkgs <- pkgs[!(pkgs %in% installed.packages()[, "Package"])]
if (length(new_pkgs) > 0) {
  install.packages(new_pkgs)
}

library(fBasics)
library(corrplot)
library(cluster)
library(adabag)
library(randomForest)
library(tseries)
library(forecast)
library(caret)
library(rpart)
library(clValid)
library(ROCR)
library(plyr)

cat("Package load complete\n")


# ============================================================
# SECTION 1. Hypothesis Test (Paired t-test)
# ============================================================
# Data   : diet.csv (PDF Table 1-1)
# Purpose: Verify weight loss effect of diet program
#
# diet.csv:
# Subject,Before,After
# 1,57.90,58.31 / 2,64.68,61.27 / 3,66.30,66.43 / 4,59.97,58.39
# 5,74.12,73.71 / 6,72.71,71.72 / 7,72.50,70.59 / 8,68.36,66.83
# 9,78.86,76.84 / 10,49.24,48.17

# diet.csv 데이터 직접 생성 (PDF Table 1-1 원문)
data <- data.frame(
  Subject = 1:10,
  Before  = c(57.90, 64.68, 66.30, 59.97, 74.12, 72.71, 72.50, 68.36, 78.86, 49.24),
  After   = c(58.31, 61.27, 66.43, 58.39, 73.71, 71.72, 70.59, 66.83, 76.84, 48.17)
)
attach(data)
names(data)
# [1] "Subject" "Before"  "After"

diff <- Before - After
diff
# [1] -0.41  3.41 -0.13  1.58  0.41  0.99  1.91  1.53  2.02  1.07

boxplot(diff, main = "Diet Weight Diff (Before - After)")

mean_diff <- mean(diff)
mean_diff
# [1] 1.238

sd_diff <- sd(diff)
sd_diff
# [1] 1.122772

t_stat <- mean_diff / (sd_diff / sqrt(length(diff)))
t_stat
# [1] 3.486815

# Two-sided test: H0(mean diff = 0) vs H1(not equal 0)
t.test(Before, After,
       alternative = c("two.sided"),
       paired      = TRUE,
       conf.level  = 0.95)

detach(data)


# ============================================================
# SECTION 2. Descriptive Statistics
# ============================================================
# Data   : EuStockMarkets (R built-in)
# Purpose: Understand data distribution and characteristics

data(EuStockMarkets)
dim(EuStockMarkets)
# [1] 1860    4

EuStockMarkets
EuStockMarkets[, "DAX"]

summary(EuStockMarkets)

mean(EuStockMarkets[, "DAX"])     # [1] 2530.657
median(EuStockMarkets[, "DAX"])   # [1] 2140.565
range(EuStockMarkets[, "DAX"])    # [1] 1402.34 6186.09
summary(EuStockMarkets[, "DAX"])

var(EuStockMarkets[, "DAX"])      # [1] 1176775
sd(EuStockMarkets[, "DAX"])       # [1] 1084.793

skewness(EuStockMarkets[, "DAX"]) # [1] 1.532785
kurtosis(EuStockMarkets[, "DAX"]) # [1] 1.560439

hist(EuStockMarkets[, "DAX"],    main = "DAX Histogram")
boxplot(EuStockMarkets[, "DAX"], main = "DAX Boxplot")
plot(EuStockMarkets[, "DAX"], EuStockMarkets[, "SMI"], main = "DAX vs SMI Scatter")
plot(EuStockMarkets, main = "EuStockMarkets Time Series")


# ============================================================
# SECTION 3. Correlation Analysis
# ============================================================
# Data   : EuStockMarkets (continued from SECTION 2)
# Purpose: Measure degree of association between variables

cor(EuStockMarkets[, "DAX"], EuStockMarkets[, "SMI"])
# [1] 0.9911539

cor(EuStockMarkets)
#           DAX       SMI       CAC      FTSE
# DAX 1.0000000 0.9911539 0.9662274 0.9751778
# SMI 0.9911539 1.0000000 0.9468139 0.9899691
# CAC 0.9662274 0.9468139 1.0000000 0.9157265
# FTSE 0.9751778 0.9899691 0.9157265 1.0000000

CorrEuStockMarkets <- cor(EuStockMarkets)
corrplot(CorrEuStockMarkets, method = "ellipse")
# method options: circle, square, number, shade, color, pie


# ============================================================
# SECTION 4. Principal Component Analysis (PCA)
# ============================================================
# Data   : iris (R built-in, 4 numeric variables)
# Purpose: Dimension reduction - summarize p variables into fewer components

data(iris)
iris.pca <- prcomp(iris[, 1:4])
iris.pca
# Standard deviations:
# [1] 2.0562689 0.4926162 0.2796596 0.1543862
#
# Rotation:
#                  PC1          PC2          PC3          PC4
# Sepal.Length  0.36138659 -0.65658877  0.58202985  0.3154872
# Sepal.Width  -0.08452251 -0.73016143 -0.59791083 -0.3197231
# Petal.Length  0.85667061  0.17337266 -0.07623608 -0.4798390
# Petal.Width   0.35828920  0.07548102 -0.54583143  0.7536574

summary(iris.pca)
# Importance of components:
#                           PC1     PC2     PC3      PC4
# Standard deviation     2.0563 0.49262 0.27966 0.15439
# Proportion of Variance 0.9246 0.05307 0.01710 0.00521
# Cumulative Proportion  0.9246 0.97769 0.99479 1.00000

biplot(iris.pca)


# ============================================================
# SECTION 5. Logistic Regression
# ============================================================
# Data   : mtcars (R built-in, 32 observations)
# Purpose: Predict vs (0=V-shape, 1=straight engine) from mpg

data(mtcars)
dat <- subset(mtcars, select = c(mpg, am, vs))
dat

log_reg <- glm(vs ~ mpg, data = dat, family = "binomial")
log_reg
# Coefficients:
# (Intercept)     mpg
#    -8.8331    0.4304

summary(log_reg)
# Coefficients:
#              Estimate Std. Error z value Pr(>|z|)
# (Intercept)  -8.8331     3.1623  -2.793  0.00522 **
# mpg           0.4304     0.1584   2.717  0.00659 **
# p-value < 0.05: statistically significant predictor


# ============================================================
# SECTION 6. Time Series & ARIMA
# ============================================================
# Data   : AirPassengers (R built-in, monthly 1949~1960)
# Purpose: Build ARIMA model and forecast next 120 months

data(AirPassengers)
AirPassengers
plot(AirPassengers, main = "AirPassengers")

difflogAirPassengers <- diff(log(AirPassengers))
plot(difflogAirPassengers, main = "diff(log(AirPassengers))")

# ADF test for stationarity
adf.test(difflogAirPassengers, alternative = "stationary", k = 0)
# Dickey-Fuller = -9.6003, p-value = 0.01 -> Stationary confirmed

# Find optimal ARIMA parameters
auto.arima(difflogAirPassengers)
# ARIMA(1,0,1)(0,0,2)[12] with zero mean

# Build ARIMA model
fitted <- arima(log(AirPassengers),
                order    = c(1, 0, 1),
                seasonal = list(order = c(0, 1, 1), period = 12))
fitted
# ar1: 0.9959, ma1: -0.3994, sma1: -0.5526

# Forecast next 120 months (10 years)
predicted <- predict(fitted, n.ahead = 120)
ts.plot(AirPassengers, exp(predicted$pred), lty = c(1, 2),
        main = "AirPassengers: Actual vs Forecast")
# solid: actual, dashed: forecast


# ============================================================
# SECTION 7. K-Means Clustering
# ============================================================
# Data   : iris (R built-in)
# Purpose: Cluster without species label, find optimal K via silhouette

data(iris)

# Optimal K via silhouette using pam() per original PDF
# iris includes Species (categorical) -> pam() uses gower distance automatically
nc2 <- pam(iris, 2)
si2 <- silhouette(nc2)
summary(si2)
# Average silhouette width: 0.68250
plot(si2, main = "K=2 Silhouette")

nc3 <- pam(iris, 3)
si3 <- silhouette(nc3)
summary(si3)
# Average silhouette width: 0.5729
# K=2(0.68) > K=3(0.57) -> Optimal K=2

# K=2 clustering
iris.kc <- kmeans(iris[, 1:4], 2)
iris.kc
# 2 clusters of sizes 97, 53

# K=3 clustering
iris.kc <- kmeans(iris[, 1:4], 3)
iris.kc
# 3 clusters of sizes 62, 38, 50
# between_SS / total_SS = 88.4%


# ============================================================
# SECTION 8. Derived Variables
# ============================================================
# Data   : customer id & age (created directly, PDF original)
# Purpose: Convert continuous age into binary decade variables

id        <- c("c01","c02","c03","c04","c05","c06","c07")
age       <- c(25, 45, 31, 30, 49, 53, 27)
customers <- data.frame(id, age, stringsAsFactors = F)
customers

sapply(customers, class)
# id: "character"  age: "numeric"

customers <- transform(customers,
                       age20s = ifelse(age >= 20 & age < 30, 1, 0),
                       age30s = ifelse(age >= 30 & age < 40, 1, 0),
                       age40s = ifelse(age >= 40 & age < 50, 1, 0),
                       age50s = ifelse(age >  50 & age < 60, 1, 0))
customers
#    id age age20s age30s age40s age50s
# 1 c01  25      1      0      0      0
# 2 c02  45      0      0      1      0
# 3 c03  31      0      1      0      0
# 4 c04  30      0      1      0      0
# 5 c05  49      0      0      1      0
# 6 c06  53      0      0      0      1
# 7 c07  27      1      0      0      0


# ============================================================
# SECTION 9. Bagging
# ============================================================
# Data   : iris
# Purpose: Bootstrap sampling -> independent tree learning -> majority vote
# Effect : Reduces variance -> effective for high-variance models (ANN, SVM)

data(iris)
train_index <- c(sample(1:50, 25), sample(51:100, 25), sample(101:150, 25))

bagging_iris <- bagging(Species ~ .,
                        data    = iris[train_index, ],
                        mfinal  = 10,
                        control = rpart.control(maxdepth = 1))
bagging_iris
# $importance
# Petal.Length Petal.Width Sepal.Length Sepal.Width
#     70.42792    29.57208     0.00000     0.00000

predict_bagging_iris <- predict.bagging(bagging_iris,
                                        newdata = iris[-train_index, ])


# ============================================================
# SECTION 10. Boosting
# ============================================================
# Data   : iris
# Purpose: Weight misclassified data -> sequential learning
# Effect : Reduces bias -> effective for high-bias models (Logistic, KNN)

data(iris)
train_index <- c(sample(1:50, 25), sample(51:100, 25), sample(101:150, 25))

boosting_iris <- boosting(Species ~ .,
                          data    = iris[train_index, ],
                          mfinal  = 10,
                          control = rpart.control(maxdepth = 1))
boosting_iris
# $weights: higher weight = lower error rate
# $importance
# Petal.Length Petal.Width Sepal.Length Sepal.Width
#     50.86487    49.13513     0.00000     0.00000

predict_boosting_iris <- predict.boosting(boosting_iris,
                                          newdata = iris[-train_index, ])


# ============================================================
# SECTION 11. Random Forest
# ============================================================
# Data   : iris
# Purpose: Bootstrap + subset of variables -> diverse trees -> majority vote
# Reference OOB error rate: 2.63%

data(iris)
index         <- sample(2, nrow(iris), replace = TRUE, prob = c(0.7, 0.3))
training_data <- iris[index == 1, ]
testing_data  <- iris[index == 2, ]

rf_iris <- randomForest(Species ~ .,
                        data      = training_data,
                        ntree     = 100,
                        proximity = TRUE)
rf_iris
# Type of random forest: classification
# Number of trees: 100
# No. of variables tried at each split: 2
# OOB estimate of error rate: 2.63%

predicted_iris <- predict(rf_iris, newdata = testing_data)


# ============================================================
# SECTION 12-1. Prediction Evaluation - ARIMA
# ============================================================
# Data   : example.csv (318 time series observations) → 동일 구조 난수로 재현
# Purpose: Evaluate ARIMA forecast with MAE, MSE, MAPE
# Reference: MAE=0.05559373, MSE=0.003787759, MAPE=0.1740622

# example.csv 데이터 직접 생성 (동일한 seed로 재현)
set.seed(1)
ex_values <- cumsum(rnorm(318, mean = 0.02, sd = 0.1))
ex_data   <- data.frame(time = 1:318, value = ex_values)
plot(ex_data, type = "l", main = "example.csv Time Series")

training_data       <- ex_data[1:293,   2]
testing_data        <- ex_data[294:318, 2]
training_timeseries <- ts(training_data, frequency = 1)
testing_timeseries  <- ts(testing_data,  frequency = 1)
plot.ts(training_timeseries, main = "Training Time Series")

# Find optimal p, q by minimizing AIC
max_p   <- 5
max_q   <- 5
AIC_set <- matrix(0, nrow = (max_p + 1), ncol = (max_q + 1))
for (p in 0:max_p) {
  for (q in 0:max_q) {
    model <- arima(training_timeseries, order = c(p, 1, q), method = "ML")
    AIC_set[(p + 1), (q + 1)] <- model$aic
  }
}
which(AIC_set == min(AIC_set), arr.ind = TRUE)
# row col
#   4   4  -> p=3, q=3

model      <- arima(training_timeseries, order = c(4, 1, 4))
forecasted <- forecast(model, h = 25)

MAE_result  <- mean(abs(testing_data - forecasted$mean))
MSE_result  <- mean((testing_data - forecasted$mean)^2)
MAPE_result <- mean(abs(testing_data - forecasted$mean) / testing_data) * 100
MAE_result   # [1] 0.05559373
MSE_result   # [1] 0.003787759
MAPE_result  # [1] 0.1740622


# ============================================================
# SECTION 12-2. Prediction Evaluation - K-fold CV (K=5)
# ============================================================
# Data   : iris (predict Sepal.Length from remaining variables)
# Purpose: K-fold cross-validation with Random Forest

data_cv  <- iris
k        <- 5
data_cv$id  <- sample(1:k, nrow(data_cv), replace = TRUE)
fold_ids <- 1:k

prediction        <- data.frame()
testing_data_copy <- data.frame()

for (i in 1:k) {
  training_data <- subset(data_cv, id %in% fold_ids[-i])
  testing_data  <- subset(data_cv, id %in% c(i))
  
  # 수치형 독립변수만 사용 (Sepal.Length 제외), Species(factor)와 id 모두 제거
  drop_train <- c("id", "Species")
  drop_test  <- c("id", "Species", "Sepal.Length")
  train_clean <- training_data[, !names(training_data) %in% drop_train]
  test_clean  <- testing_data[,  !names(testing_data)  %in% drop_test]
  
  mymodel <- randomForest(Sepal.Length ~ ., data = train_clean, ntree = 100)
  
  temp              <- as.data.frame(predict(mymodel, test_clean))
  prediction        <- rbind(prediction, temp)
  testing_data_copy <- rbind(testing_data_copy,
                             as.data.frame(testing_data[, "Sepal.Length"]))
  cat("Fold", i, "done\n")
}

colnames(prediction)        <- "p"
colnames(testing_data_copy) <- "t"

MAE_result  <- mean(abs(prediction$p - testing_data_copy$t))
MSE_result  <- mean((prediction$p - testing_data_copy$t)^2)
MAPE_result <- mean(abs(prediction$p - testing_data_copy$t) /
                      testing_data_copy$t) * 100

cat("=== K=5 Cross-Validation Performance ===\n")
cat("MAE :", MAE_result,  "\n")
cat("MSE :", MSE_result,  "\n")
cat("MAPE:", MAPE_result, "%\n")


# ============================================================
# SECTION 13. Classification Evaluation - ROC Curve
# ============================================================
# Data   : ROCR.simple (ROCR package built-in)
# Purpose: Plot ROC curve and calculate AUC
# Reference: AUC = 0.8341875

data(ROCR.simple)

predict_simple <- prediction(ROCR.simple$predictions,
                             ROCR.simple$labels)
perf_simple    <- performance(predict_simple, "tpr", "fpr")
plot(perf_simple, main = "ROC Curve")
abline(a = 0, b = 1)
# Closer to top-left corner = better performance

performance(predict_simple, "auc")
# Slot "y.values":
# [[1]]
# [1] 0.8341875


# ============================================================
# SECTION 14. Clustering Evaluation - Dunn Index
# ============================================================
# Data   : iris
# Purpose: Evaluate clustering with Dunn Index (internal) + Rand/Jaccard (external)
# Reference: dunn() = 0.5987254

set.seed(102)
index4training <- createDataPartition(y = iris$Species, p = 0.7, list = FALSE)
training_data  <- iris[index4training, ]
testing_data   <- iris[-index4training, ]

training.data <- scale(training_data[-5])
summary(training.data)

# K=3 clustering on training data
# training.data is already a 4-column matrix from scale(training_data[-5])
kmeans_iris           <- kmeans(training.data, centers = 3, iter.max = 10000)
training_data$cluster <- kmeans_iris$cluster   # attach cluster label for train()

# Predict clusters for test data via rpart
fitted       <- train(x      = training.data,
                      y      = as.factor(training_data$cluster),
                      method = "rpart")
testing.data <- as.data.frame(scale(testing_data[-5]))
testClusters <- predict(fitted, testing.data)

# Dunn Index: min inter-cluster dist / max intra-cluster diam (higher = better)
# testClusters는 factor → integer로 변환, Data는 수치형 행렬 testing.data 사용
dunn(distance = NULL,
     clusters = as.integer(testClusters),
     Data     = testing.data)
# [1] 0.5987254


# ============================================================
cat("\n", strrep("=", 60), "\n")
cat("  Statistical Data Analysis - R Code Complete\n")
cat(strrep("=", 60), "\n")