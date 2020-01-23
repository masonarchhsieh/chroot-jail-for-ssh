#!/bin/bash - 
# Note: We might need to adjust this. Can import the users from another script.
# Step 6: Create and Configure SSH user
echo "Enter how many users you want to add:"
read num
user_list=()
JAIL="/home/chroot/"                                                                                                                                                                                           


if [ $num -le 0 ] 
then 
    exit 0 
fi

for i in $(seq 1 $num);
do
    echo "Enter the #$i user name:"
    read user_name
    useradd $user_name # -d "${JAIL}home/$user_name"
    echo "Enter the $user_name password:"
    passwd $user_name

    user_list+=("$user_name")
done

# Step 7: Create the chrooted jail general configurations directory
#         and copy the updated account files#into the directory
mkdir "${JAIL}etc"
cp -vf /etc/{passwd,group} "${JAIL}etc/"

# Step 8: Configure SSH to use Chrooted jail:
user_list_size=${#user_list[*]}
for user in ${user_list[*]}
do
    echo "# define username to apply chroot jail to" >> /etc/ssh/sshd_config
    echo "Match User $user" >> /etc/ssh/sshd_config
    echo "# specify chroot jail" >> /etc/ssh/sshd_config
    echo "ChrootDirectory $JAIL" >> /etc/ssh/sshd_config
done

# Restart the ssh service
#   systemctl restart ssh/sshd
#   service ssh/sshd restart
service ssh restart

# Step 9: Create SSH User's home directory
for user in ${user_list[*]}
do
    mkdir -p "${JAIL}home/$user"
    chown -R $user:$user "${JAIL}home/$user"
    # Set the directory permission
    chmod -R 0750 "${JAIL}home/$user"
   
    # Make is uable outside the chroot jail too
    ln -s "${JAIL}home/$user" "/home/$user"
    # Set the user's home dir to this.
    usermod -d "/home/$user" $user
done

