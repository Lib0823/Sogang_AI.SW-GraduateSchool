# 데이터 로드
data <- read.table("age3.txt", header=1)

# 히스토그램
par(mar = c(5, 4, 3, 1))

hist(data$weight[data$gender == 1],
     xlim = c(1500, 4500),
     ylim = c(0, 12),
     col = "red",
     border = NA,
     main = "",
     xlab = "",
     ylab = "",
     axes = F)

hist(data$weight[data$gender == 2],
     add = TRUE,
     col = rgb(0, 1, 0, 0.5),
     border = NA)

axis(1)
axis(2)

abline(v = mean(data$weight[data$gender == 1]), lty = 1, lwd = 1.5, col = "red")
abline(v = mean(data$weight[data$gender == 2]), lty = 1, lwd = 1.5, col = "green")

legends <- c("여아", "남아")
legend("topright",
       legend = legends,
       fill = c("red", "green"),
       density = c(NA, 20))