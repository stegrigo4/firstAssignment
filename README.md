# First Assignment

This is a really "simple" project that uses 3 technologies:
- ```Nginx Webserver```
- ```PHP-FPM```
- ```MYSQL 9```
All of these are containerized, ```Nginx``` and ```PHP``` are together, and ```MySQL``` has a container for itself. All of these have been brought together using ```Docker Compose```. The first issue i have come across are the complicated configuration files, especially for ```PHP``` as it has a default configuration called ```clear_env``` that breaks the environment variables necessary to connect from the webserver to the database.
```
[www]
user = nobody
group = nobody
listen = 127.0.0.1:9000
clear_env = no
...
```
## Configuration files
Once the configuration files have been sorted and the containers have been spun up, the application works as intended, the data is retrieved from the database, and it has the feature of choosing a certain line or the default option which is the first line.
```
http://localhost:9091/index.php => Hello, Grigo!
http://localhost:9091/index.php?line=1 => Hello, Bianca!
```
## Healthchecks for all containers have been created and they work as intended:
```
MySQL
healthcheck:
    test: ["CMD", "mysqladmin" ,"ping", "-h", "localhost"]

Nginx + PHP
HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
```
```
a7051c50c3cc   test      "/bin/sh -c ./start.…"   12 minutes ago   Up 12 minutes (healthy)   0.0.0.0:9090->80/tcp                test
be3d2bdc7e81   prod      "/bin/sh -c ./start.…"   12 minutes ago   Up 12 minutes (healthy)   0.0.0.0:9091->80/tcp                prod
4dcee2f39739   mysql:9   "docker-entrypoint.s…"   12 minutes ago   Up 12 minutes (healthy)   0.0.0.0:3306->3306/tcp, 33060/tcp   mysql
```
## There were added 3 different Github Workflows:
### Testing
```
name: Testing
on: 
  pull_request:
jobs:
    validate:
    environment: Test
...
    deployment:
      needs: validate
      environment: Test
```
 - which takes care of both ```Nginx``` and ```PHP``` syntax and configuration validation, as well as deployment to the Private VM using ```SSH```
 - it only works when a pull request is ```created```, ```synchronized```, or ```closed``` and it is specific to the ```Test Environment```.
 - all credentials are stored in ```Github Secrets``` based on the ```Environment``` and are only accessible through the ```secrets``` tag from github and stored in local environment variables
```
MYSQL_ROOT_PASSWORD: ${{ secrets.MYSQL_ROOT_PASSWORD }}
MYSQL_DATABASE: ${{ secrets.MYSQL_DATABASE }}
MYSQL_USER: ${{ secrets.MYSQL_USER }}
MYSQL_PASSWORD: ${{ secrets.MYSQL_PASSWORD }}
```

### Backup
 - which takes care of the overnight backup of the database from the deployed application as it fires up at Midnight in Romania or 21:00 UTC
 - the extra stars have different meaning as the first is minutes, then hours, then day of the month, month, and day of the week respectively
 - it makes sure that the artifact that represents the database backup has a retention of 7 days
 - it also makes sure to add the date when the backup has been made for ease of keeping track
```
on:
    schedule:
        - cron: '0 21 * * *'
jobs:
    backup:
        environment: Prod
        ...
        - name: Rename the file
          run: |  
                ssh ${{ secrets.SSH_USER }}@${{ secrets.SSH_HOST }} "cd /home/grigo/backup; ls; mv backup.sql backup_$(date +"%m-%d-%y").sql"
        ... 
        - name: Upload database backup
          uses: actions/upload-artifact@v4
          with:
            name: Database Backup
            path: /home/runner/work/firstAssignment/firstAssignment/backup
            retention-days: 7
```
### Merge to Prod
- which takes care of the code post merging to production, which is release tagging,
- the repository has a file called ```version.txt``` which is updated only in this workflow before being merged again with the main repository to keep accurate track of the  version. It only increments the last number of, for example ```1.0.0``` will become ```1.0.1```, more important releases have to be manually added
- it only works on the ```Production Environment``` and it has a second clause, as it needs to start only after a pull request has been successfully merged
```
name: Merge to Prod
on:
    workflow_run:
        workflows: ["Testing"]
        types: 
            - completed
    pull_request:
        types:
            - closed
jobs:
    echo-if-merged:
        if: github.event.pull_request.merged == true
        runs-on: ubuntu-latest
        environment: Prod
        steps: 
        ...
```
In order to modify the ```version.txt``` file I used a ```bash``` script that copies the content of the folder, separates the numbers into an array, increases the last one, reassembles the number and overwrites the original.
```
#!/bin/bash

version=$(cat version.txt)

IFS='.' read -r -a version_parts <<< "$version"

((version_parts[2]++))

new_version="${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"

echo "$new_version" > version.txt

echo "Updated version: $new_version"
```
### Bad practice that worked
In order to actually spin up the application on the VM correctly i had to do something that's considered bad practice. I copied the secrets from the ```Production Environment``` onto an ```.env``` file that i send to the VM alongside the other code, in order for the application to read the environment variables correctly. I did not look that hard to a better alternative for an isolated VM so i stick with this option.
```
 - name: Copy Secrets into local file
          run: |
            echo "MYSQL_ROOT_PASSWORD=${{ secrets.MYSQL_ROOT_PASSWORD }}" >> /home/runner/work/firstAssignment/firstAssignment/.env
            echo "MYSQL_DATABASE=${{ secrets.MYSQL_DATABASE }}" >> /home/runner/work/firstAssignment/firstAssignment/.env
            echo "MYSQL_USER=${{ secrets.MYSQL_USER }}" >> /home/runner/work/firstAssignment/firstAssignment/.env
            echo "MYSQL_PASSWORD=${{ secrets.MYSQL_PASSWORD }}" >> /home/runner/work/firstAssignment/firstAssignment/.env
```
### The application on the VM doesn't have its port forwarded and a DNS assigned
This is a problem as i can't check on the VM itself to open a browser and check the localhost, or access the application remotely as i could with https://first-assignment.zambeste.ro/
### Registry cleanup and image creation on Dockerhub
I created a ```bash``` script that can create the number of images the user requests and I used the latest tag in the ```Dockerhub repository``` as the base number for the tag. It doesn't use the credentials as i only used it from my ```WSL machine``` but that can be easily added as a prompt for the user to add and. It curls a link where the repository has all its details in ```JSON``` format that can be easily parsed to find the latest image, as it is the first in the stack.
```
LATEST_TAG_PROD=$(curl -s "https://hub.docker.com/v2/repositories/$REPOSITORY_PROD/tags/?page_size=100" | jq -r '.results|.[]|.name'| head -n 1)
...
for ((i = $TEST_TAG_NUMBER; i <= $(($NUMBER_OF_IMAGES+$TEST_TAG_NUMBER)); i++)) do
  NEW_VERSION=$(($TEST_TAG_NUMBER + i))
  NEW_TAG="v$NEW_VERSION"
  echo "Creating new tag: $NEW_TAG"
  
  docker tag $REPOSITORY_TEST:v$TEST_TAG_NUMBER $REPOSITORY_TEST:$NEW_TAG
  
  docker push $REPOSITORY_TEST:$NEW_TAG
done
```
Unfortunately i did not find an automated way to clean up the Dockerhub registry or remove automatically the oldest X images.
## Webhooks to be alerted on Teams
Unfortunately I did not find a way to integrate them with ```Github Webhooks```.