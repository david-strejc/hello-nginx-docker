# hello-nginx-docker
This repository provides some helper applications and configurations for testing TLS termination in the OpenShift
enviroment.  It is meant for testing purposes only, the certificates contained within this project are not valid.

## Building the docker image
    docker build -t pweil/hello-nginx-docker .

## Verifying the docker image
    docker run pweil/hello-nginx-docker
    docker ps
    docker inspect <container id> | grep IP
    # at this point you need to put a hosts entry in /etc/hosts for the docker container that is being run
    # or you will receive an error from curl that the requested domain does not match the certificate
    curl https://www.example.com:443 --cacert certs/mypersonalca/certs/ca.pem

    Hello World

    # you may also view the certificate being served with openssl
    openssl s_client -connect 172.17.0.13:443 | grep example
    ... lines removed for clarity ...
    subject=/CN=www.example.com/ST=SC/C=US/emailAddress=example@example.com/O=Example/OU=Example
    issuer=/C=US/ST=SC/L=Default City/O=Default Company Ltd/OU=Test CA/CN=www.exampleca.com/emailAddress=example@example.com

## Testing with openshift routing beta1

### UC 1: non ssl enabled application

    # clone openshift and start the vagrant environment
    [pweil@localhost origin]$ vagrant up
    ...
    # enter the vagrant machine
    [pweil@localhost origin]$ vagrant ssh
    Last login: Thu Oct 30 18:18:12 2014 from 10.0.2.2
    [vagrant@openshiftdev ~]$ cd /data/src/github.com/openshift/origin/

    # build the base images (not necessary if they have been pushed to the openshift repository, as of writing they
    # had not been pushed. This step may take a while to download images.
    [vagrant@openshiftdev origin]$ hack/build-base-images.sh

    # build the openshift release and build the openshift images
    [vagrant@openshiftdev origin]$ hack/build-release.sh && hack/build-images.sh

    # add the build path and start openshift.  You can start this in the background or open another window and
    # add the path to your new session as well
    [vagrant@openshiftdev origin]$ export PATH=${ORIGIN_BASE}/_output/local/bin/linux/amd64:$PATH
    [vagrant@openshiftdev origin]$ sudo /data/src/github.com/openshift/origin/_output/local/bin/linux/amd64/openshift start --loglevel=4

    # deploy the router, non-secure pod, service, and route
    [vagrant@openshiftdev origin]$ hack/install-router.sh router 10.0.2.15
    Creating router file and starting pod...
    router
    [vagrant@openshiftdev origin]$ openshift cli get pods
    POD                 CONTAINER(S)                   IMAGE(S)                          HOST                  LABELS              STATUS
    router              origin-haproxy-router-router   openshift/origin-haproxy-router   openshiftdev.local/   <none>              Running

    [vagrant@openshiftdev ~]$ cd
    [vagrant@openshiftdev ~]$ git clone https://github.com/pweil-/hello-nginx-docker.git
    # starting the pod may take a while, it must download the container
    [vagrant@openshiftdev ~]$ openshift cli create -f hello-nginx-docker/openshift/nginx_pod.json pods
    hello-nginx-docker
    [vagrant@openshiftdev ~]$ openshift cli get pods
    POD                  CONTAINER(S)                   IMAGE(S)                          HOST                  LABELS                    STATUS
    router               origin-haproxy-router-router   openshift/origin-haproxy-router   openshiftdev.local/   <none>                    Running
    hello-nginx-docker   hello-nginx-docker-pod         pweil/hello-nginx-docker          openshiftdev.local/   name=hello-nginx-docker   Running

    [vagrant@openshiftdev ~]$ openshift cli create -f hello-nginx-docker/openshift/unsecure/service.json 
    hello-nginx
    [vagrant@openshiftdev ~]$ openshift cli create -f hello-nginx-docker/openshift/unsecure/route.json 
    route-secure
    [vagrant@openshiftdev ~]$ curl -H Host:www.example.com 10.0.2.15
    Hello World


