# run this script from spark cluster with: spark-submit --master local spark_app.py

from pyspark import SparkContext

def main():

   sc = SparkContext(appName='SparkWordCount')

   input_file = sc.textFile('hdfs://namenode:9000/input/input.txt')
   counts = input_file.flatMap(lambda line: line.split()) \
                     .map(lambda word: (word, 1)) \
                     .reduceByKey(lambda a, b: a + b)
   counts.saveAsTextFile('hdfs://namenode:9000/user/hduser/output')

   sc.stop()

if __name__ == '__main__':
   main()
