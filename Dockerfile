# -----------------------------------------------------
# Creates a Docker Image for the Mte-Relay
# from a compiled version of the Relay that
# you downloaded from GitHub and the Mte library
# that you obtained from Eclypses.
# -----------------------------------------------------

# Set a base image for the runtime and install some packages needed by MS.
FROM debian:latest AS runtime-env
RUN apt update
RUN apt install libicu72
RUN apt install libssl3 -y
RUN apt install -y ca-certificates
RUN rm -rf /var/lib/apt/lists/*

# Set up some symlinks for the dynamic loader and the MTE library
RUN ln -fs libdl.so.2 /usr/lib/x86_64-linux-gnu/libdl.so
RUN ln -fs /home/relay/libmte.so /usr/lib/x86_64-linux-gnu/libmte.so

# Create a directory to hold the executable
WORKDIR /home/relay

# Copy the .Net published AOT executable
# and the libmte.so file you got from Eclypses
# from the /eclypses/downloaded folder that you got from GitHub
COPY ./* /home/relay

# Remove the items that are not needed
RUN rm -f *.dbg
RUN rm -f *.log
RUN rm -f appsettings.Development.json

# Create a user to run the app and sign in
RUN useradd -m relay
RUN usermod -aG users relay
USER relay

# Expose the port that the internal Kestrel server is listening on
EXPOSE 8080

# Start the Mte-Relay Server
CMD ["./mte-relay-server"]
