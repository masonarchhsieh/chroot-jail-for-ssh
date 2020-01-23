#!/bin/bash - 
docker build -t debian-ssh-users .

if [ -f "run.sh" ] 2>&1;
then
    rm run.sh
fi
touch run.sh
echo "#!/bin/bash -" > run.sh
echo "docker run -it --rm debian-ssh-users:latest" >> run.sh

if [ -f "deleteImage.sh" ] 2>&1;
then
    rm deleteImage.sh
fi
touch deleteImage.sh
echo "#!/bin/bash -" > deleteImage.sh
echo "docker rmi debian-ssh-users:latest" >> deleteImage.sh
