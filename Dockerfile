# for production, it is not necessary to have a development server
# and the source code is also superfluous
# create 2 stages and reuse only the 'output' of the 1st phase
# which is the built files in the build folder

# add a tag using 'as' to create a stage/layer/temporary container
FROM node:16-alpine as builder

USER node
RUN mkdir -p /home/node/app
WORKDIR '/home/node/app'

COPY  --chown=node:node package.json .
RUN npm install
COPY  --chown=node:node . .
# this step creates the home/node/app/build folder
RUN npm run build

# nginx is a lightweight server for serving up static files and
# routing requests
# the base image automatically starts up the nginx server
# there is no need to set a default command at the end
FROM nginx

# this is just an instructor for the developer that this port should be opened in development
# when running docker run, so in theory it does nothing
# however, ElasticBeanstalk actually uses this port
EXPOSE 80

# copy over files from the given phase: --from=phase
# FROM folder: /home/node/app/build is where the built files are
# TO folder: /usr/share/nginx/html is given in the nginx documentation
# as the folder to use for static files
COPY --chown=node:node --from=builder /home/node/app/build /usr/share/nginx/html