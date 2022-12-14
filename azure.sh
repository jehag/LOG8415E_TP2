### connect to Azure VM ### (on local)
# ssh -i C://Users//gh0st//Documents//8415//vm1_key.pem azureuser@20.55.2.103

### install java ###
sudo apt update
sudo apt-get -y install default-jdk default-jre
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

### install hadoop ###
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
tar -xvzf hadoop-3.3.1.tar.gz
rm hadoop-3.3.1.tar.gz
sudo mv hadoop-3.3.1 /usr/local/hadoop
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:/usr/local/hadoop/sbin:/usr/local/hadoop/bin

### fetch pg4300.txt ###
hdfs dfs -mkdir input
wget --header="Accept-encoding: *" -O pg4300.txt.gz https://www.gutenberg.org/cache/epub/4300/pg4300.txt
gzip -d pg4300.txt.gz
hdfs dfs -copyFromLocal pg4300.txt input
rm pg4300.txt

### run hadoop wordcount on pg4300.txt ###
time hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.1.jar wordcount input output 
hdfs dfs -rm -r output/

# real    0m4.291s
# user    0m7.756s
# sys     0m0.390s

# real    0m5.442s
# user    0m8.571s
# sys     0m0.281s

# real    0m5.422s
# user    0m8.474s
# sys     0m0.286s

### run linux wordcount on pg4300.txt ###
time cat input/pg4300.txt | tr ' ' '\n' | sort | uniq -c ;

# real    0m0.724s
# user    0m0.367s
# sys     0m0.311s

# real    0m0.637s
# user    0m0.383s
# sys     0m0.272s

# real    0m0.674s
# user    0m0.366s
# sys     0m0.301s

### install pyspark ###
wget https://dlcdn.apache.org/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz
tar -xvzf spark-3.3.1-bin-hadoop3.tgz
rm spark-3.3.1-bin-hadoop3.tgz
sudo mv spark-3.3.1-bin-hadoop3 /opt/spark
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=/usr/bin/python3

### copy pyspark_wordcount.py ###
echo 'import sys
 
from pyspark import SparkContext, SparkConf
 
if __name__ == "__main__":
    if len(sys.argv) == 3:
        # create Spark context with necessary configuration
        sc = SparkContext("local","PySpark Word Count Exmaple")

        # read data from text file and split each line into words
        words = sc.textFile(sys.argv[1]).flatMap(lambda line: line.split(" "))

        # count the occurrence of each word
        wordCounts = words.map(lambda word: (word, 1)).reduceByKey(lambda a,b:a +b)

        # save the counts to output
        wordCounts.saveAsTextFile(sys.argv[2])
    else:
        print("Usage: {} <input> <output>".format(sys.argv[0]), file=sys.stderr)' > pyspark_wordcount.py

### run pyspark wordcount on pg4300.txt ###
time spark-submit pyspark_wordcount.py input output
hdfs dfs -rm -r output/

# real    0m8.961s
# user    0m14.795s
# sys     0m0.647s

# real    0m8.963s
# user    0m14.787s
# sys     0m0.639s

# real    0m9.152s
# user    0m15.189s
# sys     0m0.635s

### copy urls.txt ###
echo 'https://tinyurl.com/4vxdw3pa
https://tinyurl.com/kh9excea
https://tinyurl.com/dybs9bnk
https://tinyurl.com/datumz6m
https://tinyurl.com/j4j4xdw6
https://tinyurl.com/ym8s5fm4
https://tinyurl.com/2h6a75nk
https://tinyurl.com/vwvram8
https://tinyurl.com/weh83uyn' > urls.txt

### fetch tinyurls ###
hdfs dfs -mkdir all_input
wget -P all_input -i urls.txt

### run hadoop wordcount on tinyurls ###
time hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.1.jar wordcount all_input all_output
hdfs dfs -rm -r all_output/

# real    0m5.278s
# user    0m8.672s
# sys     0m0.324s

# real    0m5.319s
# user    0m9.318s
# sys     0m0.382s

# real    0m5.329s
# user    0m9.105s
# sys     0m0.367s

### run spark wordcount on tinyurls ###
time spark-submit pyspark_wordcount.py all_input all_output
hdfs dfs -rm -r all_output/

# real    0m10.848s
# user    0m18.058s
# sys     0m0.843s

# real    0m10.806s
# user    0m17.834s
# sys     0m0.857s

# real    0m11.073s
# user    0m18.411s
# sys     0m0.797s

### fetch friends lists ###
hdfs dfs -mkdir recommendations_input
mv soc-LiveJournal1Adj.txt recommendations_input/

### run pyspark recommendations on friends lists ###
time spark-submit pyspark_recommendations.py recommendations_input recommendations_output
hdfs dfs -rm -r all_output/
