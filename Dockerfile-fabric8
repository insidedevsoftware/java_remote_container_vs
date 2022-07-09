FROM openjdk:jre

ADD target/*.jar /opt/App.jar
ADD target/docker-extra/run-java/run-java.sh /opt

# See https://github.com/fabric8io-images/run-java-sh/ for more information
# about run-java.sh
#CMD JAVA_MAIN_CLASS=com.mycompany.app.App sh java -jar /opt/App.jar
CMD JAVA_MAIN_CLASS=com.mycompany.app.App sh /opt/run-java.sh
