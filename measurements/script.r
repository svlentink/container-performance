
db <- scan("/storage/docker_cli_bash_200.csv", sep=',')
dp <- scan("/storage/docker_cli_python_200.csv", sep=',')
dn <- scan("/storage/docker_cli_node_200.csv", sep=',')
dl <- scan("/storage/docker_server_lamp_200.csv", sep=',')
df <- scan("/storage/docker_fast.csv", sep=',')

drb <- scan("/storage/docker--rm_cli_bash_200.csv", sep=',')
drp <- scan("/storage/docker--rm_cli_python_200.csv", sep=',')
drn <- scan("/storage/docker--rm_cli_node_200.csv", sep=',')

lb <- scan("/storage/lxc_cli_bash_200.csv", sep=',')
lp <- scan("/storage/lxc_cli_python_200.csv", sep=',')
ln <- scan("/storage/lxc_cli_node_200.csv", sep=',')
ll <- scan("/storage/lxc_server_lamp_200.csv", sep=',')
lf <- scan("/storage/lxc_fast.csv", sep=',')

rb <- scan("/storage/rkt_cli_bash_200.csv", sep=',')
rp <- scan("/storage/rkt_cli_python_200.csv", sep=',')
rn <- scan("/storage/rkt_cli_node_200.csv", sep=',')
rl <- scan("/storage/rkt_server_lamp_200.csv", sep=',')
rf <- scan("/storage/rkt_fast.csv", sep=',')

clifr <- data.frame(
  "dkr.sh"=db,
  "rm.sh"=drb,
  "rkt.sh"=rb,
  "LXC.sh"=lb,
  "dkr.py"=dp,
  "rm.py"=drp,
  "rkt.py"=rp,
  "LXC.py"=lp,
  "dkr.js"=dn,
  "rm.js"=drn,
  "rkt.js"=rn,
  "LXC.js"=ln
)
initialfr <- data.frame(
  "dkr"=dl,
  "rkt"=rl,
  "LXC"=ll
)
successivefr <- data.frame(
  "dkr"=df,
  "rkt"=rf,
  "LXC"=lf
)

labels <- c(
  '.sh\ndkr','.sh\n--rm','.sh\nrkt','.sh\nlxc',
  '.py\ndkr','.py\n--rm','.py\nrkt','.py\nlxc',
  '.js\ndkr','.js\n--rm','.js\nrkt','.js\nlxc')
colors <- c(
  'white','white','white','white',
  'gray','gray','gray','gray'
)

jpeg('/storage/cli.jpg')
boxplot(
  db,drb,rb,lb,
  dp,drp,rp,lp,
  dn,drn,rn,ln,
  main="Executing a Bash, Python and Node.js script in a container",
  ylab="Response time in milisec.",
  xlab="1000 measurements for docker, docker with --rm, rkt and LXC",
#  horizontal=TRUE,
#  yaxt="n",
  names=labels )
#axis(2, labels=labels, at=1:12, las=2)
dev.off()


jpeg('/storage/init.jpg')
boxplot(
  dl,rl,ll,
  main="Simulated LAMP stack in starting container",
  ylab="Response time in milisec.",
  xlab="1000 measurements for docker, rkt and LXC",
  names=c('dkr','rkt','lxc') )
dev.off()


jpeg('/storage/succ.jpg')
boxplot(
  df,rf,lf,
  main="Simulated LAMP stack in running container",
  ylab="Response time in milisec.",
  xlab="1000 measurements for docker, rkt and LXC",
  names=c('dkr','rkt','lxc') )
dev.off()


stats <- function(x) round(
  c(
    Mean=mean(x),
    Min=min(x),
    Max=max(x),
    Sd=sd(x),
    Var=var(x),
    Median=median(x),
    Q1=quantile(x, 0.25),
    Q3=quantile(x, 0.75)
  )
)

df_init <- data.frame(lapply(initialfr, stats), check.names = FALSE)
df_cli <- data.frame(lapply(clifr, stats), check.names = FALSE)
df_succ <- data.frame(lapply(successivefr, stats), check.names = FALSE)

write.table(df_init, "/storage/init.md_table", sep="\t|", eol='|\n')
write.table(df_succ, "/storage/succ.md_table", sep="\t|", eol='|\n')
write.table(df_cli, "/storage/cli.md_table", sep="\t|", eol='|\n')

print(df_init)
print(df_succ)
print(df_cli)

