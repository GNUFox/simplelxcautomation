#!/bin/bash

function help() {
	cat << EOF

SimpleLXCSetupAutomation:

Usage:

  new_container.sh -i <image_name> -n <container_name> [-I <network_interface>]

  -i <image_name>        Name of the image (w/o 'images:') Example: 'debian/11'
  -n <container_name>    Name of the container
  -I <network_interface> Name of the network interface a bridge will be created (macvlan)
                         If only -I is provided 'mvlan0' will be used

EOF
}

MVLAN_EN=0
CONT_IMAGE=""
CONT_NAME=""
HOST_IFACE_NAME=""

while getopts i:n:I option 
do 
  case "${option}" in 
    i)
      CONT_IMAGE=${OPTARG}
      ;; 
    n)
      CONT_NAME=${OPTARG}
      ;; 
    I)
      HOST_IFACE_NAME=${OPTARG}
      MVLAN_EN=1
      ;;
  esac 
done 


if [ "$CONT_IMAGE" == "" ] || [ "$CONT_NAME" == "" ]; then
	help
	exit 0
else
  CONT_IMAGE="images:$CONT_IMAGE"
fi

CONT_IFACE_NAME="eth0"
if [ $MVLAN_EN == 1 ] && [ "$HOST_IFACE_NAME" == "" ]; then
  HOST_IFACE_NAME="mvlan0"
fi

echo "IMAGE: $CONT_IMAGE"
echo "NAME: $CONT_NAME"
echo "CONTAINER INTERFACE: $CONT_IFACE_NAME"
echo "HOST INTERFACE: $HOST_IFACE_NAME"

# TODO: check if container already exists and exit program (could be done via exit code of lxc init if it does set some exit code)

# create container
echo "Creating Container"
lxc init $CONT_IMAGE $CONT_NAME


# confgure network
if [ $MVLAN_EN == 1 ];then
  echo "Config Network"
  lxc config device add $CONT_NAME $CONT_IFACE_NAME nic nictype=macvlan parent=$HOST_IFACE_NAME name=$CONT_IFACE_NAME
fi

echo "Starting Container"
lxc start $CONT_NAME

# show that container is running
lxc list $CONT_NAME

# upload container_config_script.sh to container
if [ $MVLAN_EN == 1 ];then
  echo "Transfering init script to container"
  lxc file push init_container.sh $CONT_NAME/root/

  echo "Now you're logged in inside the container. Run the init script located at '/root/init_container.sh'"
  lxc exec $CONT_NAME -- /bin/bash
  echo "After reboot connect again using 'lxc exec $CONT_NAME -- /bin/bash'"
else
  echo "Connect using 'lxc exec $CONT_NAME -- /bin/bash'"
fi
