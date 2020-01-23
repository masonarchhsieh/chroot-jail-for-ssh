# ssh-user
#### Purpose
The main purpose for this project is that we want a shared file system(fs) such that our clients can upload their websites to their directory by connecting the container through the ssh or sftp. However, we don't want them to enter other users' folders or modify the system files. 

Our solution is to implement a "change root(chroot) jail" for the ssh/sftp users([Restrict SSH User Access to Certain Directory Using Chrooted Jail](https://www.tecmint.com/restrict-ssh-user-to-directory-using-chrooted-jail/) ). The chroot jail would restrict a ssh user session to a particular directory. 

(change root (chroot) in Unix-like systems such as Linux, is a means of separating specific user operations from the rest of the Linux system; changes the apparent root directory for the current running user process and its child process with new root directory called a chrooted jail.)

The file system would look like this diagram:
![chroot_jail](http://albertomatus.com/wp-content/uploads/2018/11/alberto-matus-chroot.jpg)

#### To create the docker image from a defined Dockerfile
The folder contains the following scripts:
 - Dockerfile
 - add_chroot_user.sh
 - create_chrooted_jail.sh
 - setup.sh

To build up the docker image, go to the docker folder and build the image. We use debian distribution for our container image. The Dockerfile would install the required software/tools: ansible, vim, and ssh.
```sh
$ cd docker/
$ docker build -t debian-ssh-users
```
or you can just run the setup.sh:
```sh
$ bash setup.sh
```
You should be able to see a docker image, tagged as "debian-ssh-users" right now. The Dockerfile would automatically run the create_chrooted_jail.sh to set up the chroot jail environment. You should be able to see the chroot/ under your /home/ directory. You can then call the following command to add a new ssh user.
```sh
$ cd /home/
$ bash add_chroot_user.sh
```

#### To add a ssh user from ansible
Noted: For the moment, you need to run the ansible script inside the container. 

The folder contains the following scripts:
 - playbook.yml
 - tasks.yml
 - vars.yml
 - configure_sshd.yml
 - delete_user_account.yml

To create a folder for storing ssh users' keys and configure the sshd_config file:
```sh
$ ansible-playbook playbook-yml --tags ssh-setup
```
To add a new user defined in the vars.yml:
```sh
$ ansible-playbook playbook-yml
```

To delete a ssh user with the 'username' from the system:
```sh
$ ansible-playbook delete_user_account-yml --extra-vars user=username
```
It will delete the user, remove it's home directory, and delete the authorized ssh key file under the /etc/ssh/authorized_keys/



### Todos

 - Write MORE Tests
 - Find a way to execute the ansible script from the outside.
 - Decide which commands we'd like to allow our users to use.
 - Design the structure(the path, and whether we need chroot jail or just set the basic access permission on each directory)
 - Future plan: understand how our web services can fetch websites for this fs.

License
----

...


**Free Software, Hell Yeah!**

