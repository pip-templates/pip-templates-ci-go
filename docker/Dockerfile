# Start with the scratch image
FROM scratch

# Set a working directory
WORKDIR /app

# Copy the entire project
COPY ./dist ./bin
COPY ./config ./config

# Set environment variables
ENV HTTP_PORT=8080
ENV GRPC_PORT=8090
#ENV MONGO_SERVICE_HOST=
ENV MONGO_SERVICE_PORT=27017

# Expose the port
EXPOSE "8080:8080"
EXPOSE "8090:8090"

# Specify the command to run
CMD ["./bin/run"]
