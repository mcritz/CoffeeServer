# Coffee Server

## Find Coffee with Friends

## Mac Dev Sandbox

### Installation

1. Install and run Postgres. [PostgresApp](https://postgresapp.com) does a great job.
2. Clone this repo
3. Set up the enivronment variables found in `env_example`.
    - Be sure to remember the admin email and password for step 5
    - You can set runtime environment variables by editting Xcode’s project scheme. 
        - Product > Scheme > Edit Scheme. Then go to Run > Arguments > Environment Variables
4. Build and run
5. Explore the API using [RapidAPI for Mac](https://paw.cloud). Open the CoffeeServer.paw file to find various routes. Many routes are admin protected. You’ll need your login info from step 3

On the first run, the super user will be created. You’ll need the super user account to do most create update and delete actions.

## Production Deployment
 
### Prerequisites

0. Some type of constantly internet connected server-like host 
1. ssh into your host server
2. Install git. [Documentation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
3. Install Docker. [Documentation](https://docs.docker.com/engine/install/)
4. Clone this repo into a reasonable directory. Ex: `/home/`


### Configure and Boot the Service Fleet

The entire service fleet (app, database, and Caddy proxy) are configured with the `docker-compose` file.

From the outside in:

A request to your service will first reach Caddy which knows that your server name — say, `CoffeeCoffee.world` — exists and should proxy the request to the app. The app is a Vapor server written in Swift 5.7. It connects to the database which is Postres to save and fetch data.

5. Configure the `Caddyfile`. 
    - Copy the example file `cp Caddyfile-example Caddyfile`
    - Open Caddyfile in your text editor and change the `example.com` domain name to whichever domain you’re using. Note that this doesn’t include the url scheme — just the stuff after `://`.
6. Configure the `.env` file
    - Copy the example file `cp env_example .env`
    - Open `.env` in your text editor and add your values for each value
7. Boot the service
    - If this is the **first run** then you’ll need to build the app image: `docker compose up --build -d`
    - In standard operation `docker compose up -d`
8. Run any migrations
    - If this is the **first run** then you **must** run the database migrations: `docker compose run migrate`
    - There is no effect to run migrations that have already been run
    - The only time you won’t need to run migrations is if you’re *certain* that the data models haven’t changed

### Confirm Service Readiness

At this point the service fleet should be running and connected to the database.

9. Assert that the appropriate docker containers are running.
    - `docker ps` should have three running containers. coffee-server:latest, caddy:XXXX, and postgres:XXXX
10. Assert `/healthcheck` is OK. From inside your ssh session on the server…
    - `curl "http://127.0.0.1:8080/healthcheck"` should have output similiar to: `OK. Database Check: Event count = 0`
11. Assert the service is reachable at your domain. Close your server ssh session and try…
    - `curl "http://EXAMPLE.COM/healthcheck"` should be OK.
12. Finally, assert that [Let’s Encrypt](https://letsencrypt.org) Caddy server is working.
    - `curl "https://EXAMPLE.COM/healthcheck"` should also be OK.

At this point, using a web browser and opening your URL should see the “Coffee”.
