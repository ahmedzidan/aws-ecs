## build and push image to ecr
 - To build the and package this app for use the following step
   - cd to app folder ``cd app``
   - put the correct value for ``SERVICE_NAME`` and ``REG_URL`` in .env file. for example.
   ```
   SERVICE_NAME=nginx
   REG_URL=account_id.dkr.ecr.ap-southeast-1.amazonaws.com/test/
   ``` 
   - Login to docker container registry  
   - build and push image to container registry using ``ant``
   ```
   app_version=v0.0.1 ant
   ``` 
   - if your setup correct you will get a message that say ``BUILD SUCCESSFUL`` 
