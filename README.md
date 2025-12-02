# Coffee Server

## Find Coffee with Friends

##  Dev Sandbox

### Installation

1. Install and run Postgres. [PostgresApp](https://postgresapp.com) does a great job.
2. Clone this repo
3. Set up the enivronment variables found in `env_example`.
    - Be sure to remember the admin email and password for step 5
    - Xcode: You can set runtime environment variables by editting Xcode’s project scheme. 
        - Product > Scheme > Edit Scheme. Then go to Run > Arguments > Environment Variables
    - Visual Studio Code: You can set the runtime environment variables by editting the `.vscode/launch.json`
    - macOS: Note that by default Postgres will use your macOS login name as the database name and have no password
4. Build and run
5. Explore the API using [RapidAPI for Mac](https://paw.cloud). 
    - Open the CoffeeServer.paw file to find various routes. Many routes are admin protected. You’ll need your login info from step 3. 
    - Be sure your RapidAPI Environment is using values from Step 3.

On the first run, the super user will be created using the values from Step 3. You’ll need the super user account to do most create update and delete actions.

## Production Deployment
 
### Prerequisites

0. Some type of constantly internet connected server-like host 
1. ssh into your host server
2. Install git. [Documentation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
3. Install Docker. [Documentation](https://docs.docker.com/engine/install/)
4. Clone this repo into a reasonable directory. Ex: `/home/`


### Configure and Boot the Service Fleet

The entire service fleet (app, database, and Caddy proxy) are configured with the `docker-compose` file.

#### Service Fleet Overview

From the outside in:

A request to your service will first reach Caddy which knows that your server name — say, `https://CoffeeCoffee.world` — exists and should proxy the request to the app. Caddy also handles https. The app is a Vapor server written in Swift. It connects to the database which is Postres to save and fetch data.

#### Configuration

5. Configure the `Caddyfile`. 
    - Copy the example file `cp Caddyfile-example Caddyfile`
    - Open Caddyfile in your text editor and change the `example.com` domain name to whichever domain you’re using. Note that this doesn’t include the url scheme — just the stuff after `://`.
6. Configure the `.env` file
    - Copy the example file `cp env_example .env`
    - Open `.env` in your text editor and add your values for each value
    
<span id="naive">Now... let’s run the service.</span>
#### Naive Deployment
Please see [Containerization](#containerization) section for more complete deployment instructions.

7. Boot the service
    - If this is the **first run** then you’ll need to build the app image: `docker compose up --build -d`
        - If the build fails for any reason, you can build on your local machine and push to docker hub. Your dev sandbox is also likely a great deal faster than a typical web host.
    - In standard operation `docker compose up -d`
8. Run any migrations
    - If this is the **first run** then you **must** run the database migrations: `docker compose run migrate`
    - Running migrations more than once will have no negative effect
    - The only time you won’t need to run migrations is if you’re *certain* that the data models haven’t changed

### Confirm Service Readiness

At this point the service fleet should be running and connected to the database.

9. Assert that the appropriate docker containers are running.
    - `docker ps` should have three running containers. coffee-server:latest, caddy:XXXX, and postgres:XXXX
10. Assert `/healthcheck` is OK. From inside your ssh session on the server…
    - `curl "http://127.0.0.1:8080/healthcheck"` should have output similiar to: `OK. Database Check: Event count = 0`
11. Assert the service is reachable at your domain. Close your server ssh session and try…
    - `curl "http://EXAMPLE.COM/healthcheck"` should be OK.
12. Finally, assert that https is working.
    - `curl "https://EXAMPLE.COM/healthcheck"` should also be OK.

At this point, using a web browser and opening your URL should see the “Coffee”.

<span id="containerizaion">Next... containerization</section>
### Containerization

I (@mcritz) deploy the service using OCI files built on a dev box a deployed to a container registry. I use GitHub, modify as needed for your needs.

First, be sure to log in to your container registry.

```bash
echo $LOGIN_TOKEN_VAR | docker login ghcr.io -u YOUR_USERNAME --password-stdin
```

build and push image script:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/mcritz/coffee-server:XX.XX.XX \
  -t ghcr.io/mcritz/coffee-server:latest \
  --push .
``` 

Of course, this can be altered for your favorite container registry (DockerHub, Amazon ECR, your Raspberry Pi, etc).

### Deployment

Once the Docker file is built and the image pushed, it’s just a matter of pulling the images on the production servers. **Run the following command instead of [Step 7](#naive)**. Feel free to use the exact same images I push to GitHub or create your own docker-compose.prod.yml file.

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml pull
```
I build images for linux/amd64 and linux/arm64 so, it should cover the most popular instruction sets available today.
