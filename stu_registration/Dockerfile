# Use Ballerina runtime as the base image
FROM openjdk:17-jdk-slim

# Set the working directory
WORKDIR /home/ballerina

# Copy the Ballerina executable jar into the container
COPY target/bin/stu_registration.jar /home/ballerina/

# Expose the port your Ballerina service is running on
EXPOSE 9000

# Define the command to run your Ballerina service
CMD ["java", "-jar", "stu_registration.jar"]